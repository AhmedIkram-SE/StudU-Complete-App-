import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prac_crud/models/assignments.dart';
import 'package:prac_crud/models/completed_assignments.dart';
import 'package:prac_crud/models/notes.dart';
import 'package:prac_crud/models/quizes.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
// final FirebaseAuth auth = FirebaseAuth.instance;

// final User user = auth.currentUser!;
// final uid = user.uid;

class FireStoreService {
  final CollectionReference assignments = db.collection("Assignments");
  final CollectionReference completed = db.collection("Completed Assignments");
  final CollectionReference quizes = db.collection("Quizes");
  final CollectionReference notes = db.collection("Notes");
  final CollectionReference users = db.collection("Users");

  //For Assignments
  Future<void> adding(Assignments assignment) {
    Map<String, dynamic> data = assignment.toMap();
    return assignments.add(data);
  }

  Stream<QuerySnapshot> getData(String? uid) {
    // print("In firestore uid is: $uid");
    final stream = assignments.where('userID', isEqualTo: uid).snapshots();
    return stream;
  }

  Future<void> updating(String docID, Assignments updatedObject) {
    Map<String, dynamic> data = updatedObject.toMap();

    return assignments.doc(docID).update(data);
  }

  Future<void> delete(String docID) {
    return assignments.doc(docID).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOne(String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection('Assignments').doc(docID).get();
    return document;
  }

// For Completed Assignments

  Future<void> addingComp(ComletedAssignments assignment) {
    Map<String, dynamic> data = assignment.toMap();
    return completed.add(data);
  }

  Stream<QuerySnapshot> getDataComp(String? uid) {
    // print("In firestore uid is: $uid");
    final stream = completed.where('userID', isEqualTo: uid).snapshots();
    return stream;
  }

  Future<void> updatingComp(String docID, ComletedAssignments updatedObject) {
    Map<String, dynamic> data = updatedObject.toMap();

    return completed.doc(docID).update(data);
  }

  Future<void> deleteComp(String docID) {
    return completed.doc(docID).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOneComp(
      String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection('Completed Assignments').doc(docID).get();
    return document;
  }

  Future<String> getCount(String? userID) async {
    AggregateQuery document = db
        .collection('Completed Assignments')
        .where('userID', isEqualTo: userID)
        .count();
    AggregateQuerySnapshot snapshot = await document.get();
    int? count = snapshot.count;
    return count.toString();
  }

//For Quizes

  Future<void> addingQuiz(Quiz assignment) {
    Map<String, dynamic> data = assignment.toMap();
    return quizes.add(data);
  }

  Stream<QuerySnapshot> getDataQuiz(String? uid) {
    // print("In firestore uid is: $uid");
    final stream = quizes.where('userID', isEqualTo: uid).snapshots();
    return stream;
  }

  Future<void> updatingQuiz(String docID, Quiz updatedObject) {
    Map<String, dynamic> data = updatedObject.toMap();

    return quizes.doc(docID).update(data);
  }

  Future<void> deleteQuiz(String docID) {
    return quizes.doc(docID).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOneQuiz(
      String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection('Quizes').doc(docID).get();
    return document;
  }

  Future<String> getCountQuizes(String? userID) async {
    AggregateQuery document =
        db.collection('Quizes').where('userID', isEqualTo: userID).count();
    AggregateQuerySnapshot snapshot = await document.get();
    int? count = snapshot.count;
    return count.toString();
  }

  //For Notes

  Future<void> addingNotes(Notes assignment) {
    Map<String, dynamic> data = assignment.toMap();
    return notes.add(data);
  }

  Stream<QuerySnapshot> getDataNotes(String? uid) {
    // print("In firestore uid is: $uid");
    final stream = notes.where('userID', isEqualTo: uid).snapshots();
    return stream;
  }

  Future<void> updatingNotes(String docID, Notes updatedObject) {
    Map<String, dynamic> data = updatedObject.toMap();

    return notes.doc(docID).update(data);
  }

  Future<void> deleteNotes(String docID) {
    return notes.doc(docID).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOneNote(
      String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection('Notes').doc(docID).get();
    return document;
  }

  Future<String> getCountNotes(String? userID) async {
    AggregateQuery document =
        db.collection('Notes').where('userID', isEqualTo: userID).count();
    AggregateQuerySnapshot snapshot = await document.get();
    int? count = snapshot.count;
    return count.toString();
  }

  //For Users
  Stream<QuerySnapshot> getDataUsers(String? uid) {
    // print("In firestore uid is: $uid");
    final stream = users.where('userID', isEqualTo: uid).snapshots();
    return stream;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOneUser(
      String docID) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection('Users').doc(docID).get();
    return document;
  }

  Future<void> deleteUser(String docID) {
    return users.doc(docID).delete();
  }
}
