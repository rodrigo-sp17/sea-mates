import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/repository/shifts_repository.dart';

class ShiftListModel extends ChangeNotifier {
  final ShiftsRepository shiftsRepository;

  List<Shift> _shifts;

  ShiftListModel(this.shiftsRepository, {List<Shift>? shifts})
      : _shifts = shifts ?? [];

  Future<UnmodifiableListView<Shift>> get shifts async =>
      UnmodifiableListView(_shifts);

  /// Syncs shifts
  /// To be called at app initialization and upon user request
  Future syncShifts() async {
    var localShifts = await shiftsRepository.loadLocal();
    var remoteShifts = await shiftsRepository.loadRemote();

    var unsyncedShifts = <Shift>[];
    localShifts.forEach((shift) {
      if (shift.syncStatus == SyncStatus.UNSYNC) {
        unsyncedShifts.add(shift);
      }
    });

    // Replaces local data for remote data
    await shiftsRepository.removeLocal(localShifts.map((s) => s.id!));
    await shiftsRepository.saveLocal(remoteShifts);

    // Adds pending shifts to the server
    List<Shift> added =
        await shiftsRepository.addRemote(unsyncedShifts).catchError((e) {
      // avoids losing the unsynced ones
      shiftsRepository.addLocal(unsyncedShifts);
      throw e;
    });

    await shiftsRepository.addLocal(added);
    _shifts = await shiftsRepository.loadLocal();
    notifyListeners();
  }

  /// Adds a new shift
  /// Syncs only upon user request
  Future<void> add(Shift shift) async {
    shift.syncStatus = SyncStatus.UNSYNC;
    var addedShift =
        await shiftsRepository.addLocal([shift]).then((value) => value.first);
    _shifts.add(addedShift);
    notifyListeners();
  }

  /// Removes a shift
  /// Syncs the deletion immediately
  Future<void> remove(Set<int> indexes) async {
    List<int> synced = [], unsynced = [];
    indexes.forEach((index) {
      var shift = _shifts.elementAt(index);
      int id = shift.id!;
      shift.syncStatus == SyncStatus.SYNC ? synced.add(id) : unsynced.add(id);
    });

    // for un-synced
    bool changed = false;
    if (unsynced.isNotEmpty) {
      await shiftsRepository.removeLocal(unsynced);
      changed = true;
    }

    if (synced.isNotEmpty) {
      await shiftsRepository.removeRemote(synced).catchError((e) => throw e);
      await shiftsRepository.removeLocal(synced);
      changed = true;
    }

    if (changed) {
      _shifts = await shiftsRepository.loadLocal();
      notifyListeners();
    }

    // for sync
    // if offline
    // return
    // attempt batch delete on security workflow
    // if false, check reason
    // if timeout, start offline workflow. return error timeout
    // if any other, display to the user, return error reason
    // if any deletion succeeds, notify
  }
}

class OperationException implements Exception {
  String message;
  OperationException(this.message);
}
