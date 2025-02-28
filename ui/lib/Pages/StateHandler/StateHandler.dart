import 'package:flutter/material.dart';

class StateHandler<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;

  const StateHandler({super.key, required this.snapshot, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData) {
      return Center(child: Text('No data found'));
    } else {
      return builder(snapshot.data as T);
    }
  }
}