const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Sends a push notification to a specific user.
 * @param {string} userId The UID of the user to notify.
 * @param {string} title The title of the notification.
 * @param {string} body The body of the notification.
 */
async function sendNotificationToUser(userId, title, body) {
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return;

  const tokens = userDoc.data().fcmTokens;
  if (!tokens || tokens.length === 0) return;

  const payload = {notification: {title, body}};
  await admin.messaging().sendToDevice(tokens, payload);
}

/**
 * Sends a push notification to all admin users.
 * @param {string} title The title of the notification.
 * @param {string} body The body of the notification.
 */
async function sendNotificationToAdmins(title, body) {
  const adminsSnapshot = await db.collection("users")
      .where("role", "==", "admin").get();
  if (adminsSnapshot.empty) return;

  const adminTokens = [];
  adminsSnapshot.forEach((doc) => {
    const tokens = doc.data().fcmTokens;
    if (tokens && tokens.length > 0) {
      adminTokens.push(...tokens);
    }
  });

  if (adminTokens.length === 0) return;

  const payload = {notification: {title, body}};
  await admin.messaging().sendToDevice(adminTokens, payload);
}


// --- Triggers ---

// 1. Notify admins when a new booking is created.
exports.onNewBookingRequest = functions.firestore
    .document("bookings/{bookingId}")
    .onCreate(async (snap) => {
      const booking = snap.data();
      const title = "New Booking Request";
      const body = `${booking.requestedBy} has requested ${booking.hall}.`;
      await sendNotificationToAdmins(title, body);
    });

// 2. Notify users about status changes (Approved, Rejected, Re-allocated).
exports.onBookingStatusUpdate = functions.firestore
    .document("bookings/{bookingId}")
    .onUpdate(async (change) => {
      const before = change.before.data();
      const after = change.after.data();

      // Only trigger if the status has changed.
      if (before.status === after.status) return;

      const userId = after.requesterId;
      let title = "";
      let body = "";

      switch (after.status) {
        case "Approved":
          title = "Booking Approved!";
          body = `Your request for "${after.title}" has been approved.`;
          // Check for re-allocation
          if (before.hall !== after.hall) {
            body += ` It has been moved to ${after.hall}.`;
          }
          break;
        case "Rejected":
          title = "Booking Rejected";
          body = `Your request for "${after.title}" has been rejected. ` +
                 `Reason: ${after.rejectionReason || "Not specified."}`;
          break;
        default:
          return; // Do not notify for other statuses like 'Cancelled' here.
      }

      await sendNotificationToUser(userId, title, body);
    });

// 3. Notify admins when a user cancels a booking.
exports.onBookingCancelled = functions.firestore
    .document("bookings/{bookingId}")
    .onUpdate(async (change) => {
      const before = change.before.data();
      const after = change.after.data();

      if (before.status !== "Cancelled" && after.status === "Cancelled") {
        const title = "Booking Cancelled";
        const body = `${after.requestedBy} has cancelled their booking ` +
                     `for "${after.title}".`;
        await sendNotificationToAdmins(title, body);
      }
    });
