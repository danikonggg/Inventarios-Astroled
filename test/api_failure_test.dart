import 'dart:async';
import 'package:astroled_ofc/app_state.dart';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';
import 'package:astroled_ofc/backend/api_requests/api_manager.dart';
import 'package:astroled_ofc/principal/principal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OpenDocuments extends DocumentosAbiertosCall {
  ApiCallResponse result = const ApiCallResponse([], {}, 200);
  int calls = 0;
  @override
  Future<ApiCallResponse> call({int? tipo, String? usuario = ''}) async {
    calls++;
    return result;
  }
}

void main() {
  test('HTTP and connection errors produce safe messages; empty JSON succeeds', () async {
    for (final status in [200, 401, 403, 404, 500, 502]) {
      final result = await ApiManager.instance.makeApiCall(
        callName: 'test', apiUrl: 'http://example.test/api', callType: ApiCallType.GET,
        client: MockClient((_) async => http.Response(status == 200 ? '[]' : '<html>proxy stack trace</html>', status)),
      );
      expect(result.hasFailure, status != 200);
      if (status != 200) expect(result.userMessage, isNot(contains('<html>')));
    }
    final result = await ApiManager.instance.makeApiCall(
      callName: 'save', apiUrl: 'http://example.test/api', callType: ApiCallType.POST,
      client: MockClient((_) async => throw http.ClientException('DNS internal details')),
    );
    expect(result.hasFailure, isTrue);
    expect(result.userMessage, contains('antes de repetirla'));
    expect(result.userMessage, isNot(contains('DNS internal')));
  });

  test('HTML with HTTP 200 is not accepted as a successful API call', () {
    final result = ApiCallResponse.fromHttpResponse(http.Response('<html>ngrok offline</html>', 200), true, false);
    expect(result.hasFailure, isTrue);
    expect(result.userMessage, contains('respuesta no válida'));
    expect(const ApiCallResponse({'success': false, 'descripcion': 'Cantidad excedida'}, {}, 200).userMessage, 'Cantidad excedida');
  });

  testWidgets('slow requests remain pending past 30 seconds', (tester) async {
    final gate = Completer<http.Response>();
    var completed = false;
    final request = ApiManager.instance.makeApiCall(
      callName: 'slow', apiUrl: 'http://example.test/api', callType: ApiCallType.GET,
      client: MockClient((_) => gate.future),
    ).then((result) { completed = true; return result; });
    await tester.pump(const Duration(minutes: 2));
    expect(completed, isFalse);
    gate.complete(http.Response('[]', 200));
    await tester.pump();
    expect((await request).succeeded, isTrue);
  });

  testWidgets('Documentos abiertos distinguishes empty, failed, malformed and retry', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    final api = _OpenDocuments();
    final original = WSInventariosGroup.documentosAbiertosCall;
    WSInventariosGroup.documentosAbiertosCall = api;
    addTearDown(() => WSInventariosGroup.documentosAbiertosCall = original);
    Future<void> mount() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(), child: const MaterialApp(home: PrincipalWidget())));
      await tester.pumpAndSettle();
    }
    await mount();
    expect(find.text('No hay documentos abiertos'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
    expect(tester.takeException(), isNull);

    api.result = const ApiCallResponse(null, {}, -1);
    await mount();
    expect(find.text('No hay documentos abiertos'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
    final previous = api.calls;
    api.result = const ApiCallResponse([], {}, 200);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(api.calls, greaterThan(previous));
    expect(find.text('No hay documentos abiertos'), findsOneWidget);

    api.result = const ApiCallResponse({'unexpected': 1}, {}, 200);
    await mount();
    expect(find.textContaining('lista válida'), findsOneWidget);
    expect(find.text('No hay documentos abiertos'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
