import 'package:cloud_firestore/cloud_firestore.dart';

class Assignments {
  const Assignments({
    required this.title,
    required this.subject,
    required this.teachername,
    required this.details,
    required this.date,
    required this.userID,
    required this.file,
    required this.fileName,
  });

  final String title;
  final String subject;
  final String teachername;
  final String details;
  final Timestamp? date;
  final String? userID;
  final String? file;
  final String fileName;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "subject": subject,
      "teachername": teachername,
      "details": details,
      "date": date,
      "userID": userID,
      'file': file,
      'fileName': fileName,
    };
  }

  factory Assignments.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Assignments(
        title: data['title'],
        subject: data['subject'],
        teachername: data['teachername'],
        details: data['details'],
        date: data['date'],
        userID: data["userID"],
        file: data["file"],
        fileName: data['fileName']);
  }
}
