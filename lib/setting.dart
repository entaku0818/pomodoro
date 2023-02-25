import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomodoro/data/Pomodoro.dart';

class SecondScreen extends HookConsumerWidget {
  @override
  
  Widget build(BuildContext context, WidgetRef ref)  {
    final pomodoros = ref.watch(pomodorosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoros'),
      ),
      body: pomodoros.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final pomodoro = data[index];
              return ListTile(
                title: Text(pomodoro.type),
                subtitle: Text(pomodoro.time.toString()),
              );
            },
          );
        },
        loading: () {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('An error occurred while loading pomodoros'),
          );
        },
      ),
    );
  }
}


final FirebaseFirestore firestore = FirebaseFirestore.instance;

final pomodorosStream = firestore.collection('pomodoro').snapshots();
final pomodorosProvider = StreamProvider<List<Pomodoro>>(
  (ref) =>
    pomodorosStream.map(
      (querySnapshot) => querySnapshot.docs.map(
        (doc) => 
          Pomodoro.fromMap(doc.data())).toList()
      )
 
 );



