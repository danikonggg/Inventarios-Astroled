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
  String? barcode;
  @override
  Future<ApiCallResponse> call(
      {String? codigoBarras = '', String? almacen = ''}) {
    calls++;
    barcode = codigoBarras;
    return response.future;
  }
}

class _Save extends GuardarArticuloCall {
  String? savedLot;
  int? quantity;
  String? barcode;
  Future<ApiCallResponse> call(
      {String? docCode = '',
      String? codigoArticulo = '',
      String? nombre = '',
      String? codigoBarras = '',
      int? cantidad,
      String? lote = '',
      String? almacenO = '',
      String? almacenD = '',
      String? usuario = '',
      String? tipoDocumento = '',
      int? unidad,
      double? precio,
      String? fecha = '',
      String? ubicacionO = '',
      String? ubicacionD = '',
      String? linea = ''}) async {
    savedLot = lote;
    quantity = cantidad;
    barcode = codigoBarras;
    return const ApiCallResponse({'success': true}, {}, 200);
  }
}

void main() {
  for (final scenario in [(2, 'LOTE-123'), (2, ''), (0, 'LOTE-123')]) {
    for (final continuous in [false, true]) {
      testWidgets(
          'Preserves barcode, quantity and lot (continuous=$continuous, scenario=$scenario)',
          (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        SharedPreferences.setMockInitialValues({});
        FFAppState.reset();
        await FFAppState().initializePersistedState();
        FFAppState().TipoDoc = scenario.$1;
        final original = WSInventariosGroup.leerCodigoBarrasCall;
        final reader = _Reader();
        final originalSave = WSInventariosGroup.guardarArticuloCall;
        final save = _Save();
        WSInventariosGroup.guardarArticuloCall = save;
        addTearDown(
            () => WSInventariosGroup.guardarArticuloCall = originalSave);
        WSInventariosGroup.leerCodigoBarrasCall = reader;
        addTearDown(() => WSInventariosGroup.leerCodigoBarrasCall = original);
        final Widget page = continuous
            ? const CapturaRapidaWidget(
                docEntry: 1,
                docInterno: '1',
                itemCode: '',
                nombreArticulo: '',
                cantidad: '',
                almacen: '01',
                precio: 0,
                fecha: '',
                fromButton: false)
            : const CapturaArticulosWidget(
                docEntry: 1,
                docInterno: '1',
                itemCode: '',
                nombreArticulo: '',
                cantidad: '',
                almacen: '01',
                precio: 0,
                fecha: '',
                fromButton: true);
        await tester.pumpWidget(ChangeNotifierProvider.value(
            value: FFAppState(), child: MaterialApp(home: page)));
        await tester.pumpAndSettle();
        final barcode = find.byWidgetPredicate(
            (w) => w is EditableText && w.onEditingComplete != null);
        expect(barcode, findsOneWidget);
        if (!continuous) {
          await tester.enterText(find.byType(EditableText).last, '7');
        }
        await tester.ensureVisible(barcode);
        await tester.tap(barcode);
        await tester.pump();
        expect(tester.testTextInput.isVisible, isTrue);
        await tester.enterText(barcode, 'PS-24100-D*100');
        final field = tester.widget<EditableText>(barcode);
        expect(field.keyboardType, TextInputType.text);
        expect(field.controller.text, 'PS-24100-D*100');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(field.focusNode.hasFocus, isTrue);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(reader.calls, 1);
        reader.response.complete(ApiCallResponse({
          'valores': {
            'itemCode': 'PS-24100-D',
            'itemName': 'Prueba',
            'unidad': 1,
            'loteSugerido': scenario.$2
          }
        }, {}, 200));
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(reader.barcode, 'PS-24100-D*100');
        if (!continuous) {
          expect(
              tester
                  .widget<EditableText>(find.byType(EditableText).last)
                  .controller
                  .text,
              '100');
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Capturar'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Capturar'));
          await tester.pumpAndSettle();
        }
        expect(save.savedLot, scenario.$1 == 2 ? scenario.$2 : '');
        expect(save.quantity, 100);
        expect(save.barcode, 'PS-24100-D*100');
        if (!continuous) {
          expect(
            tester.widgetList<EditableText>(find.byType(EditableText)).any(
                (field) => field.controller.text == 'Prueba'),
            isFalse,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
}
