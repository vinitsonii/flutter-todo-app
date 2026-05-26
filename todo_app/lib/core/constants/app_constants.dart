class AppConstants {
  // App Info
  static const String appName = 'TodoFlow';
  static const String appTagline = 'Get things done, beautifully.';

  // Categories
  static const List<String> categories = [
    'All',
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Other',
  ];

  // Firestore collections
  static const String usersCollection = 'users';
  static const String todosCollection = 'todos';

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);
}
