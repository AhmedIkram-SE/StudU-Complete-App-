import 'package:flutter/material.dart';

import 'package:prac_crud/models/card.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prac_crud/models/completed_assignments.dart';
import 'package:prac_crud/screens/pdfviewerscreen.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:prac_crud/screens/assignments_detail.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:prac_crud/config.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({
    super.key,
    required this.uid,
    this.imageADDRESS,
  });

  final String? uid;
  final String? imageADDRESS;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController title = TextEditingController();
  final TextEditingController subject = TextEditingController();
  final TextEditingController teachername = TextEditingController();
  final TextEditingController details = TextEditingController();
  final TextEditingController edDate = TextEditingController();
  final TextEditingController marks = TextEditingController();
  final TextEditingController fileAddrss = TextEditingController();

  DateTime? date;
  Timestamp? fndate;
  DateTime? upDate;
  bool checker = false;
  bool check = false;
  bool isLoading = false;
  late String address;
  late File manFile;
  late String url = "";
  late String delFile;
  late String delFile2;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  BannerAd? _bannerAd1;

  bool _isLoaded = false;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final adUnitId = assScreenAdID1;
  final adUnitId3 = assScreenAdID3;
  final adUnitId2 = assScreenAdID2;

  Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime!.millisecondsSinceEpoch);
  }

  DateTime _timestampToDateTime(Timestamp? dateTime) {
    return DateTime.fromMillisecondsSinceEpoch(
        dateTime!.millisecondsSinceEpoch);
  }

  Future<String> uploadPdf(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;
  }

  void loadAd2() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId2,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadAd3() {
    _bannerAd1 = BannerAd(
      adUnitId: adUnitId3,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
                  print("Sowed AD");
                },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  print("Could Not Show AD");
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  print("Came out of the AD");
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void empty() {
    title.clear();
    subject.clear();
    teachername.clear();
    details.clear();
    edDate.clear();
  }

  void showDate() async {
    date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color.fromRGBO(
                    255, 229, 202, 1), //header and selced day background color
                onPrimary: Colors.white, // titles and
                //onSurface: Colors.black, // Month days , years
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // ok , cancel    buttons
                ),
              ),
            ),
            child: child!);
      },
    );

    fndate = _dateTimeToTimestamp(date);
    edDate.text = DateFormat.yMMMEd().format(date!);
    checker = true;
  }

  void edit(String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FireStoreService().getOne(docID);

    if (document.exists) {
      Map<String, dynamic>? data = document.data();

      title.text = data?["title"];
      subject.text = data?['subject'];
      teachername.text = data?['teachername'];
      details.text = data?["details"];
      upDate = _timestampToDateTime(data?['date']);
      edDate.text = DateFormat.yMMMEd().format(upDate!);
      fileAddrss.text = data?["fileName"];

      setState(() {
        url = data?["file"];
        delFile = data?["fileName"];
        print("Got the url");
        print(url);
      });
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Color.fromRGBO(255, 251, 233, 1),
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
                backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                // backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                surfaceTintColor: Colors.white,
                shadowColor: Colors.black,
                elevation: 4,
                // title: Text(
                //   "Add Assignment",
                //   style: GoogleFonts.rajdhani(
                //     textStyle:
                //         TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                //   ),
                // ),
                leading: GestureDetector(
                  child: Icon(Icons.close),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              key: scaffoldKey,
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 25, 17, 17),
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Assignment",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Title",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: title,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Title",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(160, 125, 28, 1),
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(10),
                                fillColor: Color.fromRGBO(255, 229, 202, 1),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Subject",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: subject,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Subject",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(160, 125, 28, 1),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding: EdgeInsets.all(10),
                                fillColor: Color.fromRGBO(255, 229, 202, 1),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3),
                                    ),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Teacher",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: teachername,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Teacher Name",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(160, 125, 28, 1),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding: EdgeInsets.all(10),
                                fillColor: Color.fromRGBO(255, 229, 202, 1),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Details",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 150,
                              child: TextFormField(
                                controller: details,
                                cursorColor: Colors.black,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                decoration: const InputDecoration(
                                  alignLabelWithHint: true,
                                  labelText: "Details",
                                  labelStyle: TextStyle(
                                    color: Color.fromRGBO(160, 125, 28, 1),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 20),
                                  fillColor: Color.fromRGBO(255, 229, 202, 1),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: null,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please Add the info";
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Due Date",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    showDate();
                                  },
                                  icon: Icon(Icons.calendar_month_outlined),
                                ),
                                labelText: "Due Date",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(160, 125, 28, 1),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintText: "Due Date",
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(160, 125, 28, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                                contentPadding: EdgeInsets.all(10),
                                fillColor: Color.fromRGBO(255, 229, 202, 1),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              controller: edDate,
                              enabled: true,
                              readOnly: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter the deadline date";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Complete",
                                style: GoogleFonts.rajdhani(
                                    textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                )),
                              ),
                              Checkbox(
                                value: false,
                                onChanged: (value) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        elevation: 6,
                                        shadowColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        backgroundColor:
                                            Color.fromRGBO(255, 251, 233, 1),
                                        title: Text(
                                          "Completed?",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        content: Text(
                                          "Add this assignment to completed?",
                                          style: GoogleFonts.rajdhani(
                                              textStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                        ),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  style: GoogleFonts.rajdhani(
                                                    textStyle: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Marks",
                                                    labelStyle: TextStyle(
                                                      color: Color.fromRGBO(
                                                          160, 125, 28, 1),
                                                    ),
                                                    filled: true,
                                                    contentPadding:
                                                        EdgeInsets.all(10),
                                                    fillColor: Color.fromRGBO(
                                                        255, 229, 202, 1),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                      // BorderSide(color: Colors.black, width: 2),
                                                    ),
                                                  ),
                                                  controller: marks,
                                                  cursorColor: Colors.black,
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  final List<ConnectivityResult>
                                                      connectivityResult =
                                                      await (Connectivity()
                                                          .checkConnectivity());

                                                  if (connectivityResult
                                                          .contains(
                                                              ConnectivityResult
                                                                  .wifi) ||
                                                      connectivityResult
                                                          .contains(
                                                              ConnectivityResult
                                                                  .mobile)) {
                                                    inst.addingComp(
                                                      ComletedAssignments(
                                                          title: title.text,
                                                          subject: subject.text,
                                                          teachername:
                                                              teachername.text,
                                                          details: details.text,
                                                          date: checker
                                                              ? fndate
                                                              : _dateTimeToTimestamp(
                                                                  upDate),
                                                          marks: int.parse(
                                                              marks.text),
                                                          userID: widget.uid),
                                                    );
                                                    inst.delete(docID);
                                                    if (fileAddrss.text !=
                                                        "N/A") {
                                                      final reference2 =
                                                          FirebaseStorage
                                                              .instance
                                                              .ref()
                                                              .child(
                                                                  'pdfs/$delFile.pdf');
                                                      await reference2.delete();
                                                    }
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "No internet connection available",
                                                          style: GoogleFonts
                                                              .rajdhani(
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(Icons.send),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      labelText: "Attach File (*.pdf)"),
                                  controller: fileAddrss,
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  enabled: false,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Attach file?";
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                onPressed: () async {
                                  print("Inside Function");

                                  // if (await Permission.manageExternalStorage.request().isGranted) {
                                  final pickedFile =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );

                                  if (pickedFile != null) {
                                    String fileName = pickedFile.files[0].name;

                                    File file = File(pickedFile.files[0].path!);

                                    //final downloadLink = await uploadPdf(fileName, file);

                                    // setState(() {});

                                    // print("$downloadLink");
                                    setState(() {
                                      check = true;
                                      manFile = file;

                                      // address = downloadLink;
                                      fileAddrss.text = fileName;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.file_present),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(255, 251, 233, 1),
                                  surfaceTintColor:
                                      Color.fromRGBO(255, 229, 202, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  if (check == true) {
                                    print("Here in pdf viewver");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return PdfViewerScreen(
                                          condition: true,
                                          file: manFile,
                                        );
                                      }),
                                    );
                                  }
                                  if (url == "No file attached") {
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
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } else if (check == false) {
                                    print("Here in pdf viewver without edit");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return PdfViewerScreen(
                                          condition: false,
                                          url: url,
                                        );
                                      }),
                                    );
                                    // print("Within snackbar");
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text(
                                    //       "No file attached!",
                                    //       style: GoogleFonts.rajdhani(
                                    //         textStyle: const TextStyle(
                                    //           fontSize: 20,
                                    //           fontWeight: FontWeight.w300,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     backgroundColor: Colors.black,
                                    //     duration: const Duration(
                                    //       seconds: 1,
                                    //     ),
                                    //   ),
                                    // );
                                  }
                                },
                                child: Text(
                                  "View file",
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(170, 20),
                                  backgroundColor:
                                      Color.fromRGBO(255, 251, 233, 1),
                                  surfaceTintColor:
                                      Color.fromRGBO(255, 229, 202, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () async {
                                  final isValid =
                                      formKey.currentState!.validate();
                                  if (!isValid) {
                                    return;
                                  }

                                  final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                  if (connectivityResult
                                          .contains(ConnectivityResult.wifi) ||
                                      connectivityResult.contains(
                                          ConnectivityResult.mobile)) {
                                    setState(() {
                                      isLoading = true;
                                      print("Loading: $isLoading");
                                    });
                                    if (check) {
                                      final downoadLink = await uploadPdf(
                                          fileAddrss.text, manFile);
                                      address = downoadLink;
                                    }
                                    Assignments updatedAss = Assignments(
                                      title: title.text,
                                      subject: subject.text,
                                      teachername: teachername.text,
                                      details: details.text,
                                      date: checker
                                          ? fndate
                                          : _dateTimeToTimestamp(upDate),
                                      userID: widget.uid,
                                      file: check ? address : url,
                                      fileName: check
                                          ? fileAddrss.text
                                          : fileAddrss.text,
                                    );
                                    if (check) {
                                      if (delFile != "N/A") {
                                        final reference1 = FirebaseStorage
                                            .instance
                                            .ref()
                                            .child('pdfs/$delFile.pdf');
                                        await reference1.delete();
                                      }
                                    }

                                    setState(() {
                                      check = false;
                                    });

                                    inst
                                        .updating(docID, updatedAss)
                                        .whenComplete(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                          "Assignment Added",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        )),
                                      );
                                      empty();
                                      Navigator.pop(context);
                                      setState(() {
                                        isLoading = false;
                                        print("Loading: $isLoading");
                                      });
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "No internet connection available",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        duration: const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
                                  }

                                  //   formKey.currentState!.save();
                                  //   Assignments updatedAss = Assignments(
                                  //     title: title.text,
                                  //     subject: subject.text,
                                  //     teachername: teachername.text,
                                  //     details: details.text,
                                  //     date: checker
                                  //         ? fndate
                                  //         : _dateTimeToTimestamp(upDate),
                                  //     userID: widget.uid,
                                  //     file: check ? address : url,
                                  //     fileName:
                                  //         check ? fileAddrss.text : fileAddrss.text,
                                  //   );

                                  //   inst.updating(docID, updatedAss);
                                  //   empty();
                                  //   Navigator.pop(context);
                                },
                                child: isLoading
                                    ? const LinearProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Text(
                                        "Update Assignment",
                                        style: GoogleFonts.rajdhani(
                                          textStyle: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      setState(() {
        check = false;
      });
    });
  }

  @override
  void initState() {
    loadAd2();
    loadAd3();
    debugPrint("In the init state");
    Future.delayed(
      Duration(seconds: 10),
      () {
        loadAd();
      },
    );
    super.initState();
  }

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
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
            child: CircleAvatar(
              backgroundImage: widget.imageADDRESS != null &&
                      widget.imageADDRESS != "No image attached"
                  ? NetworkImage(widget.imageADDRESS!) as ImageProvider
                  : const AssetImage('assets/images/prof.jpg'),
              radius: 23,
            ),
          )
        ],
        title: Text(
          "Assignments",
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: inst.getData(widget.uid),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(
          //       color: Colors.black,
          //     ),
          //   );
          // }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<Assignments> asses = snapshot.data!.docs
                .map((document) => Assignments.fromSnapshot(document))
                .toList();

            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 229, 202, 1),
                    ),
                    child: ListView.builder(
                      itemCount: asses.length,
                      itemBuilder: (context, index) {
                        String id = snapshot.data!.docs[index].id;
                        return GestureDetector(
                          child: CustomCard(
                            assignment: asses[index],
                            docID: id,
                            edit: (docID) {
                              edit(docID);
                            },
                          ),
                          onTap: () {
                            if (_interstitialAd != null) {
                              _interstitialAd!.show();
                              setState(() {
                                _interstitialAd = null;
                              });
                              setState(() {
                                Future.delayed(
                                  const Duration(minutes: 2),
                                  () {
                                    loadAd();
                                  },
                                );
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AssignmentsDetails(
                                      item: asses[index],
                                      url: widget.imageADDRESS,
                                    );
                                  },
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AssignmentsDetails(
                                      item: asses[index],
                                      url: widget.imageADDRESS,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                _bannerAd == null
                    ? Container()
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
              ],
            );
          }
          return Builder(builder: (context) {
            return Container(
              padding: const EdgeInsets.all(40),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 229, 202, 1),
                image: DecorationImage(
                    image: AssetImage("assets/images/no_data.jpg"),
                    opacity: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "No assignments added!",
                    style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w500)),
                  ),
                  _bannerAd1 == null
                      ? Container()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                            child: SizedBox(
                              width: _bannerAd1!.size.width.toDouble(),
                              height: _bannerAd1!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd1!),
                            ),
                          ),
                        ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
