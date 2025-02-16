import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:prac_crud/screens/dasboard_main.dart';
import 'package:google_fonts/google_fonts.dart';

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.list,
    required this.id,
  });

  final List<Assignments> list;
  final String? id;

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  // List<String> dummy = ['hell', "how", "Why", "dfdf", "sdsd", "sdsd", "sdsd"];
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      // width: 250,
      // padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black),
      //   borderRadius: BorderRadius.circular(8),
      // ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  // surfaceTintColor: Color.fromARGB(255, 207, 197, 207),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          DateFormat.yMMMd().format(
                            _timestampToDateTime(widget.list[index].date),
                          ),
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat.EEEE().format(
                            _timestampToDateTime(widget.list[index].date),
                          ),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                );

                //   return Container(
                //     padding: const EdgeInsets.all(15),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.black),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Text(
                //       DateFormat.MEd().format(
                //         _timestampToDateTime(widget.list[index].date),
                //       ),
                //     ),
                //   );
              },
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return DashboardMain(
          //             userID: widget.id,
          //             list: widget.list,
          //           );
          //         },
          //       ),
          //     );
          //   },
          //   icon: const Icon(Icons.arrow_forward),
          // ),
        ],
      ),
    );
  }
}
