import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartt_zap/components/chat_message.dart';
import 'package:dartt_zap/components/text_composer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null
            ? "Olá, ${_currentUser!.displayName}"
            : 'DarttZap'),
        elevation: 0,
        centerTitle: true,
        actions: [
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Você saiu com sucesso!")));
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                  ))
              : Container(),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot<Map<String, dynamic>>?> documents =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessage(
                              data: documents[index]!.data(),
                              mine: documents[index]!.get('uid') ==
                                  _currentUser?.uid);
                        });
                }
              },
            )),
            _isLoading ? const LinearProgressIndicator() : Container(),
            TextComposer(sendMessage: _sendMessage)
          ],
        ),
      ),
    );
  }

  void _sendMessage({String? text, File? imgFile}) async {
    final user = await _getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Não foi possível fazer o login. Tente novamente!")));
    }

    Map<String, dynamic> data = {
      "uid": user!.uid,
      "sender": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
    };
    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid)
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      setState(() {
        _isLoading = true;
      });
      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data['text'] = text;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("messages").doc().set(data);
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication!.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }
}
