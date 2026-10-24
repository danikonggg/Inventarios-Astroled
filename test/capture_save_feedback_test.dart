import 'dart:convert';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';
import 'package:astroled_ofc/backend/api_requests/capture_save_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const description =
      'No hay más cantidad pendiente para el artículo B10000 en el documento base (ya se completó en todas sus líneas, o la cantidad escaneada excede lo que queda disponible).';
  const body = {
    'success': false,
    'error': true,
    'codigo': 410,
    'descripcion': description
  };
  test('Rejects HTTP and business errors', () {
    expect(captureSaveSucceeded(const ApiCallResponse(body, {}, 400)), isFalse);
    expect(captureSaveSucceeded(const ApiCallResponse(body, {}, 200)), isFalse);
    expect(captureSaveSucceeded(null), isFalse);
    expect(
        captureSaveSucceeded(
            const ApiCallResponse({'success': true, 'error': false}, {}, 200)),
        isTrue);
  });
  testWidgets('Shows full server description until acknowledged',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                      onPressed: () => showCaptureSaveError(
                          context, const ApiCallResponse(body, {}, 400)),
                      child: const Text('Guardar'),
                    )))));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);
    expect(find.text('Cantidad pendiente agotada o excedida'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text(description), findsOneWidget);
    expect(find.text('Cantidad pendiente agotada o excedida'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.text(description), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Preserves other rejection reasons from a JSON string',
      (tester) async {
    const reason =
        'El almacén seleccionado no está permitido para este documento.';
    final response = ApiCallResponse(
        jsonEncode({'success': false, 'descripcion': reason}), {}, 400);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showCaptureSaveError(context, response),
        child: const Text('Guardar'),
      ),
    ))));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text(reason), findsOneWidget);
    expect(find.text('Motivo del rechazo'), findsOneWidget);
    expect(captureSaveSucceeded(response), isFalse);
  });
}
