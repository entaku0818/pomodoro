
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


/// A simple [StateNotifier] that implements a counter.
///
/// It doesn't have to be a [StateNotifier], and could be anything else such as:
/// - [ChangeNotifier], with [ChangeNotifierProvider]
/// - [Stream], with [StreamProvider]
/// ...

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}
 
class TimerModel {
  const TimerModel(this.timeLeft, this.timeStatus);
  final String timeLeft;
  final TimeStatus timeStatus;

}
enum TimeStatus{
  init,
  started,
  paused,
  stoped
}

class PomodoloModel {
  const PomodoloModel(this.timerList);
  final List<TimerModel> timerList;
}
 
 
class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier() : super(_initialState);
 
  static const int _initialDuration = 1500;
  static final _initialState = TimerModel(
    _durationString(_initialDuration),
    TimeStatus.init
  );
 
 final Ticker _ticker = Ticker();
  StreamSubscription<int>? _tickerSubscription;
 
  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
 
  void start() {
    if (state.timeStatus == TimeStatus.paused){
      _restartTimer();
    }else{
      _startTimer();
    }
  }
 
  void _restartTimer() {
    _tickerSubscription?.resume();
    state = TimerModel(state.timeLeft,TimeStatus.started);
  }
 
  void _startTimer() {
    _tickerSubscription?.cancel();
 
    _tickerSubscription =
        _ticker.tick(ticks: _initialDuration).listen((duration) {
      state = TimerModel(_durationString(duration),TimeStatus.started);
    });
 
    _tickerSubscription?.onDone(() {
      state = TimerModel(state.timeLeft,TimeStatus.stoped);
    });
 
    state = TimerModel(_durationString(_initialDuration),TimeStatus.started);
  }
 
  void pause() {
    _tickerSubscription?.pause();
    state = TimerModel(state.timeLeft,TimeStatus.paused);
  }
 
  void reset() {
    _tickerSubscription?.cancel();
    state = _initialState;
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

    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand, 
        children: [
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
          )
        
        ]
      )
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