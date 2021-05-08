import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/shift_list_model.dart';
import 'package:sea_mates/view/shift_add_view.dart';

import '../data/shift.dart';

class ShiftView extends StatefulWidget {
  //ShiftView({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {
  // TODO - extract state to parent
  Set<int> selectedIndexes = <int>{};

  // AppBar state
  Widget? leading;
  List<Widget> actions = [];
  String title = 'Shifts';

  @override
  void initState() {
    super.initState();
    leading = null;
  }

  void _resetSelection() {
    setState(() {
      selectedIndexes = <int>{};
      _resetAppBar();
    });
  }

  void _resetAppBar() {
    setState(() {
      leading = null;
      actions = [];
      title = "Shifts";
    });
  }

  void _setActionMenu() {
    if (selectedIndexes.isEmpty) {
      _resetAppBar();
    } else {
      setState(() {
        leading = IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _resetSelection();
          },
        );
        actions = [
          IconButton(icon: Icon(Icons.delete), onPressed: _deleteShifts)
        ];
        title = selectedIndexes.length.toString();
      });
    }
  }

  void _deleteShifts() {
    _showSnackbar(context, "Deleting...", 1);
    var deleteResult = Provider.of<ShiftListModel>(context, listen: false)
        .remove(selectedIndexes);
    deleteResult.then((value) {
      _showSnackbar(context, "Deleted!", 1);
      _resetSelection();
    }, onError: (error) => _showSnackbar(context, error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () {
            return Provider.of<ShiftListModel>(context, listen: false)
                .syncShifts();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Text(title),
                leading: leading,
                actions: actions,
                pinned: true,
              ),
              Consumer<ShiftListModel>(builder: (context, model, child) {
                return FutureBuilder(
                    future: model.shifts,
                    builder: (context, AsyncSnapshot<List<Shift>> snapshot) {
                      if (snapshot.hasData) {
                        var shifts = snapshot.data!;
                        return SliverPadding(
                          padding: EdgeInsets.all(0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, int index) {
                              var shift = shifts[index];
                              return ListTile(
                                title: Text(
                                  DateFormat.yMMMd().format(
                                          shift.unavailabilityStartDate) +
                                      " ~ " +
                                      DateFormat.yMMMd()
                                          .format(shift.unavailabilityEndDate),
                                  textScaleFactor: 1.1,
                                ),
                                trailing: shifts[index].syncStatus ==
                                        SyncStatus.UNSYNC
                                    ? Icon(Icons.hourglass_top)
                                    : Icon(Icons.check),
                                selected: selectedIndexes.contains(index),
                                selectedTileColor:
                                    Color.fromRGBO(200, 200, 200, 1),
                                onLongPress: () {
                                  setState(() {
                                    selectedIndexes.contains(index)
                                        ? selectedIndexes.remove(index)
                                        : selectedIndexes.add(index);
                                    _setActionMenu();
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    selectedIndexes.remove(index);
                                    _setActionMenu();
                                  });
                                },
                              );
                            }, childCount: shifts.length),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                                "Oops...error loading shifts! Will handle soon!"),
                          ),
                        );
                      } else {
                        return SliverFillRemaining(
                            child: Center(
                          child: CircularProgressIndicator(),
                        ));
                      }
                    });
              }),
            ],
          ),
        ),
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

/// timeout in seconds
void _showSnackbar(BuildContext context, String message, [int timeout = 2]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: timeout),
  ));
}
