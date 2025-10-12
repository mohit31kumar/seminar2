const List<String> seminarHalls = [
  "Basement Seminar Hall",
  "Ground Floor Seminar Hall",
  "1st Floor Seminar Hall",
  "2nd Floor Seminar Hall",
  "3rd Floor Seminar Hall",
  "4th Floor Seminar Hall",
  "5th Floor Seminar Hall",
  "6th Floor Seminar Hall",
  "VIP Lounge"
];

const Map<String, List<Map<String, Object>>> hallFacilities = {
  "Basement Seminar Hall": [
    { "name": "Capacity: 200", "iconName": "Users", "capacity": 200 },
    { "name": "Air Conditioning", "iconName": "Wind" },
    { "name": "Projector & Screen", "iconName": "Video" },
  ],
  "Ground Floor Seminar Hall": [
    { "name": "Capacity: 200", "iconName": "Users", "capacity": 200 },
    { "name": "Air Conditioning", "iconName": "Wind" },
    { "name": "Restriction", "iconName": "ShieldAlert", "description": "Reserved for VIP/VVIP events only." },
  ],
};