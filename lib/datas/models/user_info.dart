class UserInfo {
  String userId;
  String userName;
  String userAvatarUrl;
  String? userAccount;
  String? accessToken;
  String? refreshToken;
  String? userEmail;

  UserInfo({
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    this.userAccount,
    this.accessToken,
    this.refreshToken,
    this.userEmail,
  });

  UserInfo copyWith({
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? userAccount,
    String? accessToken,
    String? refreshToken,
    String? userEmail,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userAccount: userAccount ?? this.userAccount,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'userAccount': userAccount,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userEmail': userEmail,
    };
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      userAccount: json['userAccount'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  UserInfo.empty() : userId = '', userName = '', userAvatarUrl = '';
}
