import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/view/calendar_view.dart';
import 'package:sea_mates/view/profile_view.dart';
import 'package:sea_mates/view/shift_view.dart';

import 'friend_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> offlineChildren = [CalendarView(), ShiftView(), ProfileView()];
  List<Widget> offlineTabs = [
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
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) {
        List<Widget> children = [];
        List<Widget> tabs = [];

        if (model.hasAuthentication()) {
          children = [CalendarView(), ShiftView(), FriendView(), ProfileView()];
          tabs = [
            Tab(
              icon: Icon(Icons.today),
              text: 'Calendar',
            ),
            Tab(
              icon: Icon(Icons.work),
              text: 'Shifts',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Friends',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Profile',
            )
          ];
        } else {
          children = offlineChildren;
          tabs = offlineTabs;
        }

        return DefaultTabController(
          length: children.length,
          child: Scaffold(
            bottomNavigationBar: TabBar(
                labelColor: Colors.blue,
                indicatorColor: Colors.blue,
                tabs: tabs),
            body: TabBarView(
              children: children,
            ),
          ),
        );
      },
    );
  }
}
