import 'package:flutter/material.dart';
import 'package:sea_mates/view/calendar_view.dart';
import 'package:sea_mates/view/profile_view.dart';
import 'package:sea_mates/view/shift_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: TabBar(
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                icon: Icon(Icons.today),
                text: 'Calendar',
              ),
              Tab(
                icon: Icon(Icons.work),
                text: 'Shifts',
              ),
              Tab(
                icon: Icon(Icons.person),
                text: 'Profile',
              )
            ],
          ),
          body: TabBarView(
            children: [CalendarView(), ShiftView(), ProfileView()],
          ),
        ));
  }
}
