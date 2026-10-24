import '/custom_code/barcode_quantity.dart';
import '/conteos/conteo_capture.dart';
import '/conteos/conteo_data.dart';
import '/backend/api_requests/capture_save_feedback.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'captura_rapida_model.dart';
export 'captura_rapida_model.dart';

class CapturaRapidaWidget extends StatefulWidget {
  const CapturaRapidaWidget({
    super.key,
    required this.docEntry,
    required this.docInterno,
    required this.itemCode,
    required this.nombreArticulo,
    required this.cantidad,
    required this.almacen,
    required this.precio,
    required this.fecha,
    required this.fromButton,
  });

  final int? docEntry;
  final String? docInterno;
  final String? itemCode;
  final String? nombreArticulo;
  final String? cantidad;
  final String? almacen;
  final double? precio;
  final String? fecha;
  final bool? fromButton;

  static String routeName = 'CapturaRapida';
  static String routePath = '/capturaRapida';

  @override
  State<CapturaRapidaWidget> createState() => _CapturaRapidaWidgetState();
}

class _CapturaRapidaWidgetState extends State<CapturaRapidaWidget> {
  late CapturaRapidaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CapturaRapidaModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {
        _model.codigoBarrasTextController?.text = '';
        _model.ubicacionFocusNode?.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _model.ubicacionTextController?.selection =
              const TextSelection.collapsed(offset: 0);
        });
      });
    });

    _model.codigoBarrasTextController ??= TextEditingController();
    _model.codigoBarrasFocusNode ??= FocusNode();

    _model.ubicacionTextController ??= TextEditingController();
    _model.ubicacionFocusNode ??= FocusNode();

    final initialAlmacen = (widget.almacen ?? '').trim().isNotEmpty
        ? widget.almacen!.trim()
        : FFAppState().almacen.trim();
    _model.almacen = initialAlmacen;
    if (initialAlmacen.isNotEmpty) {
      FFAppState().almacen = initialAlmacen;
    }
  }

  bool _showBarcodeResult(ApiCallResponse? response) {
    if (!mounted) return false;
    final itemCode = getJsonField(response?.jsonBody, r'''$.valores.itemCode''')
        ?.toString()
        .trim();
    final success = response?.succeeded == true &&
        getJsonField(response?.jsonBody, r'''$.error''') != true &&
        itemCode != null &&
        itemCode.isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      duration: const Duration(seconds: 2),
      content: Row(children: [
        Icon(success ? Icons.check_circle : Icons.error_outline,
            color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
          success ? 'Código leído correctamente' : 'No se pudo leer el código',
          style: const TextStyle(color: Colors.white),
        )),
      ]),
    ));
    return success;
  }

  Future<void> _captureBarcode(String barcode) async {
    if (_model.isLoading || barcode.trim().isEmpty) return;
    if (FFAppState().TipoDoc == 4) {
      await _captureConteo(barcode);
      return;
    }
    _model.codigoBarrasTextController.text = barcode;
    final barcodeQuantity = quantityFromBarcode(barcode) ?? 1;
    var shouldSetState = false;
    final requestAlmacen = ((widget.almacen ?? '').trim().isNotEmpty)
        ? widget.almacen!.trim()
        : ((_model.almacen.trim().isNotEmpty)
            ? _model.almacen.trim()
            : FFAppState().almacen.trim());
    if (requestAlmacen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecciona un almacen antes de leer el codigo.',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).info,
            ),
          ),
          duration: const Duration(milliseconds: 2500),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }
    FFAppState().almacen = requestAlmacen;
    _model.loadingMessage = 'Consultando código...';
    _model.codigoEscaneado = _model.codigoBarrasTextController.text.trim();
    _model.isLoading = true;
    safeSetState(() {});

    try {
      _model.codigobarras = await WSInventariosGroup.leerCodigoBarrasCall.call(
        codigoBarras: _model.codigoBarrasTextController.text,
        almacen: requestAlmacen,
      );
    } catch (e) {
      _model.isLoading = false;
      _model.codigoEscaneado = null;
      safeSetState(() {});
      rethrow;
    }

    shouldSetState = true;
    if (_showBarcodeResult(_model.codigobarras)) {
      _model.almacen = requestAlmacen;
      safeSetState(() {});
      _model.nombre = getJsonField(
        (_model.codigobarras?.jsonBody ?? ''),
        r'''$.valores.itemName''',
      ).toString();
      safeSetState(() {});
      FFAppState().unidad = getJsonField(
        (_model.codigobarras?.jsonBody ?? ''),
        r'''$.valores.unidad''',
      );
      safeSetState(() {});
    } else {
      _model.isLoading = false;
      _model.codigoEscaneado = null;
      safeSetState(() {});
      await showDialog(
        context: context,
        builder: (alertDialogContext) {
          return AlertDialog(
            title: const Text('Lectura fallida'),
            content: Text(getJsonField(
              (_model.codigobarras?.jsonBody ?? ''),
              r'''$.descripcion''',
            ).toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
      if (shouldSetState) {
        safeSetState(() {});
      }
      return;
    }

    _model.loadingMessage = 'Guardando artículo...';
    safeSetState(() {});

    try {
      _model.apiResultm1b = await WSInventariosGroup.guardarArticuloCall.call(
        codigoArticulo: getJsonField(
          (_model.codigobarras?.jsonBody ?? ''),
          r'''$.valores.itemCode''',
        ).toString(),
        nombre: getJsonField(
          (_model.codigobarras?.jsonBody ?? ''),
          r'''$.valores.itemName''',
        ).toString(),
        codigoBarras: _model.codigoBarrasTextController.text,
        cantidad: barcodeQuantity,
        lote: FFAppState().TipoDoc == 2
            ? (getJsonField(
                  _model.codigobarras?.jsonBody,
                  r'''$.valores.loteSugerido''',
                )?.toString() ??
                '')
            : '',
        almacenO: FFAppState().TipoDoc == 2 ? requestAlmacen : '',
        almacenD: FFAppState().TipoDoc == 2 ? '' : requestAlmacen,
        usuario: FFAppState().idUsuario,
        tipoDocumento: FFAppState().TipoDoc.toString(),
        precio: widget.precio,
        fecha: getCurrentTimestamp.toString(),
        unidad: FFAppState().unidad,
        docCode: widget.docInterno,
        ubicacionO: FFAppState().TipoDoc == 2
            ? _model.ubicacionTextController.text
            : '',
        ubicacionD: FFAppState().TipoDoc == 2
            ? ''
            : _model.ubicacionTextController.text,
      );
    } finally {
      _model.isLoading = false;
      _model.codigoEscaneado = null;
      safeSetState(() {});
    }

    shouldSetState = true;
    if (!mounted) return;
    if (captureSaveSucceeded(_model.apiResultm1b)) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Artículo capturado',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).info,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      safeSetState(() {
        _model.codigoBarrasTextController?.text = '';
      });
    } else {
      await showCaptureSaveError(context, _model.apiResultm1b);
    }

    if (shouldSetState) {
      safeSetState(() {});
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _captureConteo(String barcode) async {
    _model.codigoBarrasTextController.text = barcode;
    setState(() { _model.isLoading = true; _model.loadingMessage = 'Consultando código...'; });
    try {
      final row = await resolverArticuloConteo(context,
        docCode: widget.docInterno ?? '', barcode: barcode,
        ubicacion: _model.ubicacionTextController.text);
      if (!mounted || row == null) return;
      setState(() {
        _model.nombre = conteoText(row, ['itemName']);
        _model.almacen = conteoText(row, ['almacen']);
        _model.loadingMessage = 'Guardando artículo...';
      });
      final response = await WSInventariosGroup.guardarArticuloCall.call(
        docCode: widget.docInterno, tipoDocumento: '4', usuario: FFAppState().idUsuario,
        codigoArticulo: conteoText(row, ['itemCode']), codigoBarras: barcode.trim(),
        cantidad: quantityFromBarcode(barcode) ?? 1, linea: conteoText(row, ['lineNum']),
        almacenD: conteoText(row, ['almacen']), ubicacionD: conteoText(row, ['ubicacion']),
        lote: conteoText(row, ['lote']), unidad: 0,
      );
      checkConteoResponse(response);
      if (!mounted) return;
      _model.codigoBarrasTextController?.clear();
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo capturado')));
    } catch (error) {
      if (mounted) {
        await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
          title: const Text('No se pudo capturar'), content: Text(conteoErrorText(error)),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Aceptar'))],
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _model.isLoading = false);
        _model.codigoBarrasFocusNode?.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'It One - Inventarios Móviles',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.readexPro(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: _model.isLoading,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  15.0, 15.0, 15.0, 15.0),
                              child: Container(
                                width: 392.1,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: Text(
                                                  FFAppState().TipoDoc == 2
                                                      ? 'Captura Salida Mercancía'
                                                      : 'Captura Entrada Mercancía',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Text(
                                                'Documento interno captura:  ',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  widget.docInterno,
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (widget.fromButton ?? true)
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 10.0, 0.0, 10.0),
                                                child: Text(
                                                  'Artículo Captura : ',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 10.0, 0.0, 10.0),
                                                child: Text(
                                                  valueOrDefault<String>(
                                                    widget.itemCode,
                                                    '0',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 6.0,
                                  color: Color(0x1B090F13),
                                  offset: Offset(0.0, 2.0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 10.0, 10.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 20.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                const AlignmentDirectional(
                                                    0.0, 0.0),
                                            child: Text(
                                              'Captura Artículo',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Ubicacion  ',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: TextFormField(
                                              controller: _model
                                                  .ubicacionTextController,
                                              focusNode:
                                                  _model.ubicacionFocusNode,
                                              onFieldSubmitted: (_) {
                                                _model.codigoBarrasFocusNode
                                                    ?.requestFocus();
                                              },
                                              autofocus: true,
                                              enabled: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                              keyboardType:
                                                  TextInputType.text,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              enableInteractiveSelection: true,
                                              validator: _model
                                                  .ubicacionTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Artículo      ',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: TextFormField(
                                              controller: _model
                                                  .codigoBarrasTextController,
                                              focusNode:
                                                  _model.codigoBarrasFocusNode,
                                              // Keep scanner Enter from closing the input connection.
                                              onEditingComplete: () {},
                                              keyboardType: TextInputType.text,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              onFieldSubmitted: _captureBarcode,
                                              autofocus: false,
                                              enabled: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                hintText: 'Código Barras',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                              textAlign: TextAlign.start,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              enableInteractiveSelection: true,
                                              validator: _model
                                                  .codigoBarrasTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(7.0, 0.0, 0.0, 0.0),
                                          child: FlutterFlowIconButton(
                                            borderRadius: 8.0,
                                            buttonSize: 40.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                              if (_model.isLoading) return;
                                              if (FFAppState().TipoDoc == 4) {
                                                await actions.scanBarcode(context);
                                                if (mounted) await _captureBarcode(FFAppState().globalBarcode);
                                                return;
                                              }
                                              final requestAlmacen =
                                                  ((widget.almacen ?? '')
                                                          .trim()
                                                          .isNotEmpty)
                                                      ? widget.almacen!.trim()
                                                      : ((_model.almacen
                                                              .trim()
                                                              .isNotEmpty)
                                                          ? _model.almacen
                                                              .trim()
                                                          : FFAppState()
                                                              .almacen
                                                              .trim());
                                              if (requestAlmacen.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Selecciona un almacen antes de leer el codigo.',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                      ),
                                                    ),
                                                    duration: const Duration(
                                                        milliseconds: 2500),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .error,
                                                  ),
                                                );
                                                return;
                                              }
                                              FFAppState().almacen =
                                                  requestAlmacen;
                                              await actions.scanBarcode(
                                                context,
                                              );
                                              if (!mounted) return;
                                              final scannedCode = FFAppState()
                                                  .globalBarcode
                                                  .trim();
                                              if (scannedCode.isEmpty) {
                                                return;
                                              }

                                              await _captureBarcode(
                                                  scannedCode);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_model.isLoading)
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: IgnorePointer(
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _model.loadingMessage ?? 'Procesando código...',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
