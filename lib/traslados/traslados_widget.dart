import 'traslado_design.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_load_state.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'traslados_model.dart';
export 'traslados_model.dart';

class TrasladosWidget extends StatefulWidget {
  const TrasladosWidget({super.key});

  static String routeName = 'Traslados';
  static String routePath = '/traslados';

  @override
  State<TrasladosWidget> createState() => _TrasladosWidgetState();
}

class _TrasladosWidgetState extends State<TrasladosWidget>
    with SingleTickerProviderStateMixin {
  late TrasladosModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _solicitudesScrollController = ScrollController();

  String _filtroDocEntry = '';
  String _filtroFechaDesde = '';
  String _filtroFechaHasta = '';

  Key _solicitudesKey = UniqueKey();
  Key _capturasKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrasladosModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 1,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.docEntryFilterController ??= TextEditingController();
    _model.docEntryFilterFocusNode ??= FocusNode();

    _model.fechaDesdeController ??= TextEditingController();
    _model.fechaDesdeFocusNode ??= FocusNode();

    _model.fechaHastaController ??= TextEditingController();
    _model.fechaHastaFocusNode ??= FocusNode();

    _model.comentariosController ??= TextEditingController();
    _model.comentariosFocusNode ??= FocusNode();

    _model.fechaCapturaController ??= TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _model.fechaCapturaFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (functions.tieneModulo(FFAppState().modulosUsuario, 'TRA') != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No tienes permisos para acceder al módulo de Traslados.',
              style: TextStyle(color: FlutterFlowTheme.of(context).info),
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
            duration: const Duration(seconds: 3),
          ),
        );
        context.pushNamed(PrincipalWidget.routeName);
      }
    });
  }

  @override
  void dispose() {
    _solicitudesScrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _recargarSolicitudes() {
    safeSetState(() {
      _filtroDocEntry = _model.docEntryFilterController?.text.trim() ?? '';
      _filtroFechaDesde = _model.fechaDesdeController?.text.trim() ?? '';
      _filtroFechaHasta = _model.fechaHastaController?.text.trim() ?? '';
      _solicitudesKey = UniqueKey();
    });
  }

  void _limpiarFiltros() {
    safeSetState(() {
      _model.docEntryFilterController?.clear();
      _model.fechaDesdeController?.clear();
      _model.fechaHastaController?.clear();
      _filtroDocEntry = '';
      _filtroFechaDesde = '';
      _filtroFechaHasta = '';
      _solicitudesKey = UniqueKey();
    });
  }

  void _recargarCapturas() {
    safeSetState(() {
      _capturasKey = UniqueKey();
    });
  }

  Future<void> _seleccionarFecha(
      BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: FlutterFlowTheme.of(context).primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      safeSetState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'It One - Inventarios Móviles',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.readexPro(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          elevation: 2.0,
        ),
        body: _buildTabSolicitudes(),
      ),
    );
  }

  // ==========================================
  // TAB 1: SOLICITUDES TRASLADO DISPONIBLES
  // ==========================================
  Widget _buildTabSolicitudes() {
    final theme = FlutterFlowTheme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.alternate),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 6,
                    color: Color(0x1B090F13),
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Nuevo Traslado de Mercancía',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)),
                ),
                TextFormField(
                    controller: _model.docEntryFilterController,
                    focusNode: _model.docEntryFilterFocusNode,
                    decoration: trasladoField(context, 'ID de solicitud',
                        hint: 'Escribe el ID',
                        suffix: IconButton(
                            tooltip: 'Buscar solicitud',
                            onPressed: _recargarSolicitudes,
                            icon: const Icon(Icons.search))),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _recargarSolicitudes()),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _model.fechaDesdeController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(
                              context, _model.fechaDesdeController!),
                          decoration: trasladoField(context, 'Desde',
                              suffix:
                                  const Icon(Icons.calendar_today, size: 18)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextFormField(
                          controller: _model.fechaHastaController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(
                              context, _model.fechaHastaController!),
                          decoration: trasladoField(context, 'Hasta',
                              suffix:
                                  const Icon(Icons.calendar_today, size: 18)))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: TextButton(
                          onPressed: _limpiarFiltros,
                          child: const Text('Limpiar filtros'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: trasladoButton(
                          context, 'Buscar', _recargarSolicitudes)),
                ]),
                const SizedBox(height: 10),
                FutureBuilder<ApiCallResponse>(
                  key: _solicitudesKey,
                  future: WSInventariosGroup.solicitudesTrasladoCall.call(
                    usuario: FFAppState().idUsuario,
                    docEntry: _filtroDocEntry,
                    fechaDesde: _filtroFechaDesde,
                    fechaHasta: _filtroFechaHasta,
                  ),
                  builder: (context, snapshot) {
                    final loadState = apiLoadState(snapshot, onRetry: _recargarSolicitudes);
                    if (loadState != null) return loadState;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 45.0,
                          height: 45.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 48.0),
                              const SizedBox(height: 12.0),
                              Text(
                                'Error al consultar solicitudes',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                              const SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: _recargarSolicitudes,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final response = snapshot.data!;
                    final responseBody = response.jsonBody;

                    // Obtener lista de solicitudes desde Resultado.Valores
                    List solicitudes = [];
                    if (responseBody is Map &&
                        responseBody.containsKey('valores')) {
                      final v = responseBody['valores'];
                      if (v is List) solicitudes = v;
                    } else if (responseBody is List) {
                      solicitudes = responseBody;
                    }

                    if (solicitudes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 56.0),
                              const SizedBox(height: 16.0),
                              Text(
                                'No hay solicitudes disponibles',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.readexPro(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'No se encontraron solicitudes de traslado abiertas con líneas pendientes.',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 280,
                      child: Scrollbar(
                        controller: _solicitudesScrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _solicitudesScrollController,
                          primary: false,
                          padding: const EdgeInsets.only(right: 10),
                          itemCount: solicitudes.length,
                          itemBuilder: (context, index) {
                            final item = solicitudes[index];
                            final docNum = getJsonField(item, r'''$.docNum''')
                                    ?.toString() ??
                                getJsonField(item, r'''$.DocNum''')
                                    ?.toString() ??
                                '-';
                            final docEntry = int.tryParse(
                                (getJsonField(item, r'''$.docEntry''') ??
                                        getJsonField(item, r'''$.DocEntry''') ??
                                        '')
                                    .toString());
                            final fecha =
                                (getJsonField(item, r'''$.docDate''') ??
                                        getJsonField(item, r'''$.DocDate''') ??
                                        getJsonField(item, r'''$.fecha''') ??
                                        '')
                                    .toString();
                            final socio =
                                (getJsonField(item, r'''$.cardName''') ??
                                        getJsonField(item, r'''$.CardName''') ??
                                        getJsonField(item, r'''$.socio''') ??
                                        getJsonField(item, r'''$.Socio''') ??
                                        '')
                                    .toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.alternate),
                              ),
                              child: Row(children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(children: [
                                      Flexible(
                                          child: Text(docNum,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.bodyMedium.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              DateTime.tryParse(fecha) == null
                                                  ? fecha
                                                  : DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          fecha)),
                                              textAlign: TextAlign.end,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.bodySmall.copyWith(
                                                  color: theme.secondaryText))),
                                    ]),
                                    if (socio.trim().isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(socio,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.bodySmall.copyWith(
                                              color: theme.secondaryText)),
                                    ],
                                  ],
                                )),
                                const SizedBox(width: 8),
                                FFButtonWidget(
                                  text: 'Usar',
                                  options: FFButtonOptions(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    color: theme.secondary,
                                    textStyle: theme.titleSmall
                                        .copyWith(color: Colors.white),
                                    elevation: 0,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  onPressed: docEntry == null
                                      ? null
                                      : () => _mostrarDetalleSolicitud(
                                          docEntry, docNum),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: CONTINUAR CAPTURA (ABIERTAS)
  // ==========================================
  Widget _buildTabCapturasAbiertas() {
    return FutureBuilder<ApiCallResponse>(
      key: _capturasKey,
      future: WSInventariosGroup.documentosAbiertosCall.call(
        tipo: 3,
        usuario: FFAppState().idUsuario,
      ),
      builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: () => setState(() {}));
        if (loadState != null) return loadState;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 45.0,
              height: 45.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: FlutterFlowTheme.of(context).error, size: 48.0),
                  const SizedBox(height: 12.0),
                  Text(
                    'Error al consultar capturas abiertas',
                    style: FlutterFlowTheme.of(context).titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _recargarCapturas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final response = snapshot.data!;
        final responseBody = response.jsonBody;

        List capturas = [];
        if (responseBody is List) {
          capturas = responseBody;
        } else if (responseBody is Map &&
            responseBody.containsKey('valores') &&
            responseBody['valores'] is List) {
          capturas = responseBody['valores'];
        }

        if (capturas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 56.0),
                  const SizedBox(height: 16.0),
                  Text(
                    'No tienes capturas abiertas',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.readexPro(
                            fontWeight: FontWeight.w600,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Inicia una nueva captura desde la pestaña "Nueva transferencia".',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _recargarCapturas(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: capturas.length,
            itemBuilder: (context, index) {
              final item = capturas[index];
              final code = getJsonField(item, r'''$.code''')?.toString() ?? '';
              final referencia =
                  getJsonField(item, r'''$.referencia''')?.toString() ?? '-';
              final baseEntry =
                  castToType<int>(getJsonField(item, r'''$.baseEntry''')) ?? 0;
              final fecha =
                  getJsonField(item, r'''$.fecha''')?.toString() ?? '';
              final almacenO =
                  getJsonField(item, r'''$.almacenO''')?.toString() ??
                      getJsonField(item, r'''$.almacen''')?.toString() ??
                      '';
              final almacenD =
                  getJsonField(item, r'''$.almacenD''')?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(
                                  Icons.lock_open_rounded,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 20.0,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Captura #$code',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.readexPro(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Chip(
                            label: Text(
                              'Solicitud: $referencia',
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            backgroundColor: FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.08),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const Divider(height: 16.0),
                      Row(
                        children: [
                          if (almacenO.isNotEmpty)
                            Expanded(
                              child: Text(
                                'Orig: $almacenO',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ),
                          if (almacenD.isNotEmpty)
                            Expanded(
                              child: Text(
                                'Dest: $almacenD',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ),
                          if (fecha.isNotEmpty)
                            Text(
                              fecha,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FFButtonWidget(
                          onPressed: () async {
                            // Reanudar captura sin llamar DocumentoNuevo
                            context.pushNamed(
                              CapturaTrasladoWidget.routeName,
                              queryParameters: {
                                'docCode':
                                    serializeParam(code, ParamType.String),
                                'docEntry':
                                    serializeParam(baseEntry, ParamType.int),
                                'docNum': serializeParam(
                                    referencia, ParamType.String),
                              }.withoutNulls,
                            );
                          },
                          text: 'Continuar captura',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600),
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 1.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================
  // DETALLE Y CREACIÓN DE CAPTURA
  // ==========================================
  void _abrirTrasladosEnPrincipal() {
    FFAppState().update(() {
      FFAppState().TipoDoc = 3;
      FFAppState().NombrePrincipal = 'Documentos abiertos Traslado';
    });
    context.pushNamed(PrincipalWidget.routeName);
  }

  void _mostrarDetalleSolicitud(int docEntry, String docNum) {
    showDialog(
      context: context,
      builder: (sheetContext) {
        return Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                title: Text('It One - Inventarios Móviles',
                    style: FlutterFlowTheme.of(context)
                        .titleMedium
                        .copyWith(color: Colors.white)),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(sheetContext))),
            body: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
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
              child: FutureBuilder<ApiCallResponse>(
                future: WSInventariosGroup.obtenerDetalleSolicitudTrasladoCall
                    .call(docEntry: docEntry),
                builder: (context, snapshot) {
                  final loadState = apiLoadState(snapshot, onRetry: () {
                    Navigator.of(sheetContext).pop();
                    _mostrarDetalleSolicitud(docEntry, docNum);
                  });
                  if (loadState != null) return loadState;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        width: 45.0,
                        height: 45.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data!.succeeded) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error al obtener el detalle de la solicitud.',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                      ),
                    );
                  }

                  final detalleResponse = snapshot.data!;
                  final valores = getJsonField(
                    detalleResponse.jsonBody,
                    r'''$.valores''',
                  );

                  final folio =
                      getJsonField(valores, r'''$.docNum''')?.toString() ??
                          docNum;
                  final comentarios =
                      getJsonField(valores, r'''$.comentarios''')?.toString() ??
                          '';
                  final lineas = getJsonField(
                        valores,
                        r'''$.lineas''',
                        true,
                      ) as List? ??
                      [];
                  final primeraLinea = lineas.isNotEmpty ? lineas.first : null;
                  final almacenOrigen =
                      (getJsonField(valores, r'''$.almacenO''') ??
                              getJsonField(valores, r'''$.AlmacenO''') ??
                              getJsonField(primeraLinea, r'''$.almacenO''') ??
                              getJsonField(primeraLinea, r'''$.AlmacenO''') ??
                              '')
                          .toString();
                  final almacenDestino =
                      (getJsonField(valores, r'''$.almacenD''') ??
                              getJsonField(valores, r'''$.AlmacenD''') ??
                              getJsonField(primeraLinea, r'''$.almacenD''') ??
                              getJsonField(primeraLinea, r'''$.AlmacenD''') ??
                              '')
                          .toString();

                  return StatefulBuilder(
                    builder: (modalContext, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            // Encabezado
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Solicitud #$folio',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            fontSize: 18,
                                            decoration:
                                                TextDecoration.underline,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    Text(
                                      'DocEntry: $docEntry',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(sheetContext),
                                ),
                              ],
                            ),
                            if (comentarios.isNotEmpty) ...[
                              const SizedBox(height: 8.0),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  'Comentarios: $comentarios',
                                  style: FlutterFlowTheme.of(context).bodySmall,
                                ),
                              ),
                            ],
                            const SizedBox(height: 14.0),
                            Text(
                              'Artículos de la solicitud (${lineas.length} líneas):',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),

                            // Tabla / Lista de líneas
                            ...lineas.map((linea) {
                              final lineNum =
                                  getJsonField(linea, r'''$.lineNum''') ??
                                      getJsonField(linea, r'''$.LineNum''') ??
                                      0;
                              final itemCode =
                                  getJsonField(linea, r'''$.itemCode''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.ItemCode''')
                                          ?.toString() ??
                                      '';
                              final descripcion =
                                  getJsonField(linea, r'''$.descripcion''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.itemName''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.ItemName''')
                                          ?.toString() ??
                                      '';
                              final cantidad =
                                  getJsonField(linea, r'''$.cantidad''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.Cantidad''')
                                          ?.toString() ??
                                      '0';
                              final pendiente = getJsonField(
                                          linea, r'''$.cantidadPendiente''')
                                      ?.toString() ??
                                  getJsonField(
                                          linea, r'''$.CantidadPendiente''')
                                      ?.toString() ??
                                  '0';
                              final almO =
                                  getJsonField(linea, r'''$.almacenO''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.AlmacenO''')
                                          ?.toString() ??
                                      '-';
                              final almD =
                                  getJsonField(linea, r'''$.almacenD''')
                                          ?.toString() ??
                                      getJsonField(linea, r'''$.AlmacenD''')
                                          ?.toString() ??
                                      '-';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.all(14.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Línea $lineNum: $itemCode',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Text(
                                          'Pend: $pendiente / $cantidad',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (descripcion.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                          descripcion,
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Text('Alm. Origen: $almO',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall),
                                        const SizedBox(width: 16.0),
                                        Text('Alm. Destino: $almD',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 16.0),
                            const Divider(),
                            Text(
                              'Datos para iniciar captura:',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),

                            // Campo Fecha
                            InkWell(
                              onTap: () => _seleccionarFecha(
                                  sheetContext, _model.fechaCapturaController!),
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: _model.fechaCapturaController,
                                  decoration: InputDecoration(
                                    labelText: 'Fecha de captura',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    isDense: true,
                                    suffixIcon: const Icon(Icons.calendar_today,
                                        size: 18.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Campo Comentarios
                            TextFormField(
                              controller: _model.comentariosController,
                              focusNode: _model.comentariosFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Comentarios de captura',
                                hintText: 'Opcional',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                isDense: true,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16.0),

                            // Botón Iniciar Captura
                            FFButtonWidget(
                              onPressed: _model.isCreatingCapture
                                  ? null
                                  : () async {
                                      setModalState(() {
                                        _model.isCreatingCapture = true;
                                      });
                                      safeSetState(() {});

                                      try {
                                        final fecha = _model
                                                    .fechaCapturaController
                                                    ?.text
                                                    .trim()
                                                    .isNotEmpty ==
                                                true
                                            ? _model
                                                .fechaCapturaController!.text
                                                .trim()
                                            : DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now());
                                        final comentariosText = _model
                                                .comentariosController?.text
                                                .trim() ??
                                            '';

                                        final response =
                                            await WSInventariosGroup
                                                .documentoNuevoCall
                                                .call(
                                          documento: '3',
                                          estado: 'N',
                                          fecha: fecha,
                                          usuario: FFAppState().idUsuario,
                                          almacen0: almacenOrigen,
                                          almacenD: almacenDestino,
                                          referencia: folio,
                                          baseType: '1250000001',
                                          baseEntry: docEntry.toString(),
                                          comentarios: comentariosText,
                                        );

                                        if (response.succeeded &&
                                            (WSInventariosGroup.loginCall
                                                    .respuestaError(
                                                        response.jsonBody) !=
                                                true)) {
                                          final docInterno = getJsonField(
                                                response.jsonBody,
                                                r'''$.documentoInterno''',
                                              )?.toString() ??
                                              getJsonField(
                                                response.jsonBody,
                                                r'''$.DocumentoInterno''',
                                              )?.toString() ??
                                              getJsonField(
                                                response.jsonBody,
                                                r'''$.valores''',
                                              )?.toString() ??
                                              '';

                                          if (docInterno.isEmpty) {
                                            throw StateError(
                                                'La API no devolvió el código de la captura.');
                                          }

                                          if (!sheetContext.mounted ||
                                              !context.mounted) {
                                            return;
                                          }

                                          Navigator.pop(sheetContext);

                                          _abrirTrasladosEnPrincipal();
                                        } else {
                                          if (!sheetContext.mounted) return;

                                          final desc = getJsonField(
                                                response.jsonBody,
                                                r'''$.descripcion''',
                                              )?.toString() ??
                                              response.response?.body ??
                                              'No se pudo crear la captura.';

                                          await showDialog(
                                            context: sheetContext,
                                            builder: (diagContext) =>
                                                AlertDialog(
                                              title: const Text('Aviso'),
                                              content: Text(desc),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(diagContext);
                                                    Navigator.pop(sheetContext);
                                                    _abrirTrasladosEnPrincipal();
                                                  },
                                                  child: const Text(
                                                      'Ver capturas abiertas'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          diagContext),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (sheetContext.mounted) {
                                          ScaffoldMessenger.of(sheetContext)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'No se pudo iniciar la captura: $e'),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                          ));
                                        }
                                      } finally {
                                        if (sheetContext.mounted) {
                                          setModalState(() {
                                            _model.isCreatingCapture = false;
                                          });
                                        }
                                        if (mounted) safeSetState(() {});
                                      }
                                    },
                              text: _model.isCreatingCapture
                                  ? 'Creando captura...'
                                  : 'Crear traslado',
                              options: FFButtonOptions(
                                height: 44.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
