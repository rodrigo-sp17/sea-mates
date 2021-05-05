import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/view/shift_add_view.dart';

import '../data/shift.dart';

class ShiftView extends StatefulWidget {
  ShiftView({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {
  final List<Shift> shifts = <Shift>[
    Shift(1, DateTime(2021, 5, 1), DateTime(2021, 5, 2), DateTime(2021, 5, 17),
        DateTime(2021, 5, 19), SyncStatus.UNSYNC),
    Shift(2, DateTime(2021, 6, 1), DateTime(2021, 6, 2), DateTime(2021, 6, 17),
        DateTime(2021, 6, 19), SyncStatus.SYNC)
  ];

  Set<int> selectedIds = <int>{};

  // AppBar state
  Widget leading;
  List<Widget> actions;
  String title = 'Shifts';

  @override
  void initState() {
    super.initState();
    actions = [];
    title = 'Shifts';
    leading = null;
  }

  void _resetAppBar() {
    setState(() {
      leading = null;
      actions = [];
      title = "Shifts";
    });
  }

  void _setActionMenu() {
    if (selectedIds.isEmpty) {
      _resetAppBar();
    } else {
      setState(() {
        leading = IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            selectedIds = <int>{};
            _resetAppBar();
          },
        );
        actions = [
          IconButton(icon: Icon(Icons.delete), onPressed: _deleteShifts)
        ];
        title = selectedIds.length.toString();
      });
    }
  }

  void _addShifts() {
    log('call add shifts dialog');
  }

  void _deleteShifts() {
    log("delete shifts");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  title: Text(title),
                  leading: leading,
                  actions: actions,
                  pinned: true,
                ),
                shifts.length > 0
                    ? SliverPadding(
                        padding: EdgeInsets.all(0),
                        sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, int index) {
                            var shift = shifts[index];
                            return ListTile(
                              title: Text(
                                DateFormat.yMMMd()
                                        .format(shift.unavailabilityStartDate) +
                                    " ~ " +
                                    DateFormat.yMMMd()
                                        .format(shift.unavailabilityEndDate),
                                textScaleFactor: 1.1,
                              ),
                              trailing:
                                  shifts[index].syncStatus == SyncStatus.UNSYNC
                                      ? Icon(Icons.hourglass_top)
                                      : Icon(Icons.check),
                              selected: selectedIds.contains(index),
                              selectedTileColor:
                                  Color.fromRGBO(200, 200, 200, 1),
                              onLongPress: () {
                                setState(() {
                                  selectedIds.contains(index)
                                      ? selectedIds.remove(index)
                                      : selectedIds.add(index);
                                  _setActionMenu();
                                });
                              },
                              onTap: () {
                                setState(() {
                                  selectedIds.remove(index);
                                  _setActionMenu();
                                });
                              },
                            );
                          }, childCount: shifts.length),
                        ),
                      )
                    : Center(child: Text("No shifts to display")),
              ],
            ),
            onRefresh: () {
              log('refreshed');
              return;
            }),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              // call shift dialog
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShiftAddView()));
            },
          ),
        )
      ],
    );
  }
}
