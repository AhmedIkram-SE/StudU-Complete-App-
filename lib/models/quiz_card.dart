import 'package:flutter/material.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:prac_crud/models/quizes.dart";

Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
  return Timestamp.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

final inst = FireStoreService();

class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.list,
    required this.docID,
    required this.edit(String docID),
  });

  final Quiz list;
  final String docID;
  final void Function(String docID) edit;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: ContinuousRectangleBorder(
        side: const BorderSide(width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      // color: Color.fromARGB(255, 255, 255, 255),
      surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.list.title,
                  style: GoogleFonts.rajdhani(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromARGB(150, 202, 148, 148),
                      ),
                      child: Text(widget.list.subject),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      DateFormat.yMMMEd().format(
                        _timestampToDateTime(widget.list.date),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {
                      widget.edit(widget.docID);
                    },
                    icon: const Icon(Icons.edit)),
                const SizedBox(
                  height: 12,
                ),
                IconButton(
                    onPressed: () {
                      inst.deleteQuiz(widget.docID);
                    },
                    icon: const Icon(Icons.delete_outline))
              ],
            )
          ],
        ),
      ),
    );
  }
}
