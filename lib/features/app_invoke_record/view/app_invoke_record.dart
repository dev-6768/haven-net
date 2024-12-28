import 'package:flutter/material.dart';

class AppInvokeRecordPage extends StatelessWidget {
  final List<dynamic> events;
  const AppInvokeRecordPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Activity', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amberAccent,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              DateTime timestamp = events[index];
              return InputDecorator(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                      labelText: "[background fetch event]"
                  ),
                  child: Text(timestamp.toString(), style: const TextStyle(color: Colors.grey, fontSize: 16.0))
              );
            }
        ),
      ),
    );
  }
}