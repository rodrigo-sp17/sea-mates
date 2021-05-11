import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/shift_local_repository.dart';
import 'package:sea_mates/repository/shift_remote_repository.dart';

class ShiftListModel extends ChangeNotifier {
  final ShiftRemoteRepository _shiftRemoteRepository;
  final ShiftLocalRepository _shiftLocalRepository;
  late UserModel _userModel;

  List<Shift> _shifts;

  ShiftListModel(this._shiftRemoteRepository, this._shiftLocalRepository,
      {List<Shift>? shifts})
      : _shifts = shifts ?? [];

  ShiftListModel update(UserModel userModel) {
    this._userModel = userModel;
    return this;
  }

  Future<UnmodifiableListView<Shift>> get shifts async =>
      UnmodifiableListView(_shifts);

  /// Syncs shifts
  /// To be called at app initialization and upon user request
  Future syncShifts() async {
    if (!_userModel.hasAuthentication()) {
      return Future.error(
          "Synchronization is only possible when authenticated");
    }
    var token = _userModel.getToken();

    var localShifts = await _shiftLocalRepository.loadLocal();
    var remoteShifts = await _shiftRemoteRepository.loadRemote(token);

    var unsyncedShifts = <Shift>[];
    localShifts.forEach((shift) {
      if (shift.syncStatus == SyncStatus.UNSYNC) {
        unsyncedShifts.add(shift);
      }
    });

    // Replaces local data for remote data
    await _shiftLocalRepository.removeLocal(localShifts.map((s) => s.id!));
    await _shiftLocalRepository.saveLocal(remoteShifts);

    // Adds pending shifts to the server
    List<Shift> added = await _shiftRemoteRepository
        .addRemote(unsyncedShifts, token)
        .catchError((e) {
      // avoids losing the unsynced ones
      _shiftLocalRepository.addLocal(unsyncedShifts);
      throw e;
    });

    await _shiftLocalRepository.saveLocal(added);
    _shifts = await _shiftLocalRepository.loadLocal();
    notifyListeners();
  }

  /// Adds a new shift
  /// Syncs only upon user request
  /// WARNING: Mutates shift
  Future<void> add(Shift shift) async {
    shift.syncStatus = SyncStatus.UNSYNC;
    var shifts = _calculateRepetitions(shift);
    var addedShifts = await _shiftLocalRepository.addLocal(shifts);
    _shifts.addAll(addedShifts);
    notifyListeners();
  }

  /// Removes a shift
  /// Attempts remote deletions as soon as possible
  Future<void> remove(Set<int> indexes) async {
    var token = _userModel.getToken();
    List<int> synced = [], unsynced = [];
    indexes.forEach((index) {
      var shift = _shifts.elementAt(index);
      int id = shift.id!;
      shift.syncStatus == SyncStatus.SYNC ? synced.add(id) : unsynced.add(id);
    });

    // for un-synced
    if (unsynced.isNotEmpty) {
      await _shiftLocalRepository.removeLocal(unsynced);
      _shifts = await _shiftLocalRepository.loadLocal();
      notifyListeners();
    }

    // for synced - requires online access
    if (synced.isNotEmpty && _userModel.hasAuthentication()) {
      await _shiftRemoteRepository.removeRemote(synced, token).catchError((e) {
        throw Exception('Deletion failed! :(');
      });
      await _shiftLocalRepository.removeLocal(synced);
      _shifts = await _shiftLocalRepository.loadLocal();
      notifyListeners();
    }
  }

  Future<void> clearLocalDatabase() async {
    await _shiftLocalRepository.clear();
  }

  /// Calculates and returns the shifts representing the next cycles based upon
  /// the repeat property of Shift
  ///
  /// The repeat property of the original shift is mutated to 0 to avoid
  /// server duplications
  ///
  /// This method ignores the cycleDays properties - calculations are done based
  /// on available dates
  List<Shift> _calculateRepetitions(Shift shift) {
    int times = shift.repeat!;
    shift.repeat = 0;

    var result = [shift];
    if (times == 0) {
      return result;
    }

    var cycleDays = shift.leavingDate.difference(shift.boardingDate).inDays;
    var beforeDiff =
        shift.boardingDate.difference(shift.unavailabilityStartDate).inDays;
    var afterDiff =
        shift.unavailabilityEndDate.difference(shift.leavingDate).inDays;

    for (int i = 1; i <= times; i++) {
      var nextBoardingDate =
          shift.boardingDate.add(Duration(days: (i * 2 * cycleDays)));
      var nextLeavingDate =
          shift.leavingDate.add(Duration(days: (i * 2 * cycleDays)));
      var nextUnStartDate =
          nextBoardingDate.subtract(Duration(days: beforeDiff));
      var nextUnEndDate = nextLeavingDate.add(Duration(days: afterDiff));

      assert(!nextUnStartDate.isAfter(nextBoardingDate));
      assert(!nextLeavingDate.isBefore(nextBoardingDate));
      assert(!nextUnEndDate.isBefore(nextLeavingDate));

      result.add(new Shift(
          unavailabilityStartDate: nextUnStartDate,
          boardingDate: nextBoardingDate,
          leavingDate: nextLeavingDate,
          unavailabilityEndDate: nextUnEndDate,
          syncStatus: SyncStatus.UNSYNC));
    }

    return result;
  }
}
