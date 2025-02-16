import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter/widgets.dart';
import 'package:prac_crud/screens/login.dart';
import 'package:prac_crud/screens/photoscreen.dart';
import 'package:prac_crud/services/firestoreservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

final ImagePicker picker = ImagePicker();
final inst = FireStoreService();
final CollectionReference users = db.collection("Users");

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({
    super.key,
    required this.userID,
    required this.callback,
  });

  final String? userID;
  final Function() callback;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController university = TextEditingController();
  final TextEditingController cgpa = TextEditingController();
  final TextEditingController currentSemester = TextEditingController();

  bool check = false;
  bool isLoading = false;
  String? delFileName;
  String? fAddrss;
  String? fName;
  bool secondCheck = false;
  bool thirdCheck = false;
  File? selectedImage;

  final formKey = GlobalKey<FormState>();

  Future<String> uploadImage(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child('images/$fileName.jpg');

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;
  }

  void callBack() {
    setState(() {});
  }

  void edit(String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FireStoreService().getOneUser(docID);

    if (document.exists) {
      Map<String, dynamic>? data = document.data();

      name.text = data?["name"];
      phoneNumber.text = data?['phoneNumber'];
      university.text = data?["university"];
      cgpa.text = data?['cgpa'];
      currentSemester.text = data?['currentSemester'];
      fAddrss = data?['file'];
      fName = data?['fileName'];
      if (fName != "N/A") {
        delFileName = fName;
      }

      if (fAddrss != "No image attached") {
        setState(() {
          print('Within first one');
          secondCheck = true;
          thirdCheck = true;
        });
      } else {
        setState(() {
          print('Within second one');
          secondCheck = false;
        });
      }
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
                centerTitle: true,
                title: Text(
                  "Edit Info",
                  style: GoogleFonts.rajdhani(
                    textStyle:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                  ),
                ),
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
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (secondCheck == false &&
                                        check == false) {
                                      print("The no image block");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "No Image Attached",
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
                                    }
                                    if (check == true) {
                                      print("Within check one");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PhotoViewer(
                                              condition: true,
                                              selectedImage: selectedImage,
                                            );
                                          },
                                        ),
                                      );
                                    } else if (thirdCheck == true) {
                                      print("Within not check one");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PhotoViewer(
                                              condition: false,
                                              address: fAddrss,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage: secondCheck && thirdCheck
                                        ? NetworkImage(fAddrss!)
                                            as ImageProvider
                                        : secondCheck
                                            ? FileImage(selectedImage!)
                                                as ImageProvider
                                            : const AssetImage(
                                                "assets/images/prof.jpg"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  onPressed: () async {
                                    final pickedFile = await ImagePicker()
                                        .pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 30);

                                    if (pickedFile != null) {
                                      String fileName = pickedFile.name;

                                      File file = File(pickedFile.path);

                                      //final downloadLink = await uploadPdf(fileName, file);

                                      // setState(() {});

                                      // print("$downloadLink");
                                      setState(() {
                                        check = true;
                                        selectedImage = file;
                                        print(
                                            "Second Check before = $secondCheck");
                                        print(
                                            "Third Check before = $thirdCheck");
                                        secondCheck = true;
                                        thirdCheck = false;
                                        print("Second Check: $secondCheck");
                                        print(
                                            "Third Check after = $thirdCheck");

                                        // address = downloadLink;
                                        fName = fileName;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Change Photo",
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
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Full Name",
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
                              controller: name,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "Name",
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
                              "Number",
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
                              controller: phoneNumber,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Number",
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
                              "Institution",
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
                              controller: university,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "University",
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
                              "CGPA / Grade",
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
                              controller: cgpa,
                              cursorColor: Colors.black,
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: const InputDecoration(
                                labelText: "CGPA / Grade",
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
                              "Semester / Term",
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
                              decoration: const InputDecoration(
                                labelText: "Semester / Term",
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
                              style: GoogleFonts.rajdhani(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              controller: currentSemester,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter the semester";
                                }
                              },
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
                            if (check!) {
                              final fileAddrss =
                                  await uploadImage(fName!, selectedImage!);
                              if (delFileName != null) {
                                final reference2 = FirebaseStorage.instance
                                    .ref()
                                    .child('images/$delFileName.jpg');
                                await reference2.delete();
                              }
                              setState(() {
                                fAddrss = fileAddrss;
                              });
                            }

                            Map<String, dynamic> data = {
                              'name': name.text,
                              'phoneNumber': phoneNumber.text,
                              'university': university.text,
                              'cgpa': cgpa.text,
                              'currentSemester': currentSemester.text,
                              'file': fAddrss,
                              'fileName': fName
                            };
                            users.doc(docID).update(data).whenComplete(() {
                              print("Within Update");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Info Updated",
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
                              widget.callback();
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
                                "Save Changes",
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
      setState(() {
        check = false;
        isLoading = false;
      });
    });
  }

  void empty() {
    name.clear();
    university.clear();
    cgpa.clear();
    currentSemester.clear();
    phoneNumber.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 206, 202, 202),
        ),
        elevation: 4,
        title: Text(
          "Info",
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // actions: [
        //   StreamBuilder(
        //     stream: inst.getDataUsers(widget.userID),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
        //         String docID = snapshot.data!.docs.first.id;

        //         return IconButton(
        //           onPressed: () {
        //             edit(docID);
        //           },
        //           icon: const Icon(Icons.edit),
        //         );
        //       }
        //       return const SizedBox();
        //     },
        //   )
        // ],
      ),
      backgroundColor: const Color.fromRGBO(255, 229, 202, 1),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder(
          stream: inst.getDataUsers(widget.userID),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var info = MediaQuery.of(context).orientation;
              var user = snapshot.data!.docs.first;
              String docID = user.id;
              var data = user.data() as Map<String, dynamic>;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 50, 15, 15),
                child: Column(
                  crossAxisAlignment: info == Orientation.portrait
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: info == Orientation.landscape
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: data['file'] != "No image attached"
                              ? NetworkImage(data['file']) as ImageProvider
                              : const AssetImage("assets/images/prof.jpg"),
                          radius: 60,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["name"],
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                data["email"],
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                overflow: TextOverflow.visible,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                data["phoneNumber"],
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            edit(docID);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                            fixedSize: Size(350, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            "Edit",
                            style: GoogleFonts.rajdhani(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            return;
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.graduationCap,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['university'],
                                style: GoogleFonts.rajdhani(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Details",
                      style: GoogleFonts.rajdhani(
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            return;
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.trophy,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "GRADE: ${data["cgpa"]}",
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 251, 233, 1),
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            return;
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.readme,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Semester: ${data["currentSemester"]}",
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   padding: const EdgeInsets.all(15),
                    //   child: Wrap(
                    //     direction: Axis.horizontal,
                    //     children: [
                    //       Text(
                    //         "Email: ",
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         data['email'],
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   padding: const EdgeInsets.all(15),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         'Phone Number:',
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         data['phoneNumber'],
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   padding: const EdgeInsets.all(15),
                    //   child: Wrap(
                    //     direction: Axis.horizontal,
                    //     children: [
                    //       Text(
                    //         'University:',
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         data['university'],
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   padding: const EdgeInsets.all(15),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         'CGPA: ',
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         data['cgpa'],
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.black),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   padding: const EdgeInsets.all(15),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         'Current Semester:',
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         data['currentSemester'],
                    //         style: GoogleFonts.rajdhani(
                    //           textStyle: const TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    const SizedBox(
                      height: 160,
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }
}
