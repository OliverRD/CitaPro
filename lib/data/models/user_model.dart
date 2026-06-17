class Booking {
  final String? uid;
  final String name;
  final String? document;
  final String email;
  final String phash;
  final String status; 

  Booking({
     this.uid,
    required this.name,
     this.document,
    required this.email,
    required this.phash,
    required this.status,
  });
}