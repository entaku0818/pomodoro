import 'package:flutter/material.dart';
import 'package:pomodoro/data/Pomodoro.dart';

class Graph extends StatelessWidget {
  final List<Pomodoro> pomodoloList;
  Graph({required this.pomodoloList});


  @override
  Widget build(BuildContext context) {
    final convertedData = convertData(pomodoloList);

   return ListView.builder(
            itemCount: convertedData.length,
            itemBuilder: (context, index) {
              final pomodoro = convertedData[index];
              return ListTile(
                title: Text(pomodoro.type),
                subtitle: Text(pomodoro.time.toString()),
              );
            },
          );
  }
  
  List<GraphPomodoro> convertData(List<Pomodoro> datas) {
    List<GraphPomodoro>  list = [];
    datas.forEach((data) {
      GraphPomodoro? result = list.firstWhere((element) => element.type == data.type, orElse: () => 
        GraphPomodoro(time: 0, type: "")
      );
        if (result != null && result.time > 0) {
          result.time = result.time + data.time;
        } else {
         
          list.add(
            GraphPomodoro(time:  data.time, type: data.type)
          );
        }
    });
    return list;
  }
}

class GraphPomodoro {
  int time;
  String type;

  GraphPomodoro({
    required this.time,
    required this.type,
  });
}