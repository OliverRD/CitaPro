class Booking {
  final String businessName;
  final String serviceName;
   String date;
   String time;
   String status;
  final String imageUrl; 

  Booking({
    required this.businessName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
  });
}