import 'package:flutter/material.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/principal/principal_widget.dart';
import 'conteo_data.dart';
import '/custom_code/actions/scan_barcode.dart';
import '/custom_code/barcode_quantity.dart';

class CapturaConteoWidget extends StatefulWidget {
  const CapturaConteoWidget(
      {super.key, required this.docCode, this.capturaRapida = false});
  final String docCode;
  final bool capturaRapida;
  static const routeName = 'CapturaConteo';
  static const routePath = '/capturaConteo';
  @override
  State<CapturaConteoWidget> createState() => _CapturaConteoWidgetState();
}

class _CapturaConteoWidgetState extends State<CapturaConteoWidget> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _cantidad = TextEditingController();
  final _barcode = TextEditingController();
  final _lote = TextEditingController();
  final _lectura = TextEditingController();
  final _lecturaFocus = FocusNode();
  bool _leyendo = false;
  dynamic _seleccionado;
  List<dynamic> _pendientes = [], _capturados = [];
  bool _cargando = true, _ocupado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refrescar();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _cantidad.dispose();
    _barcode.dispose();
    _lote.dispose();
    _lectura.dispose();
    _lecturaFocus.dispose();
    super.dispose();
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (widget.docCode.trim().isEmpty) {
        throw StateError('Falta el código interno del documento.');
      }
      final responses = await Future.wait([
        WSInventariosGroup.articulosPendientesCall
            .call(docCode: widget.docCode),
        WSInventariosGroup.obtenerArticulosPorDocumentoCall
            .call(docId: widget.docCode),
      ]);
      for (final response in responses) {
        checkConteoResponse(response);
      }
      final pendientes = conteoRows(responses[0].jsonBody);
      final capturados = conteoRows(responses[1].jsonBody);
      if (!mounted) return;
      setState(() {
        _pendientes = pendientes;
        _capturados = capturados;
      });
    } catch (error) {
      if (mounted) setState(() => _error = conteoErrorText(error));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _aviso(String message) => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Conteo'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'))
            ],
          ));

  void _seleccionar(dynamic row) {
    setState(() {
      _seleccionado = row;
      _cantidad.clear();
      _barcode.text = conteoText(row, ['CodigoBarras', 'Barcode']);
      _lote.text = conteoText(row, ['Lote']);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _leerCodigo(String value) async {
    final code = value.trim();
    if (code.isEmpty || _leyendo || _ocupado || _cargando || _error != null) {
      return;
    }
    setState(() => _leyendo = true);
    try {
      var matches = _pendientes
          .where((row) =>
              conteoText(row, ['CodigoBarras', 'Barcode']) == code ||
              conteoText(row, ['ItemCode', 'CodigoArticulo']) == code)
          .toList();
      if (matches.isEmpty) {
        final almacenes = _pendientes
            .map((row) => conteoText(row, ['Almacen', 'AlmacenD', 'WhsCode']))
            .where((almacen) => almacen.isNotEmpty)
            .toSet();
        for (final almacen in almacenes) {
          final response = await WSInventariosGroup.leerCodigoBarrasCall
              .call(codigoBarras: code, almacen: almacen);
          checkConteoResponse(response);
          final values = conteoValue(response.jsonBody, ['Valores']);
          final itemCode = conteoText(values, ['ItemCode', 'CodigoArticulo']);
          if (itemCode.isEmpty) continue;
          matches.addAll(_pendientes.where((row) =>
              conteoText(row, ['ItemCode', 'CodigoArticulo']) == itemCode &&
              conteoText(row, ['Almacen', 'AlmacenD', 'WhsCode']) == almacen));
        }
      }
      if (!mounted) return;
      if (matches.isEmpty) {
        await _aviso('El código no corresponde a un artículo de este conteo.');
        return;
      }
      final dynamic row;
      if (matches.length == 1) {
        row = matches.single;
      } else {
        row = await showDialog<dynamic>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Selecciona la línea del conteo'),
            children: [
              for (final match in matches)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, match),
                  child: Text(
                      'Línea ${conteoText(match, ['LineNum', 'Linea'])} · '
                      'Almacén ${conteoText(match, [
                        'Almacen',
                        'AlmacenD',
                        'WhsCode'
                      ])} · '
                      '${conteoText(match, [
                        'Ubicacion',
                        'UbicacionD',
                        'BinCode'
                      ])} · '
                      'Lote ${conteoText(match, ['Lote'])}'),
                ),
            ],
          ),
        );
      }
      if (!mounted || row == null) return;
      _seleccionar(row);
      _barcode.text = code;
      _cantidad.text = (quantityFromBarcode(code) ?? 1).toString();
      _lectura.clear();
      if (widget.capturaRapida) await _guardar(validarFormulario: false);
    } catch (error) {
      if (mounted) await _aviso(conteoErrorText(error));
    } finally {
      if (mounted) {
        setState(() => _leyendo = false);
        if (_seleccionado == null) _lecturaFocus.requestFocus();
      }
    }
  }

  Future<void> _guardar({bool validarFormulario = true}) async {
    if (_ocupado ||
        _cargando ||
        _seleccionado == null ||
        (validarFormulario && !(_form.currentState?.validate() ?? false))) {
      return;
    }
    final row = _seleccionado;
    final linea = conteoText(row, ['LineNum', 'Linea']);
    final codigo = conteoText(row, ['ItemCode', 'CodigoArticulo']);
    final almacen = conteoText(row, ['Almacen', 'AlmacenD', 'WhsCode']);
    if (linea.isEmpty || codigo.isEmpty || almacen.isEmpty) {
      await _aviso(
          'El artículo no contiene LineNum, código o almacén. Actualiza los pendientes antes de capturar.');
      return;
    }
    setState(() => _ocupado = true);
    try {
      final response = await WSInventariosGroup.guardarArticuloCall.call(
        docCode: widget.docCode,
        tipoDocumento: '4',
        usuario: FFAppState().idUsuario,
        codigoArticulo: codigo,
        codigoBarras: _barcode.text.trim(),
        linea: linea,
        cantidad: int.parse(_cantidad.text.trim()),
        almacenD: almacen,
        ubicacionD: conteoText(row, ['Ubicacion', 'UbicacionD', 'BinCode']),
        lote: _lote.text.trim(),
        unidad: 0,
      );
      checkConteoResponse(response);
      if (!mounted) return;
      setState(() {
        _seleccionado = null;
        _cantidad.clear();
        _barcode.clear();
        _lote.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cantidad sumada al conteo')));
      await _refrescar();
    } catch (error) {
      if (mounted) {
        await _aviso(
            '${conteoErrorText(error)}\nSi se perdió la conexión, actualiza la captura antes de repetir el envío: cada guardado suma cantidad.');
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _subir() async {
    if (_ocupado || _cargando) return;
    setState(() => _ocupado = true);
    try {
      final response = await WSInventariosGroup.procesarDocumentoCall
          .call(docCode: widget.docCode);
      checkConteoResponse(response, requireSuccess: true);
      if (!mounted) return;
      FFAppState().update(() {
        FFAppState().TipoDoc = 4;
        FFAppState().NombrePrincipal = 'Documentos abiertos Conteos';
      });
      context.goNamed(PrincipalWidget.routeName);
    } catch (error) {
      if (mounted) await _aviso(conteoErrorText(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final disabled = _ocupado || _cargando || _leyendo;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${widget.capturaRapida ? 'Captura rápida · ' : ''}Conteo interno #${widget.docCode}'),
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: disabled ? null : _refrescar,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar')
          ]),
      body: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: [
            if (_cargando) const LinearProgressIndicator(),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.error)),
              TextButton(
                  onPressed: disabled ? null : _refrescar,
                  child: const Text('Reintentar'))
            ],
            TextField(
              key: const ValueKey('codigoConteo'),
              controller: _lectura,
              focusNode: _lecturaFocus,
              enabled: !disabled && _error == null,
              decoration: InputDecoration(
                labelText: 'Leer código de barras o artículo',
                helperText: widget.capturaRapida
                    ? 'Cada lectura guarda y suma la cantidad del código, o 1 unidad.'
                    : 'Lee un código o selecciona un artículo de la lista.',
                suffixIcon: IconButton(
                  tooltip: 'Escanear código',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: disabled || _error != null
                      ? null
                      : () async {
                          await scanBarcode(context);
                          if (mounted) {
                            await _leerCodigo(FFAppState().globalBarcode);
                          }
                        },
                ),
              ),
              onSubmitted: _leerCodigo,
            ),
            TextButton(
              onPressed: disabled || _error != null
                  ? null
                  : () => _leerCodigo(_lectura.text),
              child: const Text('Leer código'),
            ),
            if (_seleccionado != null)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _form,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Capturar ${conteoText(_seleccionado, [
                                          'ItemCode',
                                          'CodigoArticulo'
                                        ])}',
                                    style: theme.titleMedium),
                                const Text(
                                    'Cada guardado suma la cantidad ingresada al total capturado.'),
                                TextFormField(
                                    controller: _barcode,
                                    enabled: !disabled,
                                    decoration: const InputDecoration(
                                        labelText: 'Código de barras')),
                                TextFormField(
                                    controller: _cantidad,
                                    enabled: !disabled,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: 'Cantidad a sumar'),
                                    validator: (value) {
                                      final n =
                                          int.tryParse(value?.trim() ?? '');
                                      return n == null || n < 0
                                          ? 'Ingresa una cantidad entera mayor o igual a cero'
                                          : null;
                                    }),
                                TextFormField(
                                    controller: _lote,
                                    enabled: !disabled,
                                    decoration: const InputDecoration(
                                        labelText:
                                            'Lote (cuando corresponda)')),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                    onPressed: disabled ? null : _guardar,
                                    child: Text(_ocupado
                                        ? 'Procesando…'
                                        : 'Guardar captura')),
                                TextButton(
                                    onPressed: disabled
                                        ? null
                                        : () => setState(
                                            () => _seleccionado = null),
                                    child: const Text('Cancelar selección')),
                              ])))),
            Text('Artículos pendientes', style: theme.headlineSmall),
            if (!_cargando && _pendientes.isEmpty && _error == null)
              const Text('No hay artículos disponibles.'),
            for (final row in _pendientes)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${conteoText(row, [
                                      'ItemCode',
                                      'CodigoArticulo'
                                    ])} · ${conteoText(row, [
                                      'ItemName',
                                      'Nombre'
                                    ])}',
                                style: theme.titleMedium),
                            Text('Almacén: ${conteoText(row, [
                                  'Almacen',
                                  'AlmacenD',
                                  'WhsCode'
                                ])} · Ubicación: ${conteoText(row, [
                                  'Ubicacion',
                                  'UbicacionD',
                                  'BinCode'
                                ])}'),
                            Text('Existencia de referencia: ${conteoText(row, [
                                  'ExistenciaReferencia',
                                  'Existencia',
                                  'InWhsQty'
                                ])}'),
                            Text('Cantidad capturada: ${conteoText(row, [
                                  'CantidadCapturada',
                                  'CountQty'
                                ])}'),
                            Text('Línea: ${conteoText(row, ['LineNum'])}'),
                            TextButton(
                                onPressed:
                                    disabled ? null : () => _seleccionar(row),
                                child: const Text('Capturar')),
                          ]))),
            const SizedBox(height: 16),
            Text('Artículos capturados', style: theme.headlineSmall),
            for (final row in _capturados)
              ListTile(
                title: Text('${conteoText(row, [
                      'CodigoArticulo',
                      'ItemCode'
                    ])} · ${conteoText(row, ['Nombre', 'ItemName'])}'),
                subtitle: Text('Línea: ${conteoText(row, [
                      'Linea',
                      'LineNum'
                    ])} · Lote: ${conteoText(row, ['Lote'])}'),
                trailing:
                    Text(conteoText(row, ['Cantidad', 'CantidadCapturada'])),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: disabled || _error != null ? null : _subir,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Subir a SAP')),
          ]),
    );
  }
}
