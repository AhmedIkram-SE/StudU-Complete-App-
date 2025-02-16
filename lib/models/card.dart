import 'package:flutter/material.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:firebase_storage/firebase_storage.dart";

Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
  return Timestamp.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

final inst = FireStoreService();

class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.assignment,
    required this.docID,
    required this.edit(String docID),
  });

  final Assignments assignment;
  final String docID;
  final void Function(String docID) edit;

  @override
  State<CustomCard> createState() => _CardState();
}

class _CardState extends State<CustomCard> {
  late String delFile2;

  Future<String> toDel(String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FireStoreService().getOne(docID);

    if (document.exists) {
      Map<String, dynamic>? data1 = document.data();

      delFile2 = data1?["fileName"];
      return delFile2;
    } else {
      return "N/A";
    }
  }

  // @override
  // void initState() {

  //   super.initState();
  // }

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
                  widget.assignment.title,
                  style: GoogleFonts.rajdhani(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromARGB(150, 202, 148, 148),
                      ),
                      child: Text(widget.assignment.subject),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromARGB(149, 148, 202, 184),
                      ),
                      child: Text(widget.assignment.teachername),
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
                        _timestampToDateTime(widget.assignment.date),
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
                    onPressed: () async {
                      print("Within The del functiuon");
                      delFile2 = await toDel(widget.docID);

                      if (delFile2 != "N/A") {
                        print("Within The del functiuon 2");
                        print(delFile2);
                        final reference2 = FirebaseStorage.instance
                            .ref()
                            .child('pdfs/$delFile2.pdf');
                        await reference2.delete();
                      }
                      inst.delete(widget.docID);
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
