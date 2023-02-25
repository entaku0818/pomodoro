




import 'package:cloud_firestore/cloud_firestore.dart';

class Pomodoro {
  DateTime createdAt;
  Timestamp serverTimestamp;
  int time;
  String type;
  DateTime updatedAt;
  String userId;

  Pomodoro({
    required this.createdAt,
    required this.serverTimestamp,
    required this.time,
    required this.type,
    required this.updatedAt,
    required this.userId,
  });



  factory Pomodoro.fromMap(Map<String, dynamic> data) {
    return Pomodoro(
      createdAt: (data['createdAt']).toDate(),
      serverTimestamp: data['serverTimestamp'],
      time: data['time'],
      type: data['type'],
      updatedAt: (data['updatedAt']).toDate(),
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'serverTimestamp': FieldValue.serverTimestamp(),
      'time': time,
      'type': type,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }
}




