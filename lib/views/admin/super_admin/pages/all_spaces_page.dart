import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/dialogs/confirmation_dialog.dart';
import 'package:intrencity/widgets/smooth_container.dart';

class AllSpacesPage extends StatefulWidget {
  const AllSpacesPage({super.key});

  @override
  State<AllSpacesPage> createState() => _AllSpacesPageState();
}

class _AllSpacesPageState extends State<AllSpacesPage> {
  Stream<List<ParkingSpacePostModel>> getAllSpaces() {
    return FirebaseFirestore.instance.collection('spaces').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ParkingSpacePostModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> blackListSpace(String spaceId) async {
    await FirebaseFirestore.instance
        .collection('spaces')
        .doc(spaceId)
        .update({'isBlacklisted': true});
  }

  Future<void> deleteSpace(String spaceId) async {
    await FirebaseFirestore.instance.collection('spaces').doc(spaceId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaces'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: getAllSpaces(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final spaces = snapshot.data ?? [];
              if (spaces.isEmpty) {
                return const Center(child: Text('No Spaces Found'));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: spaces.length,
                itemBuilder: (context, index) {
                  final space = spaces[index];
                  return SmoothContainer(
                    height: 100,
                    color: textFieldGrey,
                    padding: const EdgeInsets.all(10),
                    contentPadding: const EdgeInsets.all(10),
                    onTap: () {
                      context.push(
                        '/parking-space-details',
                        extra: {
                          'spaceDetails': space,
                          'viewedByCurrentUser': false,
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Text(space.spaceName),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationDialog(
                                  title: 'Confirm Deletion',
                                  singleButtom: true,
                                  onTap: () {
                                    deleteSpace(space.docId!);
                                    context.pop();
                                  },
                                  buttonColor: redAccent,
                                  buttonLabel: 'Delete',
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: redAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
