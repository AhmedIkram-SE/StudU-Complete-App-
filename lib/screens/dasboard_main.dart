import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:intl/intl.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:prac_crud/services/firestoreservice.dart';

var inst = FireStoreService();

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

class DashboardMain extends StatefulWidget {
  const DashboardMain({
    super.key,
    required this.list,
    required this.userID,
    this.address,
  });

  final List<Assignments> list;
  final String? userID;
  final String? address;
  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  String? compCount;
  String? quizCount;
  String? notesCount;

  @override
  void initState() {
    _getCompletedAssignmentCount();
    _getNotesCount();
    _getQuizestCount();
    super.initState();
  }

  Future<void> _getCompletedAssignmentCount() async {
    compCount = await inst.getCount(widget.userID);
    setState(() {});
  }

  Future<void> _getQuizestCount() async {
    quizCount = await inst.getCountQuizes(widget.userID);
    setState(() {});
  }

  Future<void> _getNotesCount() async {
    notesCount = await inst.getCountNotes(widget.userID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var info = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 229, 202, 1),
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
            // statusBarColor: Color.fromARGB(255, 206, 202, 202),
            ),
        elevation: 4,
        title: Text(
          "Dashboard",
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
              backgroundImage: widget.address != null &&
                      widget.address != "No image attached"
                  ? NetworkImage(widget.address!) as ImageProvider
                  : const AssetImage('assets/images/prof.jpg'),
              radius: 23,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 229, 202, 1),
          ),
          // padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                // height: 250,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 229, 202, 1),
                ),
                child: Card(
                  elevation: 15,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMMd().format(DateTime.now()),
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Text(
                            "Deadlines:",
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.list.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      // surfaceTintColor: Color.fromARGB(255, 207, 197, 207),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              DateFormat.yMMMd().format(
                                                _timestampToDateTime(
                                                    widget.list[index].date),
                                              ),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              DateFormat.EEEE().format(
                                                _timestampToDateTime(
                                                    widget.list[index].date),
                                              ),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              widget.list[index].title,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              widget.list[index].subject,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    // Container(
                                    //   padding: const EdgeInsets.all(15),
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(color: Colors.black),
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Text(
                                    //     DateFormat.MEd().format(
                                    //       _timestampToDateTime(
                                    //           widget.list[index].date),
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  "Stats:",
                  style: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: info == Orientation.portrait
                    ? EdgeInsets.all(0)
                    : EdgeInsets.all(30),
                child: SizedBox(
                  height: info == Orientation.portrait ? 300 : 200,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 20.0,
                            childAspectRatio: 1.5),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      String title;
                      String count;

                      switch (index) {
                        case 0:
                          title = "Assignments";
                          count = widget.list.length.toString();
                          break;

                        case 1:
                          title = "Completed";
                          count = compCount ?? "Loading";
                          break;

                        case 2:
                          title = "Quizes";
                          count = quizCount ?? "Loading";
                          break;
                        case 3:
                          title = "Notes";
                          count = notesCount ?? "Loading";
                          break;

                        default:
                          title = "";
                          count = "";
                      }

                      return Card(
                        elevation: 5,
                        surfaceTintColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(226, 229, 229, 1),
                          ),
                        ),
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/notes.jpg'),
                                fit: BoxFit.contain,
                                opacity: 0.3,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  count,
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                                Text(
                                  title,
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
