import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sea_mates/data/sync_status.dart';

import '../data/shift.dart';

class ShiftView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {
  final List<Shift> shifts = <Shift>[
    Shift(
        1,
        DateTime(2021, 5, 1),
        DateTime(2021, 5, 2),
        DateTime(2021, 5, 17),
        DateTime(2021, 5, 19),
        SyncStatus.UNSYNC
    ),
    Shift(
        2,
        DateTime(2021, 6, 1),
        DateTime(2021, 6, 2),
        DateTime(2021, 6, 17),
        DateTime(2021, 6, 19),
        SyncStatus.SYNC
    )
  ];

  final Set<int> selectedIds = <int>{};
  bool showActionMenu = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scrollbar(
            child: shifts.length > 0
            ? ListView.separated(
                padding: EdgeInsets.only(top: 5),
                itemCount: shifts.length,
                separatorBuilder: (_, index) => Divider(),
                itemBuilder: (context, int index) {
                  var shift = shifts[index];
                  return ListTile(
                    title:  Text(
                      DateFormat.yMMMd().format(shift.unavailabilityStartDate)
                          + " ~ "
                          + DateFormat.yMMMd().format(
                          shift.unavailabilityEndDate),
                      textScaleFactor: 1.1,
                    ),
                    trailing: shifts[index].syncStatus == SyncStatus.UNSYNC
                        ? Icon(Icons.hourglass_top)
                        : Icon(Icons.check)
                    ,
                    selected: selectedIds.contains(index),
                    selectedTileColor: Color.fromRGBO(200, 200, 200, 1),
                    onLongPress: (){
                      setState(() {
                        selectedIds.contains(index)
                            ? selectedIds.remove(index)
                            : selectedIds.add(index);
                        showActionMenu = selectedIds.isEmpty ? false : true;
                      });
                    },
                    onTap: (){
                      setState(() {
                        selectedIds.remove(index);
                        showActionMenu = selectedIds.isEmpty ? false : true;
                      });
                    },
                  );
                }
              )
            : Center(child: Text("No shifts"),)
        )
    );
  }
}
