class User {
  final int userId;
  final String username;
  final String? displayName;
  final double totalScore;

  const User({
    required this.userId,
    required this.username,
    this.displayName,
    required this.totalScore,
  });
}
