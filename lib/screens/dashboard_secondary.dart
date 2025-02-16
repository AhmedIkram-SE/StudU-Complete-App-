import 'package:flutter/material.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var inst = FireStoreService();

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

class DashboardSecondary extends StatefulWidget {
  const DashboardSecondary({
    super.key,
    required this.userID,
    this.address,
  });

  final String? userID;
  final String? address;
  @override
  State<DashboardSecondary> createState() => _DashboardSecondaryState();
}

class _DashboardSecondaryState extends State<DashboardSecondary> {
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
      // appBar: AppBar(
      //   title: const Text("Dashboard"),
      // ),
      // body: Container(
      //   padding: const EdgeInsets.all(15),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Container(
      //         height: 100,
      //         width: double.infinity,
      //         padding: const EdgeInsets.all(12),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.black),
      //           borderRadius: BorderRadius.circular(8),
      //         ),
      //         child: const Text(
      //           "No Assignments added!",
      //           textAlign: TextAlign.center,
      //           style: TextStyle(
      //             fontSize: 20,
      //             fontWeight: FontWeight.w300,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 35,
      //       ),
      //       const Text(
      //         "Stats:",
      //         style: TextStyle(
      //           fontSize: 40,
      //           fontWeight: FontWeight.w200,
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       Container(
      //         padding: const EdgeInsets.all(15),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.black),
      //           borderRadius: const BorderRadius.vertical(
      //             top: Radius.elliptical(12, 15),
      //           ),
      //         ),
      //         child: const Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               "Assignments",
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w400,
      //               ),
      //             ),
      //             Text(
      //               '0',
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w200,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       Container(
      //         padding: const EdgeInsets.all(15),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.black),
      //           borderRadius: const BorderRadius.vertical(
      //             bottom: Radius.elliptical(12, 15),
      //           ),
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Text(
      //               "Completed Assignments",
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w400,
      //               ),
      //             ),
      //             Text(
      //               compCount != null ? compCount! : "Loading..",
      //               style: const TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w200,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       Container(
      //         padding: const EdgeInsets.all(15),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.black),
      //           borderRadius: const BorderRadius.vertical(
      //             top: Radius.elliptical(12, 15),
      //           ),
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Text(
      //               "Quizes",
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w400,
      //               ),
      //             ),
      //             Text(
      //               quizCount != null ? quizCount! : "Loading..",
      //               style: const TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w200,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       Container(
      //         padding: const EdgeInsets.all(15),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.black),
      //           borderRadius: const BorderRadius.vertical(
      //             bottom: Radius.elliptical(12, 15),
      //           ),
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Text(
      //               "Notes addeed",
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w400,
      //               ),
      //             ),
      //             Text(
      //               notesCount != null ? notesCount! : "Loading..",
      //               style: const TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.w200,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
          height: 727,
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
                            "No Assignments added:",
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
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
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.all(30),
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
                          count = "0";
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
