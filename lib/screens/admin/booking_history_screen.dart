import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _searchTerm = '';
  List<Booking> _filteredBookings = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the list with all bookings
    final allBookings = context.read<AppState>().bookings;
    _filteredBookings = List.from(allBookings)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _filterBookings(String query) {
    final allBookings = context.read<AppState>().bookings;
    setState(() {
      _searchTerm = query;
      if (_searchTerm.isEmpty) {
        _filteredBookings = List.from(allBookings)
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        _filteredBookings = allBookings.where((booking) {
          final lowerQuery = query.toLowerCase();
          return booking.title.toLowerCase().contains(lowerQuery) ||
              booking.requestedBy.toLowerCase().contains(lowerQuery) ||
              booking.hall.toLowerCase().contains(lowerQuery);
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterBookings,
              decoration: const InputDecoration(
                labelText: 'Search by title, name, or hall',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredBookings.isEmpty
                ? Center(
                    child: Text(_searchTerm.isEmpty
                        ? 'No bookings found.'
                        : 'No results for "$_searchTerm"'))
                : ListView.builder(
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(booking.title),
                          subtitle:
                              Text('${booking.requestedBy} - ${booking.hall}'),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat.yMd()
                                  .format(DateTime.parse(booking.date))),
                              Text(booking.status,
                                  style: TextStyle(
                                      color: _getStatusColor(booking.status))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
