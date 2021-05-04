import 'package:flutter/material.dart';
import 'package:sea_mates/view/calendar_view.dart';
import 'package:sea_mates/view/shift_view.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
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
            ],
          ),
          body: TabBarView(
            children: [
              CalendarView(),
              ShiftView()
            ],
          ),
        )
    );
  }

}