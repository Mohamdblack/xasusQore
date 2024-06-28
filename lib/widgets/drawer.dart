import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xasus__qore/screens/favourite_screen.dart';
import 'package:xasus__qore/services/auth_methods.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  AuthMethods authMethods = AuthMethods();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() {
    return authMethods.getUserInfo();
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 181, 245, 215),
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Icon(
                Icons.person_2,
                size: 70,
              ),
            ),
          ),
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // If there's an error, display an error message
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                Map<String, dynamic>? userData = snapshot.data!.data();
                String name = userData?['name'];
                String email = userData?['email'];
                return Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                );
              } else {
                return const Text("No data avalible !!!!");
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavouriteScreen(),
                ),
              );
            },
            leading: const Icon(Icons.favorite),
            title: const Text("Favourites"),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: InkWell(
                onTap: () {
                  authMethods.logout(context);
                },
                child: const Text("Logout")),
          ),
        ],
      ),
    );
  }
}
