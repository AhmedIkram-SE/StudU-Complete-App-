import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  const Quiz({
    required this.subject,
    required this.date,
    required this.syllabus,
    required this.title,
    required this.userID,
  });
  final String subject;
  final Timestamp? date;
  final String syllabus;
  final String title;
  final String? userID;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "subject": subject,
      "syllabus": syllabus,
      "date": date,
      "userID": userID,
    };
  }

  factory Quiz.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Quiz(
      title: data['title'],
      subject: data['subject'],
      syllabus: data['syllabus'],
      date: data['date'],
      userID: data["userID"],
    );
  }
}
