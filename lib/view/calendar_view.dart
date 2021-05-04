import 'dart:collection';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
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
    Shift(
        2,
        DateTime(2021, 6, 1),
        DateTime(2021, 6, 2),
        DateTime(2021, 6, 17),
        DateTime(2021, 6, 19),
        SyncStatus.SYNC
    )
  ];

  final unavailabilityStartDates = new LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );
  final unavailabilityEndDates = new LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );
  final boardingDates = new LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );
  final leavingDates = new LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );
  final unavailableDates = new LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );

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
    return Container(
      child: Scrollbar(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TableCalendar(
              calendarBuilders: CalendarBuilders(
                  prioritizedBuilder: (context, DateTime day, focusedDay) {
                    Color color = Colors.white;
                    if (unavailabilityStartDates.contains(day)) {
                      color =  Colors.amber;
                    } else if (boardingDates.contains(day)) {
                      color =  Colors.red;
                    } else if (unavailableDates.contains(day)) {
                      color =  Colors.grey;
                    } else if (unavailabilityEndDates.contains(day)) {
                      color =  Colors.cyan;
                    } else if (leavingDates.contains(day)) {
                      color =  Colors.greenAccent;
                    }
                    return Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(color: color),
                      child: Text(day.day.toString()),
                    );
                  }
              ),
              focusedDay: DateTime.now(),
              firstDay: DateTime.now().subtract(Duration(days: 2000)),
              lastDay: DateTime.now().add(Duration(days: 2000))
          ),
          SizedBox(height: 20,),
          FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                // TODO - addshifts
              }
          )

        ],
      ),
      )
    );
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

