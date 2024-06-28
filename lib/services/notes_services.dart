import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xasus__qore/models/notes.dart';
import 'package:xasus__qore/utilis/utilis.dart';

class NoteServices {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // * Add/create note

  Future addNote(
      {required String title,
      required String content,
      required BuildContext context}) async {
    Notes notes = Notes(
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    try {
      await firestore
          .collection("notes")
          .doc(auth.currentUser!.uid)
          .collection("user_notes")
          .add(notes.toMap())
          .then((value) {
        showSnackBar("Note added Successfully..", context);
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  // * Read note

  Future<QuerySnapshot<Map<String, dynamic>>> getNotes() async {
    QuerySnapshot<Map<String, dynamic>> snap = await firestore
        .collection("notes")
        .doc(auth.currentUser!.uid)
        .collection("user_notes")
        .orderBy("createdAt", descending: true)
        .get();
    return snap;
  }

  // * Update note

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
    required BuildContext context,
  }) async {
    try {
      await firestore
          .collection('notes')
          .doc(auth.currentUser!.uid)
          .collection('user_notes')
          .doc(noteId)
          .update({
        'title': title,
        'content': content,
      }).then((value) {
        showSnackBar("Note updated successfully.", context);
      }).catchError((error) {
        print("Failed to update user: $error");
      });
    } catch (e) {
      print("Error updating note: $e");
      throw Exception("Failed to update note.");
    }
  }

  //* Delete note

  Future deleteNote(String deletingNote) async {
    await firestore
        .collection("notes")
        .doc(auth.currentUser!.uid)
        .collection("user_notes")
        .doc(deletingNote)
        .delete();
  }

  // * Add to favourites

  Future addToFav(
      {required String title,
      required String content,
      required BuildContext context}) async {
    try {
      await firestore
          .collection("favourites")
          .doc(auth.currentUser!.uid)
          .collection("favs")
          .add({"title": title, "content": content}).then((value) {
        showSnackBar("Note added to favourites.", context);
      });
    } catch (e) {
      print("Error updating note: $e");
      throw Exception("Failed to update note.");
    }
  }

  // * remove from fav

  Future removeFromFav({
    required String title,
    required BuildContext context,
  }) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await firestore
            .collection("favourites")
            .doc(user.uid)
            .collection("favs")
            .where("title", isEqualTo: title)
            .get();

        // Assuming there is only one entry for each title,
        // we take the first document and delete it.
        if (snapshot.docs.isNotEmpty) {
          await firestore
              .collection("favourites")
              .doc(user.uid)
              .collection("favs")
              .doc(snapshot.docs.first.id)
              .delete()
              .then((value) {
            showSnackBar("Note removed from favourites.", context);
          });
        } else {
          print("No matching favorite found to remove.");
        }
      } else {
        throw Exception("User not logged in.");
      }
    } catch (e) {
      print("Error removing favorite: $e");
      throw Exception("Failed to remove favorite.");
    }
  }

  // * get from favourites

  Future<QuerySnapshot<Map<String, dynamic>>> getFavNotes() async {
    QuerySnapshot<Map<String, dynamic>> snap = await firestore
        .collection("favourites")
        .doc(auth.currentUser!.uid)
        .collection("favs")
        .get();
    return snap;
  }
}
