import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({Key? key, required this.sendMessage}) : super(key: key);

  final Function({String text, File imgFile}) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final XFile? imagefile =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (imagefile == null) {
                return;
              } else {
                File imgfile = File(imagefile.path);
                widget.sendMessage(imgFile: imgfile);
              }
            },
            icon: const Icon(Icons.photo_camera),
          ),
          Expanded(
              child: TextField(
            controller: _controller,
            decoration: const InputDecoration.collapsed(
                hintText: "Escreva sua mensagem..."),
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.sendMessage(text: text);
              _clearTextField();
            },
          )),
          IconButton(
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    _clearTextField();
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _clearTextField() {
    setState(() {
      _controller.clear();
      _isComposing = false;
    });
  }
}
