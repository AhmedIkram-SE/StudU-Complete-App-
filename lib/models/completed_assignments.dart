import 'package:cloud_firestore/cloud_firestore.dart';

class ComletedAssignments {
  const ComletedAssignments(
      {required this.title,
      required this.subject,
      required this.teachername,
      required this.details,
      required this.date,
      required this.marks,
      required this.userID});

  final String title;
  final String subject;
  final String teachername;
  final String details;
  final Timestamp? date;
  final int marks;
  final String? userID;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "subject": subject,
      "teachername": teachername,
      "details": details,
      "date": date,
      "marks": marks,
      "userID": userID,
    };
  }

  factory ComletedAssignments.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return ComletedAssignments(
      title: data['title'],
      subject: data['subject'],
      teachername: data['teachername'],
      details: data['details'],
      date: data['date'],
      marks: data['marks'],
      userID: data["userID"],
    );
  }
}
