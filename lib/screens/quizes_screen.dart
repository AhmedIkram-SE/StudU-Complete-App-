import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:prac_crud/screens/quiz_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prac_crud/models/quiz_card.dart';
import 'package:prac_crud/models/quizes.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:prac_crud/config.dart';

var inst = FireStoreService();
final FirebaseFirestore db = FirebaseFirestore.instance;

class QuizesScreen extends StatefulWidget {
  const QuizesScreen({
    super.key,
    required this.uid,
    required this.url,
  });

  final String? uid;
  final String? url;

  @override
  State<QuizesScreen> createState() => _QuizesScreenState();
}

class _QuizesScreenState extends State<QuizesScreen> {
  final TextEditingController title = TextEditingController();
  final TextEditingController subject = TextEditingController();
  final TextEditingController syllabus = TextEditingController();
  final TextEditingController edDate = TextEditingController();

  DateTime? date;
  Timestamp? fndate;
  DateTime? upDate;
  bool checker = false;
  bool isLoading = false;
  BannerAd? _bannerAd;
  BannerAd? _bannerAd1;

  bool _isLoaded = false;

  final formKey = GlobalKey<FormState>();
  final adUnitId = QuizScreenAdID1;
  final adUnitId1 = QuizScreenAdID2;

  Timestamp _dateTimeToTimestamp(DateTime? dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime!.millisecondsSinceEpoch);
  }

  DateTime _timestampToDateTime(Timestamp? dateTime) {
    return DateTime.fromMillisecondsSinceEpoch(
        dateTime!.millisecondsSinceEpoch);
  }

  @override
  void initState() {
    loadAd();
    loadAd1();
    super.initState();
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
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

  void loadAd1() {
    _bannerAd1 = BannerAd(
      adUnitId: adUnitId1,
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
    syllabus.clear();
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
        await FireStoreService().getOneQuiz(docID);

    if (document.exists) {
      Map<String, dynamic>? data = document.data();

      title.text = data?["title"];
      subject.text = data?['subject'];
      syllabus.text = data?["syllabus"];
      upDate = _timestampToDateTime(data?['date']);
      edDate.text = DateFormat.yMMMEd().format(upDate!);
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
                              "Update Quiz",
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
                                controller: syllabus,
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
                                    enabled: true,
                                    readOnly: true,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter the date";
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
                            Quiz updatedQuiz = Quiz(
                                title: title.text,
                                subject: subject.text,
                                syllabus: syllabus.text,
                                date: checker
                                    ? fndate
                                    : _dateTimeToTimestamp(upDate),
                                userID: widget.uid);

                            inst
                                .updatingQuiz(docID, updatedQuiz)
                                .whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Quiz Edited",
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
                                "Update Quiz",
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
    );
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
              backgroundImage:
                  widget.url != null && widget.url != "No image attached"
                      ? NetworkImage(widget.url!) as ImageProvider
                      : const AssetImage('assets/images/prof.jpg'),
              radius: 23,
            ),
          )
        ],
        title: Text(
          "Quizes",
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: inst.getDataQuiz(widget.uid),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(
          //       color: Colors.black,
          //     ),
          //   );
          // }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<Quiz> quizes = snapshot.data!.docs
                .map((document) => Quiz.fromSnapshot(document))
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
                      itemCount: quizes.length,
                      itemBuilder: (context, index) {
                        String id = snapshot.data!.docs[index].id;
                        return GestureDetector(
                          child: QuizCard(
                            list: quizes[index],
                            docID: id,
                            edit: (docID) {
                              edit(docID);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return QuizDetails(
                                    item: quizes[index],
                                    url: widget.url,
                                  );
                                },
                              ),
                            );
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

          return Container(
            padding: const EdgeInsets.all(40),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 229, 202, 1),
              image: DecorationImage(
                  image: AssetImage("assets/images/no_data.jpg"), opacity: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "No Quizes added!",
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
        },
      ),
    );
  }
}
