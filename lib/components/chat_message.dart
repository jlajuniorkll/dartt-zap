import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, required this.data, required this.mine})
      : super(key: key);

  final Map<String, dynamic>? data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(data!['senderPhotoUrl'].toString())),
                )
              : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              data!['imgUrl'] != null
                  ? Image.network(
                      data!['imgUrl'],
                      width: 250,
                      height: 250,
                    )
                  : Text(
                      data!['text'],
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                      style: const TextStyle(fontSize: 16.0),
                    ),
              Text(
                data!['sender'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              mine
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(data!['senderPhotoUrl'].toString())),
                    )
                  : Container(),
            ],
          ))
        ],
      ),
    );
  }
}
