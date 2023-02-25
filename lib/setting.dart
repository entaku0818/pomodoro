import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SecondScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref)  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Column(
  children: <Widget>[
    Text('要素1'),
    Text('要素2'),
    ElevatedButton(
      child: Text('Go back'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ],
)
,
    );
  }
}

final countStateProvider = StateProvider<int>((ref) => 0);


_feachdata() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference user = firestore.collection('users').doc('user1');
  DocumentSnapshot documentSnapshot = await user.get();
  print(documentSnapshot.data());
}