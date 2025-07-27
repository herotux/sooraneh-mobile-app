import 'package:flutter/material.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/dashboard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      title: 'دریک',
      body: DashboardWidget(),
    );
  }
}
