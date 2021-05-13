import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/strings.i18n.dart';
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
      text: 'Calendar'.i18n,
    ),
    Tab(
      icon: Icon(Icons.work),
      text: 'Shifts'.i18n,
    ),
    Tab(
      icon: Icon(Icons.person),
      text: 'Profile'.i18n,
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
              text: 'Calendar'.i18n,
            ),
            Tab(
              icon: Icon(Icons.work),
              text: 'Shifts'.i18n,
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Friends'.i18n,
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Profile'.i18n,
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
