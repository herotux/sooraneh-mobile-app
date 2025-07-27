import 'package:flutter/material.dart';
import 'package:daric/utils/log_service.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    final logs = LogService.getLogs();

    return MainScaffold(
      title: Text('لاگ‌ها'),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            setState(() {
              LogService.clear();
            });
          },
        ),
      ],

      body: logs.isEmpty
          ? Center(child: Text('لاگی وجود ندارد'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(logs[index]),
              ),
            ),
    );
  }
}
