import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {
  const Notes({
    required this.date,
    required this.details,
    required this.title,
    required this.userID,
  });

  final Timestamp? date;
  final String details;
  final String title;
  final String? userID;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "details": details,
      "date": date,
      "userID": userID,
    };
  }

  factory Notes.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Notes(
      title: data['title'],
      details: data['details'],
      date: data['date'],
      userID: data["userID"],
    );
  }
}
