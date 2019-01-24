import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CrashView extends StatelessWidget {
  final String message;
  final String stacktrace;

  CrashView(this.message, this.stacktrace);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Application Crash"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Whoops, this should not have happened...",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "The error has been reported to the developer. For reference, the error that occurred is displayed below.",
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("The following error has occurred:"),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 12),
                      child: Text("Error:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Container(child: Text(message ?? 'NONE'))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("Stacktrace:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.grey.shade800,
                  child: Text(
                    stacktrace ?? 'NONE',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
