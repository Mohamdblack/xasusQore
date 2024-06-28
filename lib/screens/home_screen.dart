import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xasus__qore/screens/edit_note.dart';
import 'package:xasus__qore/services/notes_services.dart';

import '../widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  NoteServices noteServices = NoteServices();

  bool isClicked = false;
  var searchTitle = "";

  Future addNote() {
    return noteServices.addNote(
        title: titleController.text,
        content: contentController.text,
        context: context);
  }

  Future<void> _refreshNotes() async {
    // Fetch and update the notes here
    await noteServices.getNotes();
    setState(() {});
    // Add any additional logic you need after refreshing the notes
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noteServices.getNotes();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return noteServices.getNotes().asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isClicked
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(hintText: "Search a note"),
                onChanged: (value) {
                  setState(() {
                    searchTitle = value;
                  });
                },
              )
            : const Text("xasusQore"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  isClicked = !isClicked;
                });
              },
              child: const Icon(
                Icons.search_rounded,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      drawer: const Drawer(
        child: CustomDrawer(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        child: SafeArea(
          child: isClicked
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("notes")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("user_notes")
                      .where("title",
                          isGreaterThanOrEqualTo: searchController.text)
                      .where("title",
                          isLessThanOrEqualTo: '${searchController.text}\uf8ff')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      // If there's an error, display an error message
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No note found!!",
                                style:
                                    TextStyle(fontSize: 18, color: Colors.red)),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var searchedData = snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: ListTile(
                                  onTap: () {
                                    String documentId = searchedData.id;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditNote(
                                          title: searchedData['title'],
                                          content: searchedData['content'],
                                          documentId: documentId,
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(searchedData['title'].toString()),
                                  subtitle:
                                      Text(searchedData['content'].toString()),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      return const Text("No data avalible !!!!");
                    }
                  },
                )
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: getNotes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              // If there's an error, display an error message
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData) {
                              if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "No Notes Availible Add New One 📒",
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Image.asset("assets/nonote.jpg"),
                                    ],
                                  ),
                                );
                              } else {
                                return GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final notesData =
                                        snapshot.data!.docs[index];
                                    int createdAtTimestamp =
                                        notesData['createdAt'];
                                    DateTime createdAtDate =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            createdAtTimestamp);

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          String documentId = notesData.id;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditNote(
                                                title: notesData['title'],
                                                content: notesData['content'],
                                                documentId: documentId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          // width: 300,
                                          // height: 300,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 96, 255, 181),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notesData['title'],
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Divider(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                notesData['content'],
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                maxLines: 2,
                                              ),
                                              const Spacer(),
                                              const Divider(),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.watch_later_outlined,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                            'yyyy-MM-dd HH:mm')
                                                        .format(createdAtDate
                                                            .toLocal()),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              return const Text("No data avalible !!!!");
                            }
                          }),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5693BF),
        onPressed: () {
          showDialog<void>(
            context: context,
            // barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add a note 📒'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / .10,
                    child: ListBody(
                      children: <Widget>[
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "title...",
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "content...",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      addNote();
                      Navigator.pop(context);
                      setState(() {
                        getNotes();
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
