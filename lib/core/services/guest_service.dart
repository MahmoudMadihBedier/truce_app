import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const String _guestActionKey = 'guest_actions_count';
  static const int maxGuestActions = 10;

  final SharedPreferences _prefs;

  GuestService(this._prefs);

  int get actionsCount => _prefs.getInt(_guestActionKey) ?? 0;

  Future<void> incrementAction() async {
    await _prefs.setInt(_guestActionKey, actionsCount + 1);
  }

  bool get isLimitReached => actionsCount >= maxGuestActions;

  Future<void> resetActions() async {
    await _prefs.remove(_guestActionKey);
  }
}
