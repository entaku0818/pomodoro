
import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:pomodoro/setting.dart';


/// A simple [StateNotifier] that implements a counter.
///
/// It doesn't have to be a [StateNotifier], and could be anything else such as:
/// - [ChangeNotifier], with [ChangeNotifierProvider]
/// - [Stream], with [StreamProvider]
/// ...



Future<void> _setupSession() async {
   _player = AudioPlayer();
   final session = await AudioSession.instance;
   await session.configure(const AudioSessionConfiguration.music());
   await _loadAudioFile();
}

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}
 
class TimerModel {
  const TimerModel(this.timeLeft, this.timeStatus,this.timeType,this.beforeTimeType);
  final String timeLeft;
  final TimeStatus timeStatus;
  final TimeType timeType; 
  final TimeType? beforeTimeType;
}
enum TimeStatus{
  init,
  started,
  paused,
  stoped
}

enum TimeType{
  work('仕事'), 
  subWork('副業'),
  myDevelopment('個人開発'),
  sleep('休憩'),
  ;
  
  const TimeType(this.displayName);

  final String displayName;
}


class PomodoloModel {
  const PomodoloModel(this.timerList);
  final List<TimerModel> timerList;
}
 
 
class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier() : super(_initialState);
 
  static const int _initialDuration = 10;
  static final _initialState = TimerModel(
    _durationString(_initialDuration),
    TimeStatus.init,
    TimeType.work,
    null
  );
 
 final Ticker _ticker = Ticker();
  StreamSubscription<int>? _tickerSubscription;
 
  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    print('$minutes:$seconds');
    return '$minutes:$seconds';
  }

  int workTime = 10;
  int breakTime = 10;

  void start() {
    _setupSession();
    if (state.timeStatus == TimeStatus.paused){
      _restartTimer();
    }else{
      _startTimer();
    }
  }
 
  void _restartTimer() {
    _tickerSubscription?.resume();
    state = TimerModel(state.timeLeft,TimeStatus.started,state.timeType,state.beforeTimeType);
  }
 
  void _startTimer() {
    _tickerSubscription?.cancel();
 
    _tickerSubscription =
        _ticker.tick(ticks: _initialDuration).listen((duration) {
      state = TimerModel(_durationString(duration),TimeStatus.started,state.timeType,state.beforeTimeType);

    });
 
    _tickerSubscription?.onDone(() {
      _player.play();


      if (state.timeType == TimeType.sleep.name){
        addtime(breakTime,state.timeType.name);
        state = TimerModel(state.timeLeft,TimeStatus.stoped,state.beforeTimeType!,TimeType.sleep);
      }else{
        addtime(workTime,state.timeType.name);
        state = TimerModel(state.timeLeft,TimeStatus.stoped,TimeType.sleep, state.timeType); 
      }
      _startTimer();
    });
 
    state = TimerModel(_durationString(_initialDuration),TimeStatus.started,state.timeType,state.beforeTimeType);
  }
 
  void pause() {
    _tickerSubscription?.pause();
    state = TimerModel(state.timeLeft,TimeStatus.paused,state.timeType,state.beforeTimeType);
  }

  void changeType(String type) {
    _tickerSubscription?.pause();
    state = TimerModel(state.timeLeft,state.timeStatus,state.timeType,state.beforeTimeType);

  }
 
  void reset() {
    _tickerSubscription?.cancel();
    state = _initialState;
  }

  void updateType(String type) {

    TimeType timeType = TimeType.values.firstWhere((e) => e.toString().split('.').last == type);

    state = TimerModel(state.timeLeft,state.timeStatus,timeType,state.beforeTimeType);
  }
 
  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(),
);
 
final _timeLeftProvider = Provider<String>((ref) {
  return ref.watch(timerProvider).timeLeft;
});
 
final timeLeftProvider = Provider<String>((ref) {
  return ref.watch(_timeLeftProvider);
});


class Pomodoro extends HookConsumerWidget {
  const Pomodoro({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLeft = ref.watch(timeLeftProvider);
    final state = ref.watch(timerProvider);
    
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand, 
        children: [
             Align(
                  alignment:
                   const Alignment(0, -0.2),
                  child: DropdownButton(
                  value: state.timeType.name,
                  items: const[
                    DropdownMenuItem(
                      value: 'work',
                      child: Text('仕事'),
                    ),
                    DropdownMenuItem(
                      value: 'subWork',
                      child: Text('副業'),
                    ),
                    DropdownMenuItem(
                        value: 'myDevelopment',
                        child: Text('個人開発'),
                    ),
                    DropdownMenuItem(
                      value: 'sleep',
                      child: Text('sleep'),
                    )

            ],
              onChanged: (String? value) {
                ref.read(timerProvider.notifier).updateType(value!);
              },
            ))
          ,
       
          Align(
            alignment: const Alignment(0, 0),
            child: Text(
          timeLeft,
          style: Theme.of(context).textTheme.headlineMedium,
        ) 
          )
      ,          const Align(
            alignment: Alignment(0, 0.3),
            child:TimeButtons()
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondScreen()),
                  );
              },
              child: Icon(Icons.bar_chart),
            ),
          ),
        ]
      ),
      
    ));
  }
}




class TimeButtons extends HookConsumerWidget {
  const TimeButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
 
    switch (state.timeStatus){
      
      case TimeStatus.init:
        return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).start(),
                  child: const Text('stert'),
               )
            ]
            );
      case TimeStatus.started:
        return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).pause(),
                  child: const Text('stop'),
                                    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red, // background
                    backgroundColor: Colors.white, // foreground
                  ),
               )
            ]
            );
      case TimeStatus.paused:
                return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).start(),
                  child: const Text('restart'),
               ),
                const SizedBox(width:20),
               ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).reset(),
                  child: const Text('reset'),
               ),
            ]
            );
      case TimeStatus.stoped:
                return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).start(),
                  child: const Text('stert'),
               ),
               const SizedBox(width:20),
               ElevatedButton(
                  onPressed: () => ref.read(timerProvider.notifier).pause(),
                  child: const Text('stop'),
               )
            ]
            );
    }
    
  }

}

late AudioPlayer _player;


Future<void> _loadAudioFile() async {
   try {

     await _player.setAudioSource(AudioSource.uri(Uri.parse(
          "https://www.nakano-sound.com/freedeta/%E3%83%95%E3%82%A1%E3%83%B3%E3%83%95%E3%82%A1%E3%83%BC%E3%83%AC10%EF%BC%88%E3%82%B2%E3%83%BC%E3%83%A0%E5%90%91%E3%81%91%EF%BC%89.mp3")));
   } catch(e) {
      print(e);
   }
}


addtime(int time,String type) {

  var uid = FirebaseAuth.instance.currentUser?.uid;
  FirebaseFirestore.instance
    .collection('pomodoro')
    .add(
      {
        'createdAt':DateTime.now(),
        // :TODO serverTimeStampにする！
        'serverTimestamp':DateTime.now(),
        'time': time,
        'updatedAt': DateTime.now(),
        'userId': uid,
        'type':type
      }
    );
}


