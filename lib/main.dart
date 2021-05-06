import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/impl/shift_hive_repository.dart';
import 'package:sea_mates/repository/impl/shift_web_client.dart';
import 'package:sea_mates/repository/impl/user_hive_repo.dart';
import 'package:sea_mates/view/welcome.dart';

import 'model/shift_list_model.dart';

void main() async {
  await Hive.initFlutter("sea_mates");
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(SyncStatusAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserModel(UserHiveRepository()),
          ),
          ProxyProvider<UserModel, ShiftListModel>(
              update: (context, UserModel uModel, ShiftListModel sModel) =>
                  ShiftListModel(
                      ShiftWebClient(), ShiftHiveRepository(), uModel)),
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            home: WelcomePage()));
  }
}
