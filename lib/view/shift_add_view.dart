import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/model/shift_list_model.dart';

class ShiftAddView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a shift"),
      ),
      body: ShiftForm(),
    );
  }
}

class ShiftForm extends StatefulWidget {
  //const ShiftForm({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShiftFormState();
}

class _ShiftFormState extends State<StatefulWidget> {
  Shift _shift = Shift.empty();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late FocusNode _unStartDate,
      _boardDate,
      _leaveDate,
      _unEndDate,
      _cycleDays,
      _repeat;

  final _unStartDateController = new TextEditingController();
  final _boardDateController = new TextEditingController();
  final _leaveDateController = new TextEditingController();
  final _unEndDateController = new TextEditingController();
  final _cycleDaysController = new TextEditingController();
  final _repeatController = new TextEditingController();

  bool useCycle = false;

  @override
  void initState() {
    super.initState();
    _unStartDate = new FocusNode();
    _boardDate = new FocusNode();
    _leaveDate = new FocusNode();
    _unEndDate = new FocusNode();
    _cycleDays = new FocusNode();
    _repeat = new FocusNode();
    _repeatController.text = "0";

    _boardDateController.addListener(_handleBoardDateChange);
    _leaveDateController.addListener(_handleLeaveDateChange);
  }

  @override
  void dispose() {
    _unStartDate.dispose();
    _boardDate.dispose();
    _leaveDate.dispose();
    _unEndDate.dispose();
    _cycleDays.dispose();
    _repeat.dispose();
    _unStartDateController.dispose();
    _boardDateController.dispose();
    _leaveDateController.dispose();
    _unEndDateController.dispose();
    _cycleDaysController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  void _pickDate(TextEditingController ctrl) async {
    DateTime? selected = _parseDate(ctrl.text);
    if (selected == null) {
      selected = DateTime.now();
    }

    DateTime? result = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: selected.subtract(Duration(days: 1000)),
        lastDate: selected.add(Duration(days: 1000)));

    if (result != null) {
      setState(() {
        ctrl.text = DateFormat.yMd().format(result);
      });
    }
  }

  String? _validateUnStartDate(String? value) {
    if (value == null) {
      _unStartDateController.text = _boardDateController.text;
      return null;
    }

    DateTime? selected = _parseDate(value);
    DateTime? boarding = _parseDate(_boardDateController.text);
    if (selected == null) {
      return "Invalid date";
    }

    if (boarding == null) {
      return "Please check your boarding date";
    }

    if (selected.isAfter(boarding)) {
      return "Unavailability can't start after boarding date";
    }

    return null;
  }

  String? _validateBoardDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Boarding date is mandatory";
    }

    DateTime? selected = _parseDate(value);
    DateTime? leaving = _parseDate(_leaveDateController.text);
    if (selected == null) {
      return "Invalid date";
    }

    if (leaving == null) {
      return "Please check your leaving date";
    }

    if (selected.isAfter(leaving)) {
      return "You can't board after you leave";
    }

    return null;
  }

  String? _validateLeaveDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Leaving date is mandatory if cycle is not fulfilled";
    }

    DateTime? selected = _parseDate(value);
    DateTime? unEnd = _parseDate(_unEndDateController.text);

    if (selected == null) {
      return "Invalid date";
    }

    if (unEnd == null) {
      return "Please check your dates";
    }

    if (selected.isAfter(unEnd)) {
      return "You can't be available before you leave";
    }
  }

  String? _validateCycleDays(String? value) {
    if (value == null || value.isEmpty) {
      _cycleDaysController.text = "0";
      return null;
    }

    int? days = int.tryParse(value);
    if (days == null) {
      return "Are you sure you typed numbers?";
    } else if (days > 1000) {
      return "Isn't 3 years too much for a shift?";
    } else if (days < 0) {
      return "You can't have a negative cycle day";
    }

    return null;
  }

  String? _validateRepeat(String? value) {
    if (value == null || value.isEmpty) {
      _repeatController.text = '0';
      return null;
    }

    int cycles = int.parse(value);
    if (cycles > 10) {
      return "Sorry, only 10 repeats are allowed for each input";
    } else if (cycles < 0) {
      return "You can't have negative repeats";
    }

    return null;
  }

  void _handleBoardDateChange() {
    String value = _boardDateController.text;
    DateTime? unStart = _parseDate(_unStartDateController.text);
    if (unStart == null) {
      if (value.isNotEmpty) {
        setState(() {
          _unStartDateController.text = value;
        });
      }
    }

    if (!useCycle) {
      DateTime? boarding = _parseDate(value);
      DateTime? leaving = _parseDate(_leaveDateController.text);
      if (boarding != null && leaving != null) {
        var diff = leaving.difference(boarding);
        _cycleDaysController.text = diff.inDays.toString();
      }
    }
  }

  void _handleLeaveDateChange() {
    String value = _leaveDateController.text;
    DateTime? unEnd = _parseDate(_unEndDateController.text);
    if (unEnd == null) {
      if (value.isNotEmpty) {
        setState(() {
          _unEndDateController.text = value;
        });
      }
    }

    if (!useCycle) {
      DateTime? boarding = _parseDate(_boardDateController.text);
      DateTime? leaving = _parseDate(value);
      if (boarding != null && leaving != null) {
        var diff = leaving.difference(boarding);
        _cycleDaysController.text = diff.inDays.toString();
      }
    }
  }

  void _calculateCycle() {
    int? days = int.tryParse(_cycleDaysController.text);
    if (days != null) {
      DateTime? boarding = _parseDate(_boardDateController.text);
      DateTime? unStartDate = _parseDate(_unStartDateController.text);
      if (boarding != null) {
        DateTime leaving = boarding.add(Duration(days: days));
        DateTime unEnd = leaving;
        setState(() {
          _leaveDateController.text = DateFormat.yMd().format(leaving);
          _unEndDateController.text = DateFormat.yMd().format(unEnd);
        });
      }
    }
  }

  void _handleSubmit() async {
    // Submission logic, including decision about local vs remote saving
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      await Provider.of<ShiftListModel>(context, listen: false).add(_shift);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 10,
    );
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Scrollbar(
        child: ListView(
          padding: EdgeInsets.all(8),
          children: [
            SizedBox(
              height: 8,
            ),
            TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: _unStartDateController,
                focusNode: _unStartDate,
                readOnly: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.calendar_today),
                    labelText: "Start of unavailability",
                    helperText:
                        "Pre-boarding meetings, trainings, quarantines, etc..."),
                validator: _validateUnStartDate,
                onTap: () {
                  _pickDate(_unStartDateController);
                },
                onSaved: (value) {
                  _shift.unavailabilityStartDate = _parseDate(value)!;
                }),
            sizedBox,
            TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: _boardDateController,
                focusNode: _boardDate,
                readOnly: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.calendar_today),
                    labelText: "Boarding date",
                    helperText: "The date you will actually board the vehicle"),
                validator: _validateBoardDate,
                onTap: () {
                  _pickDate(_boardDateController);
                },
                onSaved: (value) {
                  _shift.boardingDate = _parseDate(value)!;
                }),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: Switch(
                  value: useCycle,
                  onChanged: (value) {
                    setState(() {
                      useCycle = value;
                    });
                  },
                )),
                Flexible(
                    flex: 2,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      textAlignVertical: TextAlignVertical.center,
                      controller: _cycleDaysController,
                      focusNode: _cycleDays,
                      enabled: useCycle,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 10),
                          labelText: "Days on board",
                          helperText: "These days will be added to your "
                              "dates"),
                      validator: _validateCycleDays,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (_) {
                        _calculateCycle();
                      },
                      onSaved: (value) {
                        _shift.cycleDays = int.parse(value!);
                      },
                    ))
              ],
            ),
            sizedBox,
            TextFormField(
                textAlignVertical: TextAlignVertical.center,
                enabled: !useCycle,
                controller: _leaveDateController,
                focusNode: _leaveDate,
                readOnly: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.calendar_today),
                    labelText: "Leaving date",
                    helperText: "The date you will actually leave the vehicle"),
                validator: _validateLeaveDate,
                onTap: () {
                  _pickDate(_leaveDateController);
                },
                onSaved: (value) {
                  _shift.leavingDate = _parseDate(value)!;
                }),
            sizedBox,
            TextFormField(
                textAlignVertical: TextAlignVertical.center,
                enabled: !useCycle,
                controller: _unEndDateController,
                focusNode: _unEndDate,
                readOnly: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.calendar_today),
                    labelText: "End of unavailability",
                    helperText:
                        "The date (exclusive) after leaving in which you will be available for events"),
                onTap: () {
                  _pickDate(_unEndDateController);
                },
                onSaved: (value) {
                  _shift.unavailabilityEndDate = _parseDate(value)!;
                }),
            sizedBox,
            TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: _repeatController,
                focusNode: _repeat,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.repeat),
                    labelText: "Times to repeat",
                    helperText: "Use 0 or blank to not repeat the shift",
                    suffixText: "x"),
                validator: _validateRepeat,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) {
                  _shift.repeat = int.parse(value!);
                }),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(
                  'Add shift',
                  textScaleFactor: 1.2,
                ))
          ],
        ),
      ),
    );
  }
}

DateTime? _parseDate(String? text) {
  if (text == null) return null;
  try {
    return DateFormat.yMd().parse(text);
  } on FormatException {
    return null;
  }
}
