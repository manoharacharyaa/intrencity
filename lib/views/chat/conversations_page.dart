import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final conversation = snapshot.data!.docs[index];
              final participants =
                  List<String>.from(conversation['participants']);
              final otherUserId =
                  participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'Unknown User';

                  return SmoothContainer(
                    height: 70,
                    contentPadding: const EdgeInsets.all(10),
                    onTap: () => context.push(
                      '/chat',
                      extra: {
                        'receiverId': otherUserId,
                        'receiverName': userName,
                      },
                    ),
                    color: textFieldGrey,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      spacing: 16,
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryBlue,
                          backgroundImage: userData['profilePic'] != null
                              ? NetworkImage(userData['profilePic'])
                              : null,
                          child: userData['profilePic'] == null
                              ? Text(
                                  userName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        Text(userName),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
