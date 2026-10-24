import 'dart:async';

import 'package:astroled_ofc/app_state.dart';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';
import 'package:astroled_ofc/traslados/captura_traslado_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Leer extends LeerCodigoBarrasCall {
  final result = Completer<ApiCallResponse>();
  String? origin;

  @override
  Future<ApiCallResponse> call(
      {String? codigoBarras = '', String? almacen = ''}) {
    origin = almacen;
    return result.future;
  }
}

class _Pendientes extends ArticulosPendientesCall {
  bool saved = false;

  @override
  Future<ApiCallResponse> call({String? docCode = ''}) async => ApiCallResponse(
        saved
            ? []
            : [
                {
                  'lineNum': 0,
                  'itemCode': 'ART-001',
                  'itemName': 'Artículo de prueba',
                  'cantidadPendiente': 2.0,
                  'almacenO': '01',
                  'almacenD': '02'
                },
              ],
        {},
        200,
      );
}

class _Guardar extends GuardarArticuloCall {
  _Guardar(this.pendientes);
  final _Pendientes pendientes;
  String? savedLine;
  String? savedCode;
  String? savedOrigin;
  String? savedDestination;
  String? savedLocationOrigin;
  String? savedLocationDestination;

  @override
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
    savedLine = linea;
    savedCode = codigoArticulo;
    savedOrigin = almacenO;
    savedDestination = almacenD;
    savedLocationOrigin = ubicacionO;
    savedLocationDestination = ubicacionD;
    pendientes.saved = true;
    return const ApiCallResponse({'error': false}, {}, 200);
  }
}

class _Capturados extends ObtenerArticulosCapturadosCall {
  @override
  Future<ApiCallResponse> call({String? docCode = ''}) async =>
      const ApiCallResponse({
        'valores': [
          {
            'codigoArticulo': 'ART-001',
            'nombre': 'Artículo de prueba',
            'cantidad': 2,
            'linea': 0,
            'almacenO': '01',
            'almacenD': '02',
            'lote': 'L-123',
            'ubicacionO': 'A-01',
            'ubicacionD': 'B-02'
          },
        ]
      }, {}, 200);
}

void main() {
  testWidgets(
      'Lista primero; captura el artículo elegido y actualiza al guardar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({'ff_modulosUsuario': 'TRA'});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    final originalPending = WSInventariosGroup.articulosPendientesCall;
    final originalSave = WSInventariosGroup.guardarArticuloCall;
    final originalReader = WSInventariosGroup.leerCodigoBarrasCall;
    final reader = _Leer();
    WSInventariosGroup.leerCodigoBarrasCall = reader;
    final originalCaptured = WSInventariosGroup.obtenerArticulosCapturadosCall;
    final pending = _Pendientes();
    final save = _Guardar(pending);
    WSInventariosGroup.articulosPendientesCall = pending;
    WSInventariosGroup.guardarArticuloCall = save;
    WSInventariosGroup.obtenerArticulosCapturadosCall = _Capturados();
    addTearDown(() {
      WSInventariosGroup.articulosPendientesCall = originalPending;
      WSInventariosGroup.guardarArticuloCall = originalSave;
      WSInventariosGroup.leerCodigoBarrasCall = originalReader;
      WSInventariosGroup.obtenerArticulosCapturadosCall = originalCaptured;
    });
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: const MaterialApp(
          home: CapturaTrasladoWidget(
              docCode: 'CAP-1', docEntry: 123, docNum: '456')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('ART-001'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Artículos capturados'), findsNothing);

    await tester.tap(find.byIcon(Icons.add_circle_outline_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Captura de artículo'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Almacén origen'), findsOneWidget);
    expect(find.text('Almacén destino'), findsOneWidget);
    expect(find.text('Lote'), findsNothing);
    expect(find.text('Ubicación origen'), findsOneWidget);
    expect(find.text('Ubicación destino'), findsOneWidget);

    // Back returns to the list without saving and allows selecting again.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(pending.saved, isFalse);
    await tester.tap(find.byIcon(Icons.add_circle_outline_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.enterText(find.byType(TextFormField).at(2), '03');
    await tester.enterText(find.byType(TextFormField).at(3), '04');
    await tester.enterText(find.byType(TextFormField).at(4), ' A-01 ');
    await tester.enterText(find.byType(TextFormField).at(5), ' B-02 ');
    await tester.enterText(find.byType(TextFormField).at(0), 'ART-001');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Buscar código'));
    await tester.tap(find.byTooltip('Buscar código'));
    await tester.pump();
    expect(find.text('Leyendo código...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(reader.origin, '03');
    reader.result.complete(const ApiCallResponse({
      'error': false,
      'valores': {'itemCode': 'ART-001', 'itemName': 'Artículo de prueba'}
    }, {}, 200));
    await tester.pumpAndSettle();
    expect(find.text('Leyendo código...'), findsNothing);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Capturar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capturar'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('No hay artículos pendientes'), findsOneWidget);
    expect(save.savedLine, '0');
    expect(save.savedCode, 'ART-001');
    expect(save.savedOrigin, '03');
    expect(save.savedDestination, '04');
    expect(save.savedLocationOrigin, 'A-01');
    expect(save.savedLocationDestination, 'B-02');
    // Processing can validate captures without first visiting their screen.
    await tester.ensureVisible(find.text('Generar transferencia en SAP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar transferencia en SAP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Confirmar y Procesar'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Artículos Capturados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Artículos Capturados'));
    await tester.pumpAndSettle();
    expect(find.text('Artículos pendientes'), findsNothing);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('ART-001'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Artículos pendientes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
