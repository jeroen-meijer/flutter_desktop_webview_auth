class AuthResult {
  final String? accessToken;
  final String? tokenType;
  final String? scope;
  final int? expiresIn;
  final String? refreshToken;
  final String? idToken;
  final String? tokenSecret;

  AuthResult({
    this.accessToken,
    this.tokenType,
    this.scope,
    this.expiresIn,
    this.refreshToken,
    this.idToken,
    this.tokenSecret,
  });

  @override
  String toString() {
    return 'AuthResult(idToken: $idToken, accessToken: $accessToken, tokenType: $tokenType, scope: $scope, expiresIn: $expiresIn, refreshToken: $refreshToken, tokenSecret: $tokenSecret)';
  }
}
