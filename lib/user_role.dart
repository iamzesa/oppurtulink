import 'package:flutter/foundation.dart';

class UserRole with ChangeNotifier {
  String _role = ''; // Initialize the role

  String get role => _role; // Getter for role

  void setRole(String newRole) {
    _role = newRole; // Update the private _role variable
    notifyListeners();
  }
}
