import 'dart:async';
import 'dart:convert';
import 'package:astroled_ofc/app_state.dart';
import 'package:astroled_ofc/backend/api_requests/api_calls.dart';
import 'package:astroled_ofc/conteos/nuevo_conteo_widget.dart';
import 'package:astroled_ofc/conteos/captura_conteo_widget.dart';
import 'package:astroled_ofc/conteos/conteo_data.dart';
import 'package:astroled_ofc/principal/principal_widget.dart';
import 'package:astroled_ofc/captura_entrada/captura_entrada_widget.dart';
import 'package:astroled_ofc/captura_articulos/captura_articulos_widget.dart';
import 'package:astroled_ofc/captura_rapida/captura_rapida_widget.dart';
import 'package:astroled_ofc/articulos_capturados/articulos_capturados_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:astroled_ofc/flutter_flow/nav/nav.dart' as app_nav;
import 'package:astroled_ofc/flutter_flow/flutter_flow_widgets.dart';
import 'package:astroled_ofc/auth/custom_auth/custom_auth_user_provider.dart';

class _Server {
  final requests = <http.Request>[];
  Completer<void>? saveGate;
  Completer<void>? processGate;
  bool processSuccess = false;
  bool saveSuccess = true;
  bool openConteo = false;
  bool missingInternal = false;
  bool duplicateItem = false;
  String lookupItemCode = 'ART001';
  int total = 0;
  int get saves =>
      requests.where((r) => r.url.path.endsWith('/GuardarArticulo')).length;
  Future<http.Response> handle(http.Request r) async {
    requests.add(r);
    final path = r.url.path;
    dynamic result;
    if (path.contains('/DocumentosAbiertos/')) {
      result = openConteo
          ? [
              {
                'Code': '123',
                'BaseEntry': 456,
                'Referencia': '78',
                'Fecha': '2026-10-07'
              }
            ]
          : [];
    } else if (path.endsWith('/Conteos/12')) {
      result = [
        {
          'Code': 'SAP-CODE-NO-USAR',
          'BaseEntry': 456,
          'DocNum': 78,
          'Almacen': '01'
        }
      ];
    } else if (path.endsWith('/DocumentoNuevo')) {
      result = missingInternal
          ? {'Success': true, 'Code': 'WRONG'}
          : {'Success': true, 'DocumentoInterno': '123'};
    } else if (path.endsWith('/ArticulosPendientes/123')) {
      result = {
        'Valores': [
          {
            'LineNum': 1,
            'ItemCode': 'ART001',
            'ItemName': 'Artículo',
            'Almacen': '01',
            'Ubicacion': '01-A',
            'ExistenciaReferencia': 2,
            'CantidadCapturada': total,
            'CantidadPendiente': 0,
            'CodigoBarras': '7501234567890'
          },
          if (duplicateItem)
            {
              'LineNum': 2,
              'ItemCode': 'ART001',
              'Almacen': '01',
              'Ubicacion': '01-B',
              'CodigoBarras': '7501234567890'
            },
        ]
      };
    } else if (path.endsWith('/ObtenerArticulos/123')) {
      result = [
        {'CodigoArticulo': 'ART001', 'Cantidad': total, 'Linea': 1}
      ];
    } else if (path.endsWith('/LeerCodigoBarra')) {
      result = {
        'valores': {'itemCode': lookupItemCode}
      };
    } else if (path.endsWith('/GuardarArticulo')) {
      if (saveGate != null) await saveGate!.future;
      if (!saveSuccess) {
        return http.Response(
            jsonEncode({'Success': false, 'Descripcion': 'Lote requerido'}),
            200);
      }
      total += (jsonDecode(r.body)['Cantidad'] as int);
      result = {'Success': true};
    } else if (path.endsWith('/Procesar/123')) {
      if (processGate != null) await processGate!.future;
      result = {
        'Success': processSuccess,
        'Descripcion': 'SAP rechazó el conteo'
      };
    } else {
      throw StateError('Unexpected request: ${r.method} $path');
    }
    return http.Response(jsonEncode(result), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}

void main() {
  testWidgets(
      'Lectura manual selecciona sin guardar y permite indicar cantidad',
      (tester) async {
    final server = _Server();
    await http.runWithClient(() async {
      await tester.pumpWidget(
          const MaterialApp(home: CapturaConteoWidget(docCode: '123')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('codigoConteo')), '7501234567890');
      await tester.tap(find.text('Leer código'));
      await tester.pumpAndSettle();
      expect(server.saves, 0);
      await tester.enterText(find.byType(TextFormField).at(1), '3');
      await tester.ensureVisible(find.text('Guardar captura'));
      await tester.tap(find.text('Guardar captura'));
      await tester.pumpAndSettle();
      expect(server.total, 3);
    }, () => MockClient(server.handle));
  });

  testWidgets('Lectura de un artículo ajeno al conteo no guarda',
      (tester) async {
    final server = _Server()..lookupItemCode = 'OTRO';
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
          home: CapturaConteoWidget(docCode: '123', capturaRapida: true)));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('codigoConteo')), 'DESCONOCIDO');
      await tester.tap(find.text('Leer código'));
      await tester.pumpAndSettle();
      expect(server.saves, 0);
      expect(
          find.text('El código no corresponde a un artículo de este conteo.'),
          findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
    }, () => MockClient(server.handle));
  });

  testWidgets('Captura general de conteos abre captura rápida sin bloqueo',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final server = _Server();
    FFAppState().TipoDoc = 4;
    await http.runWithClient(() async {
      final auth = app_nav.AppStateNotifier.instance;
      auth.update(AstroledOfcAuthUser(loggedIn: true, uid: '12'));
      auth.stopShowingSplashImage();
      final router = app_nav.createRouter(auth);
      addTearDown(router.dispose);
      router.go('/capturaEntrada?docEntry=456&docInterno=123');
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      final checkbox = find.byType(Checkbox);
      if (!tester.widget<Checkbox>(checkbox).value!) {
        await tester.ensureVisible(checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
      }
      final button = find.byWidgetPredicate(
          (w) => w is FFButtonWidget && w.text == 'Captura  General');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(CapturaRapidaWidget), findsOneWidget);
      expect(find.byType(CapturaConteoWidget), findsNothing);
      final barcode = find.byWidgetPredicate(
          (w) => w is EditableText && w.onEditingComplete != null);
      await tester.ensureVisible(barcode);
      await tester.enterText(barcode, '7501234567890*5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(server.total, 5);
      final payload = jsonDecode(server.requests
          .lastWhere((r) => r.url.path.endsWith('/GuardarArticulo'))
          .body);
      expect(payload['Linea'], '1');
      expect(payload['UbicacionD'], '01-A');
      router.pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(CapturaArticulosWidget), findsOneWidget);
      await tester.ensureVisible(barcode);
      await tester.enterText(barcode, '7501234567890');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(server.saves, 1);
      await tester.enterText(find.byType(EditableText).last, '3');
      await tester.ensureVisible(find.text('Capturar'));
      await tester.tap(find.text('Capturar'));
      await tester.pumpAndSettle();
      expect(server.total, 8);
      expect(find.byType(CapturaEntradaWidget), findsOneWidget);
      expect(
          find.text(
              'Selecciona el artículo en la lista de pendientes para capturar su línea.'),
          findsNothing);
    }, () => MockClient(server.handle));
  });

  testWidgets('Lectura rápida conserva línea y ubicación y suma cantidades',
      (tester) async {
    final server = _Server();
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
          home: CapturaConteoWidget(docCode: '123', capturaRapida: true)));
      await tester.pumpAndSettle();
      for (final code in ['7501234567890', '7501234567890*5']) {
        await tester.enterText(
            find.byKey(const ValueKey('codigoConteo')), code);
        await tester.tap(find.text('Leer código'));
        await tester.pumpAndSettle();
      }
      expect(server.saves, 2);
      expect(server.total, 6);
      final payload = jsonDecode(server.requests
          .lastWhere((r) => r.url.path.endsWith('/GuardarArticulo'))
          .body);
      expect(payload['DocCode'], '123');
      expect(payload['Linea'], '1');
      expect(payload['AlmacenD'], '01');
      expect(payload['UbicacionD'], '01-A');
      expect(payload['TipoDocumento'], '4');
    }, () => MockClient(server.handle));
  });

  testWidgets(
      'Artículo en varias ubicaciones requiere elegir línea antes de guardar',
      (tester) async {
    final server = _Server()..duplicateItem = true;
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
          home: CapturaConteoWidget(docCode: '123', capturaRapida: true)));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('codigoConteo')), '7501234567890');
      await tester.tap(find.text('Leer código'));
      await tester.pumpAndSettle();
      expect(server.saves, 0);
      await tester.tap(find.textContaining('Línea 2 ·'));
      await tester.pumpAndSettle();
      expect(server.saves, 1);
      final payload = jsonDecode(server.requests
          .lastWhere((r) => r.url.path.endsWith('/GuardarArticulo'))
          .body);
      expect(payload['Linea'], '2');
      expect(payload['UbicacionD'], '01-B');
    }, () => MockClient(server.handle));
  });

  testWidgets(
      'Conteos usa pendientes y captura compartidos con cero y sobreexistencia',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final server = _Server()..openConteo = true;
    FFAppState().TipoDoc = 4;
    FFAppState().NombrePrincipal = 'Documentos abiertos Conteos';
    await http.runWithClient(() async {
      final auth = app_nav.AppStateNotifier.instance;
      auth.update(AstroledOfcAuthUser(loggedIn: true, uid: '12'));
      auth.stopShowingSplashImage();
      final router = app_nav.createRouter(auth);
      addTearDown(router.dispose);
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      final open = find.byWidgetPredicate(
          (w) => w is FFButtonWidget && w.text == 'Capturar');
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(find.byType(CapturaEntradaWidget), findsOneWidget);
      expect(find.text('pend.'), findsOneWidget);
      for (final quantity in ['0', '5']) {
        final select = find.byIcon(Icons.add_circle_outline_outlined);
        await tester.ensureVisible(select);
        await tester.tap(select);
        await tester.pumpAndSettle();
        expect(find.byType(CapturaArticulosWidget), findsOneWidget);
        expect(find.text('Ubicacion  '), findsNothing);
        expect(find.text('Lote sugerido'), findsNothing);
        expect(find.text('Cantidad pendiente: 0'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).last, quantity);
        final save = find.byWidgetPredicate(
            (w) => w is FFButtonWidget && w.text == 'Capturar');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.byType(CapturaEntradaWidget), findsOneWidget);
      }
      expect(server.saves, 2);
      expect(server.total, 5);
      final body = jsonDecode(server.requests
          .lastWhere((r) => r.url.path.endsWith('/GuardarArticulo'))
          .body);
      expect(body['DocCode'], '123');
      expect(body['Linea'], '1');
      expect(body['AlmacenD'], '01');
      expect(body['UbicacionD'], '01-A');
      expect(body['TipoDocumento'], '4');
      expect(body['Unidad'], 0);
      expect(
          server.requests
              .where((r) => r.url.path.endsWith('/ObtenerArticulos/123'))
              .length,
          2);
      expect(tester.takeException(), isNull);
      final captured = find.byWidgetPredicate(
          (w) => w is FFButtonWidget && w.text == 'Artículos Capturados');
      await tester.ensureVisible(captured);
      await tester.tap(captured);
      await tester.pumpAndSettle();
      expect(find.byType(ArticulosCapturadosWidget), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      final upload = find.byWidgetPredicate(
          (w) => w is FFButtonWidget && w.text == 'Subir a SAP');
      await tester.ensureVisible(upload);
      server.processGate = Completer<void>();
      await tester.tap(upload);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Subiendo conteo a SAP...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(find.text('Subiendo conteo a SAP...'), findsOneWidget);
      expect(
          server.requests
              .where((r) => r.url.path.endsWith('/Procesar/123'))
              .length,
          1);
      server.processGate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Subiendo conteo a SAP...'), findsNothing);
      expect(find.text('SAP rechazó el conteo'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.byType(CapturaEntradaWidget), findsOneWidget);
      server.processSuccess = true;
      await tester.tap(upload);
      await tester.pumpAndSettle();
      expect(find.byType(PrincipalWidget), findsOneWidget);
    }, () => MockClient(server.handle));
  });

  testWidgets('Pantalla compacta: buscar y Usar no crean documentos',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final server = _Server();
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: NuevoConteoWidget()));
      await tester.pumpAndSettle();
      expect(find.text('Nuevo Conteo de Inventario'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'inexistente');
      await tester.pumpAndSettle();
      expect(find.text('No hay coincidencias.'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '78');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usar'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).at(1))
              .controller!
              .text,
          '78');
      expect(server.requests.length, 1);
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  test('Respuestas PascalCase/camelCase y Success obligatorio al procesar', () {
    expect(
        conteoRows({
          'valores': [
            {'lineNum': 0}
          ]
        }).length,
        1);
    expect(conteoText({'lineNum': 0}, ['LineNum']), '0');
    expect(
        () => checkConteoResponse(
            const ApiCallResponse({'success': true}, {}, 200),
            requireSuccess: true),
        returnsNormally);
    expect(
        () => checkConteoResponse(const ApiCallResponse({}, {}, 200),
            requireSuccess: true),
        throwsStateError);
    expect(
        () => checkConteoResponse(
            const ApiCallResponse({'Error': true}, {}, 200)),
        throwsStateError);
  });
  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().idUsuario = '12';
  });

  testWidgets('Nueva en el menú abre Conteos con el router real',
      (tester) async {
    FFAppState().modulosUsuario = 'CON';
    final server = _Server();
    await http.runWithClient(() async {
      final auth = app_nav.AppStateNotifier.instance;
      auth.update(AstroledOfcAuthUser(loggedIn: true, uid: '12'));
      auth.stopShowingSplashImage();
      final router = app_nav.createRouter(auth);
      addTearDown(router.dispose);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      final nueva = find
          .byWidgetPredicate((w) => w is FFButtonWidget && w.text == 'Nueva')
          .last;
      await tester.ensureVisible(nueva);
      await tester.pumpAndSettle();
      await tester.tap(nueva);
      await tester.pumpAndSettle();
      expect(find.byType(NuevoConteoWidget), findsOneWidget);
      expect(find.text('Nuevo Conteo de Inventario'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Usar'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('crearConteo')));
      await tester.tap(find.byKey(const ValueKey('crearConteo')));
      await tester.pumpAndSettle();
      expect(find.byType(PrincipalWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // The menu must remain usable after creation returns via goNamed.
      await tester.ensureVisible(nueva);
      await tester.tap(nueva);
      await tester.pumpAndSettle();
      expect(find.byType(NuevoConteoWidget), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(PrincipalWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  testWidgets(
      'Crear usa BaseEntry y vuelve a Principal con documentos abiertos de conteos',
      (tester) async {
    final server = _Server();
    await http.runWithClient(() async {
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const NuevoConteoWidget()),
        GoRoute(
            path: '/principal',
            name: PrincipalWidget.routeName,
            builder: (_, state) => const PrincipalWidget()),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      expect(server.requests.length, 1);
      expect(find.text('Conteo: 78'), findsOneWidget);
      await tester.tap(find.text('Usar'));
      await tester.pumpAndSettle();
      expect(server.requests.where((r) => r.method == 'POST'), isEmpty);
      await tester.ensureVisible(find.byKey(const ValueKey('crearConteo')));
      await tester.tap(find.byKey(const ValueKey('crearConteo')));
      await tester.pumpAndSettle();
      final creation = server.requests.singleWhere((r) => r.method == 'POST');
      expect(jsonDecode(creation.body), {
        'Documento': '4',
        'Usuario': '12',
        'BaseType': '1000',
        'BaseEntry': '456'
      });
      expect(
          creation.headers['Content-Type'] ?? creation.headers['content-type'],
          contains('application/json'));
      expect(find.byType(PrincipalWidget), findsOneWidget);
      expect(find.text('Documentos abiertos Conteos'), findsOneWidget);
      expect(FFAppState().TipoDoc, 4);
      expect(
          server.requests
              .any((r) => r.url.path.endsWith('/DocumentosAbiertos/4/12')),
          isTrue);
      expect(
          server.requests
              .any((r) => r.url.path.contains('/ArticulosPendientes/')),
          isFalse);
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  testWidgets('Cero y sobreexistencia, acumulación, doble envío y refrescos',
      (tester) async {
    final server = _Server();
    await http.runWithClient(() async {
      await tester.pumpWidget(
          const MaterialApp(home: CapturaConteoWidget(docCode: '123')));
      await tester.pumpAndSettle();
      for (final quantity in ['0', '5']) {
        await tester.ensureVisible(find.text('Capturar'));
        await tester.tap(find.text('Capturar'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(1), quantity);
        await tester.enterText(find.byType(TextFormField).at(2), 'LOTE1');
        await tester.ensureVisible(find.text('Guardar captura'));
        server.saveGate = Completer<void>();
        await tester.tap(find.text('Guardar captura'));
        await tester.pump();
        final button = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Procesando…'));
        expect(button.onPressed, isNull);
        final count = server.saves;
        await tester.tap(find.text('Procesando…'), warnIfMissed: false);
        await tester.pump();
        expect(server.saves, count);
        server.saveGate!.complete();
        await tester.pumpAndSettle();
      }
      expect(server.saves, 2);
      expect(server.total, 5);
      final saved = jsonDecode(server.requests
          .lastWhere((r) => r.url.path.endsWith('/GuardarArticulo'))
          .body);
      expect(saved, {
        'DocCode': '123',
        'TipoDocumento': '4',
        'Usuario': '12',
        'CodigoArticulo': 'ART001',
        'CodigoBarras': '7501234567890',
        'Linea': '1',
        'Cantidad': 5,
        'AlmacenD': '01',
        'UbicacionD': '01-A',
        'Lote': 'LOTE1',
        'Unidad': 0
      });
      expect(
          server.requests
              .where((r) => r.url.path.endsWith('/ArticulosPendientes/123'))
              .length,
          3);
      expect(
          server.requests
              .where((r) => r.url.path.endsWith('/ObtenerArticulos/123'))
              .length,
          3);
      expect(find.text('Cantidad capturada: 5'), findsOneWidget);
      expect(find.text('Capturar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  testWidgets('SAP rechaza sin perder captura; Success true vuelve a abiertos',
      (tester) async {
    final server = _Server()..total = 5;
    await http.runWithClient(() async {
      final router = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (_, __) => const CapturaConteoWidget(docCode: '123')),
        GoRoute(
            path: '/principal',
            name: 'Principal',
            builder: (_, __) =>
                const Scaffold(body: Text('Documentos abiertos'))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Subir a SAP'));
      await tester.tap(find.text('Subir a SAP'));
      await tester.pumpAndSettle();
      expect(find.textContaining('SAP rechazó el conteo'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('Conteo interno #123'), findsOneWidget);
      expect(server.total, 5);
      server.processSuccess = true;
      await tester.tap(find.text('Subir a SAP'));
      await tester.pumpAndSettle();
      expect(find.text('Documentos abiertos'), findsOneWidget);
      expect(FFAppState().TipoDoc, 4);
      expect(
          server.requests
              .where((r) => r.url.path.endsWith('/Procesar/123'))
              .length,
          2);
    }, () => MockClient(server.handle));
  });

  testWidgets('Rechazo al guardar conserva cantidad y selección',
      (tester) async {
    final server = _Server()..saveSuccess = false;
    await http.runWithClient(() async {
      await tester.pumpWidget(
          const MaterialApp(home: CapturaConteoWidget(docCode: '123')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capturar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), '-1');
      await tester.ensureVisible(find.text('Guardar captura'));
      await tester.tap(find.text('Guardar captura'));
      await tester.pumpAndSettle();
      expect(server.saves, 0);
      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.ensureVisible(find.text('Guardar captura'));
      await tester.tap(find.text('Guardar captura'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Lote requerido'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).at(1))
              .controller!
              .text,
          '5');
      expect(server.saves, 1);
      expect(server.total, 0);
    }, () => MockClient(server.handle));
  });

  testWidgets('No usa Code como reemplazo de DocumentoInterno', (tester) async {
    final server = _Server()..missingInternal = true;
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: NuevoConteoWidget()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usar'));
      await tester.pumpAndSettle();
      expect(server.requests.where((r) => r.method == 'POST'), isEmpty);
      await tester.ensureVisible(find.byKey(const ValueKey('crearConteo')));
      await tester.tap(find.byKey(const ValueKey('crearConteo')));
      await tester.pumpAndSettle();
      expect(find.textContaining('La API no devolvió DocumentoInterno'),
          findsOneWidget);
      expect(server.requests.length, 2);
    }, () => MockClient(server.handle));
  });
}
