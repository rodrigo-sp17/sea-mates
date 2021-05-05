import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/view/shift_add_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarView> {
  final List<Shift> shifts = <Shift>[
    Shift(
      1,
      DateTime(2021, 5, 1),
      DateTime(2021, 5, 2),
      DateTime(2021, 5, 17),
      DateTime(2021, 5, 19),
      SyncStatus.SYNC,
    ),
    Shift(2, DateTime(2021, 6, 1), DateTime(2021, 6, 2), DateTime(2021, 6, 17),
        DateTime(2021, 6, 19), SyncStatus.SYNC)
  ];

  final unavailabilityStartDates =
      new LinkedHashSet<DateTime>(equals: isSameDay, hashCode: getHashCode);
  final unavailabilityEndDates =
      new LinkedHashSet<DateTime>(equals: isSameDay, hashCode: getHashCode);
  final boardingDates =
      new LinkedHashSet<DateTime>(equals: isSameDay, hashCode: getHashCode);
  final leavingDates =
      new LinkedHashSet<DateTime>(equals: isSameDay, hashCode: getHashCode);
  final unavailableDates =
      new LinkedHashSet<DateTime>(equals: isSameDay, hashCode: getHashCode);

  @override
  void initState() {
    super.initState();

    shifts.forEach((shift) {
      this.unavailabilityStartDates.add(shift.unavailabilityStartDate);
      this.unavailabilityEndDates.add(shift.unavailabilityEndDate);
      this.boardingDates.add(shift.boardingDate);
      this.leavingDates.add(shift.leavingDate);

      Duration diff = shift.leavingDate.difference(shift.boardingDate);
      while (diff.inDays > 0) {
        unavailableDates.add(shift.leavingDate.subtract(diff));
        diff = new Duration(days: diff.inDays - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text('Calendar'),
              pinned: true,
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, int index) {
              return TableCalendar(
                  calendarBuilders: CalendarBuilders(
                      prioritizedBuilder: (context, DateTime day, focusedDay) {
                    Color color = Colors.white;
                    if (unavailabilityStartDates.contains(day)) {
                      color = Colors.amber;
                    } else if (boardingDates.contains(day)) {
                      color = Colors.red;
                    } else if (unavailableDates.contains(day)) {
                      color = Colors.grey;
                    } else if (unavailabilityEndDates.contains(day)) {
                      color = Colors.cyan;
                    } else if (leavingDates.contains(day)) {
                      color = Colors.greenAccent;
                    }
                    return Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(color: color),
                      child: Text(day.day.toString()),
                    );
                  }),
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.now().subtract(Duration(days: 2000)),
                  lastDay: DateTime.now().add(Duration(days: 2000)));
            }, childCount: 1))
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            tooltip: "Shift",
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShiftAddView()));
            },
          ),
        )
      ],
    );
  }
}

int getHashCode(DateTime key) {
  int result = 17;
  result = 31 * result + key.day;
  result = 31 * result + key.month;
  result = 31 * result + key.year;
  return result;
}
