import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xasus__qore/screens/edit_note.dart';
import 'package:xasus__qore/services/notes_services.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  NoteServices noteServices = NoteServices();

  Stream<QuerySnapshot<Map<String, dynamic>>> getFavNotes() {
    return noteServices.getFavNotes().asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getFavNotes(),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No  Fav Notes Availible Add New One 📒",
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final notesData = snapshot.data!.docs[index];

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
                            color: const Color.fromARGB(255, 108, 171, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const Row(
                                children: [
                                  Icon(
                                    Icons.watch_later_outlined,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
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
    );
  }
}
