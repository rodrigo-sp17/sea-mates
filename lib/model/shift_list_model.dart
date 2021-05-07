import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/shift_local_repository.dart';
import 'package:sea_mates/repository/shift_remote_repository.dart';

class ShiftListModel extends ChangeNotifier {
  final ShiftRemoteRepository shiftRemoteRepository;
  final ShiftLocalRepository shiftLocalRepository;
  late UserModel userModel;

  List<Shift> _shifts;

  ShiftListModel(this.shiftRemoteRepository, this.shiftLocalRepository,
      {List<Shift>? shifts})
      : _shifts = shifts ?? [];

  ShiftListModel update(UserModel userModel) {
    this.userModel = userModel;
    return this;
  }

  Future<UnmodifiableListView<Shift>> get shifts async =>
      UnmodifiableListView(_shifts);

  /// Syncs shifts
  /// To be called at app initialization and upon user request
  Future syncShifts() async {
    if (!userModel.hasAuthentication()) {
      return Future.error(
          "Synchronization is only possible when authenticated");
    }
    var token = userModel.getToken();

    var localShifts = await shiftLocalRepository.loadLocal();
    var remoteShifts = await shiftRemoteRepository.loadRemote(token);

    var unsyncedShifts = <Shift>[];
    localShifts.forEach((shift) {
      if (shift.syncStatus == SyncStatus.UNSYNC) {
        unsyncedShifts.add(shift);
      }
    });

    // Replaces local data for remote data
    await shiftLocalRepository.removeLocal(localShifts.map((s) => s.id!));
    await shiftLocalRepository.saveLocal(remoteShifts);

    // Adds pending shifts to the server
    List<Shift> added = await shiftRemoteRepository
        .addRemote(unsyncedShifts, token)
        .catchError((e) {
      // avoids losing the unsynced ones
      shiftLocalRepository.addLocal(unsyncedShifts);
      throw e;
    });

    await shiftLocalRepository.addLocal(added);
    _shifts = await shiftLocalRepository.loadLocal();
    notifyListeners();
  }

  /// Adds a new shift
  /// Syncs only upon user request
  Future<void> add(Shift shift) async {
    shift.syncStatus = SyncStatus.UNSYNC;
    var addedShift = await shiftLocalRepository
        .addLocal([shift]).then((value) => value.first);
    _shifts.add(addedShift);
    notifyListeners();
  }

  /// Removes a shift
  /// Attempts remote deletions as soon as possible
  Future<void> remove(Set<int> indexes) async {
    var token = userModel.getToken();
    List<int> synced = [], unsynced = [];
    indexes.forEach((index) {
      var shift = _shifts.elementAt(index);
      int id = shift.id!;
      shift.syncStatus == SyncStatus.SYNC ? synced.add(id) : unsynced.add(id);
    });

    // for un-synced
    if (unsynced.isNotEmpty) {
      await shiftLocalRepository.removeLocal(unsynced);
      _shifts = await shiftLocalRepository.loadLocal();
      notifyListeners();
    }

    // for synced - requires online access
    if (synced.isNotEmpty && userModel.hasAuthentication()) {
      await shiftRemoteRepository
          .removeRemote(synced, token)
          .catchError((e) => throw e);
      await shiftLocalRepository.removeLocal(synced);
      _shifts = await shiftLocalRepository.loadLocal();
      notifyListeners();
    }
  }

  Future<void> clearLocalDatabase() async {
    await shiftLocalRepository.clear();
  }
}
