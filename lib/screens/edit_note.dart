import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xasus__qore/services/notes_services.dart';

class EditNote extends StatefulWidget {
  const EditNote(
      {super.key,
      required this.title,
      required this.content,
      required this.documentId});

  final String title;
  final String content;
  final String documentId;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  NoteServices noteServices = NoteServices();

  bool isFavorited = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return noteServices.getNotes().asStream();
  }

  Future updateNote() async {
    return noteServices.updateNote(
        noteId: widget.documentId,
        title: titleController.text,
        content: contentController.text,
        context: context);
  }

  Future addToFav() async {
    try {
      await noteServices.addToFav(
          title: widget.title, content: widget.content, context: context);
      setState(() {
        isFavorited = true;
      });
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }

  void toggleFavorite() {
    if (isFavorited) {
      // Code to remove from favorites
      removeFromFav();
    } else {
      // Code to add to favorites
      addToFav();
    }
  }

  Future removeFromFav() async {
    try {
      // You need to implement this method in your noteServices
      await noteServices.removeFromFav(title: widget.title, context: context);
      setState(() {
        isFavorited = false; // Update the state
      });
    } catch (e) {
      print("Error removing from favorites: $e");
    }
  }

  @override
  void initState() {
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text("Edit Note"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: toggleFavorite,
              icon: Icon(isFavorited
                  ? Icons.favorite
                  : Icons.favorite_border_outlined),
              color: isFavorited ? Colors.red : null),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String choice) {
                if (choice == 'Save') {
                  String updatingDocId = widget.documentId;
                  noteServices
                      .updateNote(
                          noteId: updatingDocId,
                          title: titleController.text,
                          content: contentController.text,
                          context: context)
                      .then((_) {
                    Navigator.pop(context);
                    setState(() {
                      getNotes();
                    });
                  });
                } else if (choice == 'Delete') {
                  String deletingDocId = widget.documentId;
                  noteServices.deleteNote(deletingDocId).then((_) {
                    Navigator.pop(context);
                    setState(() {});
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Save',
                  child: ListTile(
                    leading: Icon(Icons.save),
                    title: Text('Save'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 30),
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    // border: Border.all(),
                    ),
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
