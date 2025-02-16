import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:prac_crud/dashboard.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:prac_crud/models/completed_assignments.dart';
import 'package:prac_crud/models/notes.dart';
import 'package:prac_crud/models/panels.dart';
import 'package:prac_crud/models/quizes.dart';
import 'package:prac_crud/screens/assignments_screen.dart';
import 'package:prac_crud/screens/completed_assignments.dart';
import 'package:prac_crud/screens/dashboard_secondary.dart';
import 'package:prac_crud/screens/notes_screen.dart';
import 'package:prac_crud/screens/pdfviewerscreen.dart';
import 'package:prac_crud/screens/quizes_screen.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:prac_crud/screens/userinfo_screen.dart';
import 'package:prac_crud/screens/dasboard_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:prac_crud/config.dart';

var inst = FireStoreService();
final FirebaseFirestore db = FirebaseFirestore.instance;

Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
  return Timestamp.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

DateTime _timestampToDateTime(Timestamp? dateTime) {
  return DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid});
  final String? uid;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController title = TextEditingController();
  final TextEditingController subject = TextEditingController();
  final TextEditingController teachername = TextEditingController();
  final TextEditingController details = TextEditingController();
  final TextEditingController edDate = TextEditingController();
  final TextEditingController marks = TextEditingController();
  final TextEditingController fileAddrss = TextEditingController();

  BannerAd? _bannerAd;

  bool _isLoaded = false;
  bool check = false;
  late String address;
  late File manFile;
  bool isLoading = false;
  bool delCheck = false;

  DateTime? date;
  Timestamp? fndate;
  DateTime? upDate;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final adUnitId = homepageAdID;

  Future<String> uploadPdf(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId, //Place your ad ID here
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

  void empty() {
    title.clear();
    subject.clear();
    teachername.clear();
    details.clear();
    edDate.clear();
    fileAddrss.clear();
    marks.clear();
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
  }

  void chekConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile)) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No Internet Connected",
            style: GoogleFonts.rajdhani(
                textStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
          ),
        ),
      );
    }
  }

  void helpDelAss(List<QueryDocumentSnapshot> data) async {
    print("Within Del ASS");
    for (int i = 0; i < data.length; i++) {
      print("2nd Step");
      String aID = data[i].id;
      Map<String, dynamic> aDATA = data[i].data() as Map<String, dynamic>;
      if (aDATA["fileName"] != "N/A") {
        print("3rd Step");
        final reference2 = FirebaseStorage.instance
            .ref()
            .child('pdfs/${aDATA["fileName"]}.pdf');
        await reference2.delete();
      }
      inst.delete(aID);
    }
  }

  void helpDelCompAss(List<QueryDocumentSnapshot> data) {
    print("Within Del COMPASS");
    for (int i = 0; i < data.length; i++) {
      print("2nd Step");
      String aID = data[i].id;

      inst.deleteComp(aID);
    }
  }

  void helpDelQuizes(List<QueryDocumentSnapshot> data) {
    print("Within Del Quizes");
    for (int i = 0; i < data.length; i++) {
      print("2nd Step");
      String aID = data[i].id;

      inst.deleteQuiz(aID);
    }
  }

  void helpDelNotes(List<QueryDocumentSnapshot> data) {
    print("Within Del NOTES");
    for (int i = 0; i < data.length; i++) {
      print("2nd Step");
      String aID = data[i].id;

      inst.deleteNotes(aID);
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      print("1st Step");
      await getAssignmentsData();
      await getCompletedData();
      await getNotesData();
      await getQuizesData();
      print(assignmentData!.length);
      helpDelAss(assignmentData!);
      helpDelCompAss(completedData!);
      helpDelQuizes(quizesData!);
      helpDelNotes(notesData!);
      // for (int i = 0; i < assignmentData!.length; i++) {
      //   print("2nd Step");
      //   String aID = assignmentData![i].id;
      //   Map<String, dynamic> aDATA =
      //       assignmentData![i].data() as Map<String, dynamic>;
      //   if (aDATA["fileName"] != "N/A") {
      //     print("3rd Step");
      //     final reference2 = FirebaseStorage.instance
      //         .ref()
      //         .child('pdfs/${aDATA["fileName"]}.pdf');
      //     await reference2.delete();
      //   }
      //   inst.delete(aID);
      // }
      print(userData);
      if (userData != null && userData?["fileName"] != "N/A") {
        print("Step 4");
        final reference3 = FirebaseStorage.instance
            .ref()
            .child('images/${userData!["fileName"]}.jpg');
        await reference3.delete();
      }
      print(curuser);
      if (curuser != null) {
        print("Step 4.5");
        inst.deleteUser(curuser!.id);
      }
      print("Step 5");
      Navigator.of(context).pop();
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      print(e);

      // Handle general exception
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    print("Re Step");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sign In Again"),
          content: Text(
              "Your data has been deleted, due to security reasons, sign in again to delete your account."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: GoogleFonts.rajdhani(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    // try {
    //   print("Within the try block");
    //   final providerData =
    //       FirebaseAuth.instance.currentUser?.providerData.first;

    //   if (AppleAuthProvider().providerId == providerData!.providerId) {
    //     print("in Apple");
    //     await FirebaseAuth.instance.currentUser!
    //         .reauthenticateWithProvider(AppleAuthProvider());
    //   } else if (GoogleAuthProvider().providerId == providerData.providerId) {
    //     print("in google");
    //     await FirebaseAuth.instance.currentUser!
    //         .reauthenticateWithProvider(GoogleAuthProvider());
    //   }

    //   // for (int i = 0; i < assignmentData!.length; i++) {
    //   //   String aID = assignmentData![i].id;
    //   //   Map<String, dynamic> aDATA =
    //   //       assignmentData![i].data() as Map<String, dynamic>;
    //   //   if (aDATA["fileName"] != "N/A") {
    //   //     final reference2 = FirebaseStorage.instance
    //   //         .ref()
    //   //         .child('pdfs/${aDATA["fileName"]}.pdf');
    //   //     await reference2.delete();
    //   //   }
    //   //   inst.delete(aID);
    //   // }
    //   // if (userData!["fileName"] != "NA") {
    //   //   print("Step 4");
    //   //   final reference3 = FirebaseStorage.instance
    //   //       .ref()
    //   //       .child('images/${userData!["fileName"]}.jpg');
    //   //   await reference3.delete();
    //   // }
    //   // inst.deleteUser(curuser!.id);
    //   print("in delete");
    //   await FirebaseAuth.instance.currentUser?.delete();
    // } catch (e) {
    //   // Handle exceptions
    // }
  }

  void open() {
    empty();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              key: scaffoldKey,
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              "Add new Assignment",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w300),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: title,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: subject,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Subject",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: teachername,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Teacher Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: details,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Details",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              maxLines: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Deadline"),
                                    controller: edDate,
                                    style: GoogleFonts.rajdhani(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    enabled: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter the deadline date";
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDate();
                                  },
                                  icon:
                                      const Icon(Icons.calendar_month_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: "Attach File* (.pdf)"),
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
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: BeveledRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  if (check) {
                                    print("Here in pdf viewver");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return PdfViewerScreen(
                                            file: manFile,
                                            condition: true,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    print("Within snackbar");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "No file attached!",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                        duration: const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "View FILE",
                                  style: GoogleFonts.rajdhani(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(170, 20),
                                  shape: BeveledRectangleBorder(
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

                                  formKey.currentState!.save();
                                  final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                  if (connectivityResult
                                          .contains(ConnectivityResult.wifi) ||
                                      connectivityResult.contains(
                                          ConnectivityResult.mobile)) {
                                    setState(() {
                                      isLoading = true;
                                      print("isLoading: $isLoading");
                                    });
                                    if (check) {
                                      final downoadLink = await uploadPdf(
                                          fileAddrss.text, manFile);
                                      address = downoadLink;
                                    }
                                    Assignments newAss = Assignments(
                                      title: title.text,
                                      subject: subject.text,
                                      teachername: teachername.text,
                                      details: details.text,
                                      date: fndate,
                                      userID: widget.uid,
                                      file:
                                          check ? address : "No file attached",
                                      fileName: check ? fileAddrss.text : "N/A",
                                    );
                                    setState(() {
                                      check = false;
                                    });

                                    inst.adding(newAss).whenComplete(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                          "Assignment Added",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        )),
                                      );
                                      empty();
                                      Navigator.pop(context);
                                      setState(() {
                                        isLoading = false;
                                        print("isLoading: $isLoading");
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
                                },
                                child: isLoading
                                    ? const LinearProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Text(
                                        "Add to Assignments",
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
                        ],
                      ),
                      const SizedBox(
                        height: 15,
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
        isLoading = false;
      });
    });
  }

  void open2() {
    empty();
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
                              "New Assignment",
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  // BorderSide(color: Colors.black, width: 2),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                cursorColor: Colors.black,
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              cursorColor: Colors.black,
                              enabled: true,
                              readOnly: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter the deadline date";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: "Attach File (*.pdf)",
                                    // floatingLabelBehavior:
                                    //     FloatingLabelBehavior.never,
                                  ),
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
                            height: 15,
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
                                  if (check) {
                                    print("Here in pdf viewver");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return PdfViewerScreen(
                                            file: manFile,
                                            condition: true,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    print("Within snackbar");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "No file attached!",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                        duration: const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
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
                                  backgroundColor:
                                      Color.fromRGBO(255, 251, 233, 1),
                                  surfaceTintColor:
                                      Color.fromRGBO(255, 229, 202, 1),
                                  fixedSize: const Size(170, 20),
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

                                  formKey.currentState!.save();
                                  final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                  if (connectivityResult
                                          .contains(ConnectivityResult.wifi) ||
                                      connectivityResult.contains(
                                          ConnectivityResult.mobile)) {
                                    setState(() {
                                      isLoading = true;
                                      print("isLoading: $isLoading");
                                    });
                                    if (check) {
                                      final downoadLink = await uploadPdf(
                                          fileAddrss.text, manFile);
                                      address = downoadLink;
                                    }
                                    Assignments newAss = Assignments(
                                      title: title.text,
                                      subject: subject.text,
                                      teachername: teachername.text,
                                      details: details.text,
                                      date: fndate,
                                      userID: widget.uid,
                                      file:
                                          check ? address : "No file attached",
                                      fileName: check ? fileAddrss.text : "N/A",
                                    );
                                    setState(() {
                                      check = false;
                                    });

                                    inst.adding(newAss).whenComplete(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                          "Assignment Added",
                                          style: GoogleFonts.rajdhani(
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        )),
                                      );
                                      empty();
                                      Navigator.pop(context);
                                      setState(() {
                                        isLoading = false;
                                        print("isLoading: $isLoading");
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
                                },
                                child: isLoading
                                    ? const LinearProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Text(
                                        "Add Assignment",
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
                      const SizedBox(
                        height: 15,
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
        isLoading = false;
      });
    });
  }

  void openComp2() {
    empty();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        var info = MediaQuery.of(context).orientation;
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
              body: Padding(
                padding: const EdgeInsets.fromLTRB(17, 25, 17, 17),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Completed Assignment",
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                expands: true,
                                cursorColor: Colors.black,
                                textAlignVertical: TextAlignVertical.top,
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Details",
                                  alignLabelWithHint: true,
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
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      info == Orientation.portrait ? 100 : 150,
                                  child: TextFormField(
                                    controller: marks,
                                    cursorColor: Colors.black,
                                    style: GoogleFonts.rajdhani(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Marks",
                                      labelStyle: TextStyle(
                                        color: Color.fromRGBO(160, 125, 28, 1),
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      contentPadding: info ==
                                              Orientation.portrait
                                          ? EdgeInsets.fromLTRB(23, 10, 10, 10)
                                          : EdgeInsets.fromLTRB(50, 10, 10, 10),
                                      fillColor:
                                          Color.fromRGBO(255, 229, 202, 1),
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
                                ),
                                SizedBox(
                                  width:
                                      info == Orientation.portrait ? 200 : 250,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: "Due Date",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          showDate();
                                        },
                                        icon:
                                            Icon(Icons.calendar_month_outlined),
                                      ),
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
                                      fillColor:
                                          Color.fromRGBO(255, 229, 202, 1),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                          surfaceTintColor: Color.fromRGBO(255, 229, 202, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());
                          setState(() {
                            isLoading = true;
                            print("Loading: $isLoading");
                          });
                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            ComletedAssignments newAss = ComletedAssignments(
                                title: title.text,
                                subject: subject.text,
                                teachername: teachername.text,
                                details: details.text,
                                date: fndate,
                                marks: int.parse(marks.text),
                                userID: widget.uid);

                            inst.addingComp(newAss).whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Assignment Added",
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add Completed Assignment",
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
                ),
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  void openComp() {
    empty();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              "Add Completed Assignment",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w300),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: title,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: subject,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Subject",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: teachername,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Teacher Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: details,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Details",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              maxLines: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: marks,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Marks",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Deadline"),
                                    controller: edDate,
                                    enabled: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter the deadline date";
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDate();
                                  },
                                  icon:
                                      const Icon(Icons.calendar_month_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());
                          setState(() {
                            isLoading = true;
                            print("Loading: $isLoading");
                          });
                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            ComletedAssignments newAss = ComletedAssignments(
                                title: title.text,
                                subject: subject.text,
                                teachername: teachername.text,
                                details: details.text,
                                date: fndate,
                                marks: int.parse(marks.text),
                                userID: widget.uid);

                            inst.addingComp(newAss).whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Assignment Added",
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add to Completed Assignments",
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
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  void openQuiz() {
    empty();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              "Add new Quiz",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w300),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: title,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: subject,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Subject",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: details,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Syllabus",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              maxLines: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Quiz Date"),
                                    controller: edDate,
                                    enabled: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter the date";
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDate();
                                  },
                                  icon:
                                      const Icon(Icons.calendar_month_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());

                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            setState(() {
                              isLoading = true;
                              print("Loading: $isLoading");
                            });
                            Quiz newQuiz = Quiz(
                                title: title.text,
                                subject: subject.text,
                                syllabus: details.text,
                                date: fndate,
                                userID: widget.uid);

                            inst.addingQuiz(newQuiz).whenComplete(() {
                              print("Withing snackbar");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Quiz Added",
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
                              Navigator.pop(context);
                              empty();
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add to Quizes",
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
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  void openQuiz2() {
    empty();
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
                // backgroundColor:
                //Color.fromRGBO(255, 255, 255, 1),
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
                              "New Quiz",
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                              "Syllabus",
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
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Syllabus",
                                  alignLabelWithHint: true,
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
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
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
                              "Quiz Date",
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          showDate();
                                        },
                                        icon:
                                            Icon(Icons.calendar_month_outlined),
                                      ),
                                      labelText: "Quiz Date",
                                      labelStyle: TextStyle(
                                        color: Color.fromRGBO(160, 125, 28, 1),
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      hintText: "Quiz Date",
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(160, 125, 28, 1),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      fillColor:
                                          Color.fromRGBO(255, 229, 202, 1),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    controller: edDate,
                                    cursorColor: Colors.black,
                                    enabled: true,
                                    readOnly: true,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter the date";
                                      }
                                    },
                                  ),
                                ),
                                // const SizedBox(
                                //   width: 10,
                                // ),
                                // IconButton(
                                //   onPressed: () {
                                //     showDate();
                                //   },
                                //   icon:
                                //       const Icon(Icons.calendar_month_rounded),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                          surfaceTintColor: Color.fromRGBO(255, 229, 202, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());

                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            setState(() {
                              isLoading = true;
                              print("Loading: $isLoading");
                            });
                            Quiz newQuiz = Quiz(
                                title: title.text,
                                subject: subject.text,
                                syllabus: details.text,
                                date: fndate,
                                userID: widget.uid);

                            inst.addingQuiz(newQuiz).whenComplete(() {
                              print("Withing snackbar");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Quiz Added",
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
                              Navigator.pop(context);
                              empty();
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add Quiz",
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
                ),
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  void openNotes() {
    empty();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              "Add new Note",
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w300),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: title,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: details,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Details",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              maxLines: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Add the info";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          date = DateTime.now();
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());

                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            setState(() {
                              isLoading = true;
                              print("Loading: $isLoading");
                            });
                            Notes newNote = Notes(
                                title: title.text,
                                details: details.text,
                                date: _dateTimeToTimestamp(date),
                                userID: widget.uid);

                            inst.addingNotes(newNote).whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Note Added",
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add to Notes",
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
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  void openNotes2() {
    empty();
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
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "New Note",
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
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
                              height: 32,
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
                              height: 400,
                              child: TextFormField(
                                controller: details,
                                cursorColor: Colors.black,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Details",
                                  alignLabelWithHint: true,
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
                                maxLines: null,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please Add the info";
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                          surfaceTintColor: Color.fromRGBO(255, 229, 202, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          if (!isValid) {
                            return;
                          }
                          date = DateTime.now();
                          formKey.currentState!.save();
                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());

                          if (connectivityResult
                                  .contains(ConnectivityResult.wifi) ||
                              connectivityResult
                                  .contains(ConnectivityResult.mobile)) {
                            setState(() {
                              isLoading = true;
                              print("Loading: $isLoading");
                            });
                            Notes newNote = Notes(
                                title: title.text,
                                details: details.text,
                                date: _dateTimeToTimestamp(date),
                                userID: widget.uid);

                            inst.addingNotes(newNote).whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Note Added",
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
                        },
                        child: isLoading
                            ? const LinearProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Add Note",
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
                ),
              ),
            );
          },
        );
      },
      isScrollControlled: true,
      useSafeArea: true,
    ).whenComplete(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getAssignmentsData();
    getCompletedData();
    getNotesData();
    getQuizesData();

    chekConnection();
    loadAd();
  }

  Map<String, dynamic>? userData;
  QueryDocumentSnapshot? curuser;
  List<QueryDocumentSnapshot>? assignmentData;
  List<QueryDocumentSnapshot>? completedData;
  List<QueryDocumentSnapshot>? quizesData;
  List<QueryDocumentSnapshot>? notesData;

  Future<void> getUserData() async {
    QuerySnapshot querySnapshot = await db
        .collection("Users")
        .where('userID', isEqualTo: widget.uid)
        .get();

    setState(() {
      userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      curuser = querySnapshot.docs.first;
    });
  }

  Future<void> getAssignmentsData() async {
    print("Getting Ass Data");
    QuerySnapshot querySnapshot = await db
        .collection("Assignments")
        .where('userID', isEqualTo: widget.uid)
        .get();

    setState(() {
      assignmentData = querySnapshot.docs;
    });
  }

  Future<void> getCompletedData() async {
    print("Getting COMPAss Data");

    QuerySnapshot querySnapshot = await db
        .collection("Completed Assignments")
        .where('userID', isEqualTo: widget.uid)
        .get();

    setState(() {
      completedData = querySnapshot.docs;
    });
  }

  Future<void> getQuizesData() async {
    print("Getting Quizes Data");

    QuerySnapshot querySnapshot = await db
        .collection("Quizes")
        .where('userID', isEqualTo: widget.uid)
        .get();

    setState(() {
      quizesData = querySnapshot.docs;
    });
  }

  Future<void> getNotesData() async {
    print("Getting Notes Data");

    QuerySnapshot querySnapshot = await db
        .collection("Notes")
        .where('userID', isEqualTo: widget.uid)
        .get();

    setState(() {
      notesData = querySnapshot.docs;
    });
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
        title: Text(
          "Home",
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
              backgroundImage: userData != null &&
                      userData!['file'] != null &&
                      userData!['file'] != 'No image attached'
                  ? NetworkImage(userData!["file"]) as ImageProvider
                  : const AssetImage('assets/images/prof.jpg'),
              radius: 23,
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          children: [
            SizedBox(
              height: 250,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 229, 202, 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: userData != null &&
                              userData!['file'] != null &&
                              userData!['file'] != 'No image attached'
                          ? NetworkImage(userData!["file"]) as ImageProvider
                          : const AssetImage('assets/images/prof.jpg'),
                      radius: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      userData != null ? userData!['name'] : "N/A",
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      userData != null ? userData!['email'] : 'N/A',
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'User Info',
                    style: GoogleFonts.rajdhani(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return UserInfoScreen(
                        userID: widget.uid,
                        callback: getUserData,
                      );
                    },
                  ),
                );
                // Update the state of the app.
                // ...
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.exit_to_app),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.rajdhani(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.delete_forever),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Delete Account',
                    style: GoogleFonts.rajdhani(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Text(
                        'Delete your Account?',
                        style: GoogleFonts.rajdhani(
                          textStyle: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      content: Text(
                        '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.
''',
                        style: GoogleFonts.rajdhani(
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.rajdhani(
                              textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          onPressed: () {
                            deleteUserAccount();
                            Navigator.of(context).pop();

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Do not close the app!, you will be signed out automatically",
                                    style: GoogleFonts.rajdhani(
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.black,
                                        ),
                                      ]),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'Close Alert',
                                        style: GoogleFonts.rajdhani(
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            // Call the delete account function
                          },
                        ),
                      ],
                    );
                  },
                );
                // FirebaseAuth.instance.currentUser!.delete();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        childMargin: const EdgeInsets.all(20),
        activeIcon: Icons.arrow_back,
        backgroundColor: const Color.fromRGBO(250, 227, 203, 1),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.assessment),
            label: "Add Assignments",
            onTap: open2,
          ),
          SpeedDialChild(
            child: const Icon(Icons.assessment_outlined),
            label: "Add Completed assignments",
            onTap: openComp2,
          ),
          SpeedDialChild(
            child: const Icon(Icons.quiz),
            label: "Add Quizes",
            onTap: openQuiz2,
          ),
          SpeedDialChild(
            child: const Icon(Icons.note),
            label: "Add Notes",
            onTap: openNotes2,
          ),
        ],
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: 800,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 229, 202, 1),
          ),
          // padding: const EdgeInsets.all(12),
          child: StreamBuilder(
            stream: inst.getData(widget.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                List<Assignments> asses = snapshot.data!.docs
                    .map((document) => Assignments.fromSnapshot(document))
                    .toList();
                // print('snapshot ${user.uid}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                        surfaceTintColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 0, 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat.yMMMMd()
                                          .format(DateTime.now()),
                                      style: GoogleFonts.rajdhani(
                                        textStyle: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return DashboardMain(
                                                userID: widget.uid,
                                                list: asses,
                                                address: userData!['file'],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.arrow_forward),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    100, // Specify the desired height for the Dashboard
                                child: Dashboard(
                                  list: asses,
                                  id: widget.uid,
                                ), // Pass assignments list here
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
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
                    GestureDetector(
                      child: const Panels(
                        heading: "Assignments",
                        icon: Icons.assessment,
                        image: "assets/images/ass_illus.jpg",
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AssignmentsScreen(
                                  uid: widget.uid,
                                  imageADDRESS: userData!["file"]);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      child: const Panels(
                          heading: "Completed Assignments",
                          icon: Icons.assessment_outlined,
                          image: "assets/images/ass_illus.jpg"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ComletedScreen(
                                uid: widget.uid,
                                url: userData?["file"],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      child: const Panels(
                          heading: "Quizes",
                          icon: Icons.quiz_sharp,
                          image: "assets/images/quiz_illus.jpg"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return QuizesScreen(
                                uid: widget.uid,
                                url: userData?["file"],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      child: const Panels(
                          heading: "Notes",
                          icon: Icons.notes,
                          image: "assets/images/notes.jpg"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NotesScreen(
                                uid: widget.uid,
                                url: userData?["file"],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                );
              }
              return Column(
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
                      surfaceTintColor:
                          const Color.fromARGB(255, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 0, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat.yMMMMd().format(DateTime.now()),
                                    style: GoogleFonts.rajdhani(
                                      textStyle: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DashboardSecondary(
                                                userID: widget.uid,
                                                address: userData!["file"]);
                                          },
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                "No Assignments added!",
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
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
                  GestureDetector(
                    child: const Panels(
                        heading: "Assignments",
                        icon: Icons.assessment,
                        image: "assets/images/ass_illus.jpg"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AssignmentsScreen(
                              uid: widget.uid,
                              imageADDRESS: userData!["file"],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    child: const Panels(
                        heading: "Completed Assignments",
                        icon: Icons.assessment_outlined,
                        image: "assets/images/ass_illus.jpg"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ComletedScreen(
                              uid: widget.uid,
                              url: userData?["file"],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    child: const Panels(
                        heading: "Quizes",
                        icon: Icons.quiz_sharp,
                        image: "assets/images/quiz_illus.jpg"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return QuizesScreen(
                              uid: widget.uid,
                              url: userData?["file"],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    child: const Panels(
                        heading: "Notes",
                        icon: Icons.notes,
                        image: "assets/images/notes.jpg"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NotesScreen(
                              uid: widget.uid,
                              url: userData?["file"],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // bottomNavigationBar: _bannerAd == null
      //     ? Container()
      //     : Align(
      //         alignment: Alignment.bottomCenter,
      //         child: SafeArea(
      //           child: SizedBox(
      //             width: _bannerAd!.size.width.toDouble(),
      //             height: _bannerAd!.size.height.toDouble(),
      //             child: AdWidget(ad: _bannerAd!),
      //           ),
      //         ),
      //       ),
    );
  }
}
