import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy(
              "created_at",
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text("No messages yet!"),
            );
          }
          final loadedMessages = chatSnapshots.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 40,
                left: 13,
                right: 13,
              ),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentUserId = chatMessage["user_id"];
                final nextUserId =
                    nextChatMessage != null ? nextChatMessage["user_id"] : null;
                final nextUserIsSame = nextUserId == currentUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage["text"],
                      isMe: authenticatedUser.uid == currentUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage["user_image"],
                      username: chatMessage["username"],
                      message: chatMessage["text"],
                      isMe: authenticatedUser.uid == currentUserId);
                }
              });
        });
  }
}
