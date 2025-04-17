import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  final String message;
  final String timestamp;
  final Map<String, dynamic>? metadata;

  UserData({required this.message, required this.timestamp, this.metadata});

  Map<String, dynamic> toJson() {
    return {'message': message, 'timestamp': timestamp, 'metadata': metadata};
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      message: json['message'],
      timestamp: json['timestamp'],
      metadata: json['metadata'],
    );
  }
}

class UserDataService {
  static const String _storageKey = 'user_conversation_data';

  // Store a user message along with any metadata
  Future<void> storeUserMessage(
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = UserData(
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      metadata: metadata,
    );

    // Get existing data
    List<UserData> existingData = await getUserData();
    existingData.add(userData);

    // Convert to JSON and save
    final jsonDataList = existingData.map((data) => data.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonDataList));
  }

  // Get all stored user data
  Future<List<UserData>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => UserData.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing user data: $e');
      return [];
    }
  }

  // Clear all stored user data
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Export user data as JSON string
  Future<String> exportUserData() async {
    final userData = await getUserData();
    final jsonDataList = userData.map((data) => data.toJson()).toList();
    return jsonEncode(jsonDataList);
  }
}
