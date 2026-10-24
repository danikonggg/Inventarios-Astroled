import 'dart:async';
import 'package:astroled_ofc/app_state.dart';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';
import 'package:astroled_ofc/captura_articulos/captura_articulos_widget.dart';
import 'package:astroled_ofc/captura_rapida/captura_rapida_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Reader extends LeerCodigoBarrasCall {
  final response = Completer<ApiCallResponse>();
  int calls = 0;
  @override
  Future<ApiCallResponse> call({String? codigoBarras = '', String? almacen = ''}) {
    calls++;
    return response.future;
  }
}

void main() {
  for (final continuous in [false, true]) {
    testWidgets('Scanner keeps focus while loading (continuous=$continuous)', (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      SharedPreferences.setMockInitialValues({});
      FFAppState.reset();
      await FFAppState().initializePersistedState();
      final original = WSInventariosGroup.leerCodigoBarrasCall;
      final reader = _Reader();
      WSInventariosGroup.leerCodigoBarrasCall = reader;
      addTearDown(() => WSInventariosGroup.leerCodigoBarrasCall = original);
      final Widget page = continuous
          ? const CapturaRapidaWidget(docEntry: 1, docInterno: '1', itemCode: '', nombreArticulo: '', cantidad: '', almacen: '01', precio: 0, fecha: '', fromButton: false)
          : const CapturaArticulosWidget(docEntry: 1, docInterno: '1', itemCode: '', nombreArticulo: '', cantidad: '', almacen: '01', precio: 0, fecha: '', fromButton: true);
      await tester.pumpWidget(ChangeNotifierProvider.value(value: FFAppState(), child: MaterialApp(home: page)));
      await tester.pumpAndSettle();
      final barcode = find.byWidgetPredicate((w) => w is EditableText && w.onEditingComplete != null);
      expect(barcode, findsOneWidget);
      await tester.ensureVisible(barcode);
      await tester.tap(barcode);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.enterText(barcode, '123456');
      final field = tester.widget<EditableText>(barcode);
      expect(field.keyboardType, TextInputType.text);
      expect(field.controller.text, '123456');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(field.focusNode.hasFocus, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(reader.calls, 1);
      reader.response.complete(const ApiCallResponse({'descripcion': 'No encontrado'}, {}, 404));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}