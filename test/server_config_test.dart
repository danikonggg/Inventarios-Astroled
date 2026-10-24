import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:astroled_ofc/backend/api_requests/server_config.dart';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ServerConfig.initialize();
  });

  test('normalizes IP, root URL and custom API path', () {
    expect(ServerConfig.normalize(' 192.168.1.73:5123 '),
        'http://192.168.1.73:5123/api');
    expect(ServerConfig.normalize('https://example.com/'),
        'https://example.com/api');
    expect(ServerConfig.normalize('https://example.com/custom/api/'),
        'https://example.com/custom/api');
    for (final value in [
      '',
      'ftp://example.com',
      'https://',
      'http://a b',
      'https://user:pass@example.com',
      'https://example.com?a=1',
      'https://example.com/#foo',
      'http://example.com:99999'
    ]) {
      expect(() => ServerConfig.normalize(value), throwsFormatException);
    }
  });

  test('saved server survives initialization and is used by API group',
      () async {
    await ServerConfig.save('http://10.0.0.2:5123');
    await ServerConfig.initialize();
    expect(WSInventariosGroup.getBaseUrl(), 'http://10.0.0.2:5123/api');
    await expectLater(ServerConfig.save(''), throwsFormatException);
    expect(ServerConfig.baseUrl, 'http://10.0.0.2:5123/api');
    await ServerConfig.save(ServerConfig.defaultUrl);
    await ServerConfig.initialize();
    expect(ServerConfig.baseUrl, ServerConfig.defaultUrl);
  });

  test('invalid saved configuration falls back to original', () async {
    SharedPreferences.setMockInitialValues(
        {ServerConfig.preferenceKey: 'ftp://bad'});
    await ServerConfig.initialize();
    expect(ServerConfig.baseUrl, ServerConfig.defaultUrl);
  });

  test('probe uses candidate URL without changing saved server', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(),
          'http://10.0.0.3:5123/api/DocumentoEntrada/ObtenerUbicaciones');
      return http.Response('[]', 200);
    });
    expect(await ServerConfig.probe('10.0.0.3:5123', client: client),
        contains('Conexión correcta'));
    expect(ServerConfig.baseUrl, ServerConfig.defaultUrl);
  });

  test('probe rejects HTML and HTTP errors', () async {
    for (final response in [
      http.Response('<html>gateway</html>', 200),
      http.Response('{}', 404)
    ]) {
      await expectLater(
          ServerConfig.probe('localhost:5123',
              client: MockClient((_) async => response)),
          throwsFormatException);
    }
  });
}
