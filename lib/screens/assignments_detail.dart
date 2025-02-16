import 'package:flutter/material.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import 'package:prac_crud/screens/pdfviewerscreen.dart';

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

class AssignmentsDetails extends StatefulWidget {
  const AssignmentsDetails({
    super.key,
    required this.item,
    this.url,
  });

  final Assignments item;
  final String? url;

  @override
  State<AssignmentsDetails> createState() => _AssignmentsDetailsState();
}

class _AssignmentsDetailsState extends State<AssignmentsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
            // statusBarColor: Color.fromARGB(255, 206, 202, 202),
            ),
        elevation: 4,
        title: Text(
          "Details",
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
            child: CircleAvatar(
              backgroundImage:
                  widget.url != null && widget.url != "No image attached"
                      ? NetworkImage(widget.url!) as ImageProvider
                      : const AssetImage('assets/images/prof.jpg'),
              radius: 23,
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(150, 202, 148, 148),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(12),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SUBJECT:",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Text(
                      widget.item.subject,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(149, 148, 202, 184),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(12),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TEACHER:",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Text(
                      widget.item.teachername,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(12),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DETAILS:",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Text(
                      widget.item.details,
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(12),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DEADLINE:",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.yMMMEd().format(
                        _timestampToDateTime(widget.item.date),
                      ),
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(12),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FILE:",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(widget.item.fileName,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        if (widget.item.file != "No file attached") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PdfViewerScreen(
                                  condition: false,
                                  url: widget.item.file,
                                );
                              },
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "No file attached",
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        "Open",
                        style: GoogleFonts.rajdhani(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
