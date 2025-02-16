import 'package:flutter/material.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import "package:prac_crud/models/notes.dart";
import 'package:google_fonts/google_fonts.dart';

Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
  return Timestamp.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

final inst = FireStoreService();

class NotesCard extends StatefulWidget {
  const NotesCard({
    super.key,
    required this.list,
    required this.docID,
    required this.edit(String docID),
  });

  final Notes list;
  final String docID;
  final void Function(String docID) edit;

  @override
  State<NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<NotesCard> {
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
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
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
                      inst.deleteNotes(widget.docID);
                    },
                    icon: const Icon(Icons.delete))
              ],
            )
          ],
        ),
      ),
    );
  }
}
