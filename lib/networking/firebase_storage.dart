import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runo_notes/model/Notes.dart';
import 'package:runo_notes/model/SignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseStorage {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final Stream<QuerySnapshot> usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  final Stream<QuerySnapshot> notesStream =
      FirebaseFirestore.instance.collection('notes').snapshots();
  String? id;

  Future<String> addUser(SignUp signUp) async {
    final docRef = await users.add(signUp.toJson());
    return docRef.id;
  }

  Future<void> addNote(Notes note, String id) async {
    await FirebaseFirestore.instance.collection('notes').add(note.toJson());
  }

  Future<QuerySnapshot> getNotes(String id) async {
    final note = await FirebaseFirestore.instance
        .collection('notes')
        .where('id', isEqualTo: id)
        .get();
    return note;
  }

  Future<QuerySnapshot> searchNotes(String title) async {
    final note = await FirebaseFirestore.instance
        .collection('notes')
        .where('title', isGreaterThanOrEqualTo: title)
        .get();
    return note;
  }

  Future searchQuery(String searchString) async {
    return FirebaseFirestore.instance
        .collection('notes')
        .where('title', isGreaterThanOrEqualTo: searchString)
        .get();
  }

  addDataToSF(String name, String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(name, id);
  }

  Future<String> getIdValue(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    id = pref.getString(id)!;
    return id;
  }
}
