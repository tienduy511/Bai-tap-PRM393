class MockAuthService {
  static const _fakeEmail = 'test@example.com';
  static const _fakePassword = '123456';

  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == _fakeEmail && password == _fakePassword) {
      return 'mock_token_abc123';
    }
    return null;
  }
}