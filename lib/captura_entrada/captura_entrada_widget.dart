import '/backend/api_requests/api_load_state.dart';
import '/backend/api_requests/api_calls.dart';
import 'dart:async';
import '/conteos/conteo_data.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'captura_entrada_model.dart';
export 'captura_entrada_model.dart';

class CapturaEntradaWidget extends StatefulWidget {
  const CapturaEntradaWidget({
    super.key,
    required this.docEntry,
    required this.docInterno,
  });

  final int? docEntry;
  final String? docInterno;

  static String routeName = 'CapturaEntrada';
  static String routePath = '/capturaEntrada';

  @override
  State<CapturaEntradaWidget> createState() => _CapturaEntradaWidgetState();
}

class _CapturaEntradaWidgetState extends State<CapturaEntradaWidget> {
  late CapturaEntradaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _subiendoConteo = false;

  Future<void> _subirConteo() async {
    if (_subiendoConteo) return;
    _subiendoConteo = true;
    try {
      final navigator = Navigator.of(context, rootNavigator: true);
      final loadingRoute = DialogRoute<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(children: [
              SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
              SizedBox(width: 20),
              Expanded(child: Text('Subiendo conteo a SAP...')),
            ]),
          ),
        ),
      );
      unawaited(navigator.push(loadingRoute));
      late ApiCallResponse response;
      try {
        response = await WSInventariosGroup.procesarDocumentoCall.call(docCode: widget.docInterno);
      } finally {
        if (loadingRoute.isActive) navigator.removeRoute(loadingRoute);
      }
      checkConteoResponse(response, requireSuccess: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conteo actualizado en SAP')),
      );
      FFAppState().update(() {
        FFAppState().TipoDoc = 4;
        FFAppState().NombrePrincipal = 'Documentos abiertos Conteos';
      });
      context.goNamed(PrincipalWidget.routeName);
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: const Text('Conteo'), content: Text(conteoErrorText(error)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
      ));
    } finally { _subiendoConteo = false; }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CapturaEntradaModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<ApiCallResponse>(
      future: WSInventariosGroup.articulosPendientesCall.call(
        docCode: widget.docInterno,
      ),
      builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: () => setState(() {}), fullScreen: true);
        if (loadState != null) return loadState;
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        var capturaEntradaArticulosPendientesResponse = snapshot.data!;
        if (FFAppState().TipoDoc == 4) {
          try {
            checkConteoResponse(capturaEntradaArticulosPendientesResponse);
            capturaEntradaArticulosPendientesResponse = ApiCallResponse(
              conteoRows(capturaEntradaArticulosPendientesResponse.jsonBody).map(conteoArticulo).toList(),
              capturaEntradaArticulosPendientesResponse.headers,
              capturaEntradaArticulosPendientesResponse.statusCode,
            );
          } catch (error) {
            return Scaffold(appBar: AppBar(title: const Text('Artículos pendientes')),
              body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(conteoErrorText(error)),
                TextButton(onPressed: () => setState(() {}), child: const Text('Reintentar')),
              ])));
          }
        }

        if (kDebugMode) {
          debugPrint(
            '📦 [ArticulosPendientes] docCode="${widget.docInterno}" '
            'status=${capturaEntradaArticulosPendientesResponse.statusCode} '
            'succeeded=${capturaEntradaArticulosPendientesResponse.succeeded}',
          );
        }

        final almacenDocumento = (getJsonField(
                      capturaEntradaArticulosPendientesResponse.jsonBody,
                      r'''$[0].almacen''',
                    ) ??
                    getJsonField(
                      capturaEntradaArticulosPendientesResponse.jsonBody,
                      r'''$.valores[0].almacen''',
                    ))
                ?.toString() ??
            '';

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
                  context.pushNamed(PrincipalWidget.routeName);
                },
              ),
              title: Text(
                'Artículos pendientes',
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
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
              ),
              actions: const [],
              centerTitle: false,
              elevation: 1.0,
            ),
            body: SafeArea(
              top: true,
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
                                    10.0, 10.0, 10.0, 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Text(
                                                'Captura  Mercancía',
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
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Orden  No: ',
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
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          valueOrDefault<String>(
                                            widget.docEntry?.toString(),
                                            '0',
                                          ),
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
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 10.0, 0.0, 10.0),
                                          child: Text(
                                            'Documento interno captura:  ',
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
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 10.0, 0.0, 10.0),
                                          child: Text(
                                            valueOrDefault<String>(
                                              widget.docInterno,
                                              '0',
                                            ),
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 10.0, 0.0, 10.0),
                                          child: Text(
                                            'Captura Continua',
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
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                            ),
                                            unselectedWidgetColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                          ),
                                          child: Checkbox(
                                            value: _model.checkboxValue ??=
                                                true,
                                            onChanged: (newValue) async {
                                              safeSetState(() => _model
                                                  .checkboxValue = newValue!);
                                            },
                                            side: (FlutterFlowTheme.of(context)
                                                        .alternate !=
                                                    null)
                                                ? BorderSide(
                                                    width: 2,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                  )
                                                : null,
                                            activeColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            checkColor:
                                                FlutterFlowTheme.of(context)
                                                    .info,
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
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 10.0),
                      child: Container(
                        height: 372.85,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
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
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final respuesta =
                                        capturaEntradaArticulosPendientesResponse
                                            .jsonBody;
                                    final valores = respuesta is Map
                                        ? respuesta['valores']
                                        : respuesta;
                                    final articuloPendiente =
                                        valores is List ? valores : [];

                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Artículos pendientes',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                              ),
                                              Text(
                                                '${articuloPendiente.length}',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: articuloPendiente.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .inventory_2_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 40.0,
                                                      ),
                                                      const SizedBox(
                                                          height: 10.0),
                                                      Text(
                                                        'Sin artículos pendientes',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount:
                                                      articuloPendiente.length,
                                                  itemBuilder: (context,
                                                      articuloPendienteIndex) {
                                                    final articuloPendienteItem =
                                                        articuloPendiente[
                                                            articuloPendienteIndex];
                                                    final ubicaciones =
                                                        getJsonField(
                                                              articuloPendienteItem,
                                                              r'''$.ubicaciones''',
                                                            )
                                                                ?.toString()
                                                                .trim() ??
                                                            '';
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  getJsonField(
                                                                    articuloPendienteItem,
                                                                    r'''$.itemCode''',
                                                                  ).toString(),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        2.0),
                                                                Text(
                                                                  getJsonField(
                                                                    articuloPendienteItem,
                                                                    r'''$.itemName''',
                                                                  ).toString(),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                ),
                                                                if (FFAppState().TipoDoc == 4)
                                                                  Text('Almacén: ${conteoText(articuloPendienteItem, ['Almacen'])} · Ubicación: ${conteoText(articuloPendienteItem, ['Ubicacion'])}\nExistencia: ${conteoText(articuloPendienteItem, ['ExistenciaReferencia'])} · Capturada: ${conteoText(articuloPendienteItem, ['CantidadCapturada'])}', style: FlutterFlowTheme.of(context).bodySmall),
                                                                if (FFAppState()
                                                                            .TipoDoc ==
                                                                        2 &&
                                                                    ubicaciones
                                                                        .isNotEmpty)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0),
                                                                    child: Text(
                                                                      'Ubicaciones: $ubicaciones',
                                                                      softWrap:
                                                                          true,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.inter(),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            fontSize:
                                                                                11.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            lineHeight:
                                                                                1.35,
                                                                          ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10.0),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                getJsonField(
                                                                  articuloPendienteItem,
                                                                  r'''$.cantidadPendiente''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                              Text(
                                                                'pend.',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      fontSize:
                                                                          10.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              width: 6.0),
                                                          FlutterFlowIconButton(
                                                            borderRadius: 8.0,
                                                            buttonSize: 40.0,
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .warning,
                                                            icon: Icon(
                                                              Icons
                                                                  .add_circle_outline_outlined,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .info,
                                                              size: 24.0,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              await context.pushNamed(
                                                                CapturaArticulosWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  if (FFAppState().TipoDoc == 4) ...{
                                                                    'linea': conteoText(articuloPendienteItem, ['LineNum']),
                                                                    'ubicacion': conteoText(articuloPendienteItem, ['Ubicacion']),
                                                                    'codigoBarras': conteoText(articuloPendienteItem, ['CodigoBarras']),
                                                                    'lote': conteoText(articuloPendienteItem, ['Lote']),
                                                                  },
                                                                  'docEntry':
                                                                      serializeParam(
                                                                    widget
                                                                        .docEntry,
                                                                    ParamType
                                                                        .int,
                                                                  ),
                                                                  'docInterno':
                                                                      serializeParam(
                                                                    widget
                                                                        .docInterno,
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'itemCode':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.itemCode''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'nombreArticulo':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.itemName''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'cantidad':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.cantidadPendiente''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'almacen':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.almacen''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'precio':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.precio''',
                                                                    ),
                                                                    ParamType
                                                                        .double,
                                                                  ),
                                                                  'fecha':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      articuloPendienteItem,
                                                                      r'''$.fechaDocumento''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'fromButton':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                              if (mounted && FFAppState().TipoDoc == 4) setState(() {});
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 15.0, 15.0, 15.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(
                                  ArticulosCapturadosWidget.routeName,
                                  queryParameters: {
                                    'docEntry': serializeParam(
                                      widget.docEntry,
                                      ParamType.int,
                                    ),
                                    'docInterno': serializeParam(
                                      widget.docInterno,
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              text: 'Artículos Capturados',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).alternate,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 15.0, 15.0, 15.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                if (_model.checkboxValue!) {
                                  if (almacenDocumento.trim().isNotEmpty) {
                                    FFAppState().almacen =
                                        almacenDocumento.trim();
                                  }
                                  await context.pushNamed(
                                    CapturaRapidaWidget.routeName,
                                    queryParameters: {
                                      'docEntry': serializeParam(
                                        widget.docEntry,
                                        ParamType.int,
                                      ),
                                      'docInterno': serializeParam(
                                        widget.docInterno,
                                        ParamType.String,
                                      ),
                                      'itemCode': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'nombreArticulo': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'cantidad': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'almacen': serializeParam(
                                        almacenDocumento,
                                        ParamType.String,
                                      ),
                                      'precio': serializeParam(
                                        0.0,
                                        ParamType.double,
                                      ),
                                      'fecha': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'fromButton': serializeParam(
                                        false,
                                        ParamType.bool,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  await context.pushNamed(
                                    CapturaArticulosWidget.routeName,
                                    queryParameters: {
                                      'docEntry': serializeParam(
                                        widget.docEntry,
                                        ParamType.int,
                                      ),
                                      'docInterno': serializeParam(
                                        widget.docInterno,
                                        ParamType.String,
                                      ),
                                      'itemCode': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'nombreArticulo': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'cantidad': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'almacen': serializeParam(
                                        almacenDocumento,
                                        ParamType.String,
                                      ),
                                      'precio': serializeParam(
                                        0.0,
                                        ParamType.double,
                                      ),
                                      'fecha': serializeParam(
                                        '',
                                        ParamType.String,
                                      ),
                                      'fromButton': serializeParam(
                                        true,
                                        ParamType.bool,
                                      ),
                                    }.withoutNulls,
                                  );
                                }
                                if (mounted && FFAppState().TipoDoc == 4) setState(() {});
                              },
                              text: 'Captura  General',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).accent1,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(15.0, 15.0,
                                FFAppState().TipoDoc == 2 ? 10.0 : 25.0, 15.0),
                            child: FFButtonWidget(
                              showLoadingIndicator: FFAppState().TipoDoc != 4,
                              onPressed: () async {
                                var shouldSetState = false;
                                if (FFAppState().TipoDoc == 4) {
                                  await _subirConteo();
                                  return;
                                }
                                if (FFAppState().TipoDoc == 2) {
                                  _model.apiResult0ae = await WSInventariosGroup
                                      .procesarDocumentoCall
                                      .call(
                                    docId: widget.docInterno,
                                    comentariosFF: FFAppState().Ubicaciones,
                                  );

                                  shouldSetState = true;
                                  if ((_model.apiResult0ae?.succeeded ??
                                      true)) {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Creado Correctamente'),
                                          content: Text(getJsonField(
                                            (_model.apiResult0ae?.jsonBody ??
                                                ''),
                                            r'''$.descripcion''',
                                          ).toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    FFAppState().Ubicaciones = '';
                                    safeSetState(() {});
                                    FFAppState().MiLista = [];
                                    safeSetState(() {});

                                    context
                                        .pushNamed(PrincipalWidget.routeName);

                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(getJsonField(
                                            (_model.apiResult0ae?.jsonBody ??
                                                ''),
                                            r'''$.descripcion''',
                                          ).toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  }
                                } else {
                                  _model.apiResult0 = await WSInventariosGroup
                                      .procesarDocumentoCall
                                      .call(
                                    docId: widget.docInterno,
                                    comentariosFF: FFAppState().Ubicaciones,
                                  );

                                  shouldSetState = true;
                                  if ((_model.apiResult0?.succeeded ?? true)) {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Creado Correctamente'),
                                          content: Text(getJsonField(
                                            (_model.apiResult0?.jsonBody ?? ''),
                                            r'''$.descripcion''',
                                          ).toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    FFAppState().MiLista = [];
                                    safeSetState(() {});
                                    FFAppState().Ubicaciones = '';
                                    safeSetState(() {});

                                    context
                                        .pushNamed(PrincipalWidget.routeName);

                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(getJsonField(
                                            (_model.apiResult0?.jsonBody ?? ''),
                                            r'''$.descripcion''',
                                          ).toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  }
                                }

                                if (shouldSetState) safeSetState(() {});
                              },
                              text: FFAppState().TipoDoc == 4 ? 'Subir a SAP' : 'Terminar Captura',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).accent3,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        if (FFAppState().TipoDoc == 2)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 15.0, 15.0, 15.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    ListaEmbalajeWidget.routeName,
                                    queryParameters: {
                                      'docEntry': serializeParam(
                                        widget.docEntry,
                                        ParamType.int,
                                      ),
                                      'docInterno': serializeParam(
                                        widget.docInterno,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                text: 'Lista de embalaje',
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: const Color(0xFFF7C49D),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
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
        );
      },
    );
  }
}
