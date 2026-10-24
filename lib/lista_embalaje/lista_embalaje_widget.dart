import '/backend/api_requests/api_load_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/custom_code/embalaje_manager.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lista_embalaje_model.dart';
export 'lista_embalaje_model.dart';

class ListaEmbalajeWidget extends StatefulWidget {
  const ListaEmbalajeWidget({
    super.key,
    required this.docEntry,
    required this.docInterno,
  });

  final int? docEntry;
  final String? docInterno;

  static String routeName = 'ListaEmbalaje';
  static String routePath = '/listaEmbalaje';

  @override
  State<ListaEmbalajeWidget> createState() => _ListaEmbalajeWidgetState();
}

class _ListaEmbalajeWidgetState extends State<ListaEmbalajeWidget> {
  late ListaEmbalajeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaEmbalajeModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docId = widget.docInterno ?? '';

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
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: FutureBuilder<ApiCallResponse>(
            future: WSInventariosGroup.detallePaquetesCall.call(
              docCode: widget.docInterno,
            ),
            builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: () => setState(() {}), fullScreen: false);
        if (loadState != null) return loadState;
              if (snapshot.hasData) {
                final resp = snapshot.data!;
                if (resp.isEmbalajeSuccess) {
                  final listRaw = (getJsonField(
                            resp.jsonBody,
                            r'''$.valores''',
                            true,
                          ) as List?) ??
                      (resp.jsonBody is List ? resp.jsonBody as List : []);
                  EmbalajeManager().syncFromBackend(docId, listRaw);
                } else if (!resp.succeeded) {
                  // Fallback: intentar con obtenerPaquetes si detallePaquetes falla
                  // o conservar sincronización
                }
              }

              final paquetes = EmbalajeManager().getPaquetes(docId);

              if (_model.selectedNumeroPaquete == null && paquetes.isNotEmpty) {
                _model.selectedNumeroPaquete = paquetes.first.numero;
              } else if (_model.selectedNumeroPaquete != null &&
                  !paquetes.any((p) => p.numero == _model.selectedNumeroPaquete)) {
                _model.selectedNumeroPaquete =
                    paquetes.isNotEmpty ? paquetes.first.numero : null;
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 12.0),
                            child: Text(
                              'Paquetes existentes',
                              style:
                                  FlutterFlowTheme.of(context).bodyLarge.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                            ),
                          ),
                          // Table container
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header Row
                                Container(
                                  color: const Color(0xFFC4C4C4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 4.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            'N° paq',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  fontSize: 13.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 6.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Tipo',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  fontSize: 13.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 6.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Unidad',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  fontSize: 13.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 4.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: const SizedBox(height: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Data Rows
                                ...paquetes.map((item) {
                                  final isSelected =
                                      _model.selectedNumeroPaquete == item.numero;
                                  final rowBg = isSelected
                                      ? const Color(0xFF90CAF9)
                                      : Colors.white;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.selectedNumeroPaquete =
                                            item.numero;
                                      });
                                    },
                                    child: Container(
                                      color: rowBg,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 4.0),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0),
                                                  bottom: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                      width: 1.0),
                                                ),
                                              ),
                                              child: Text(
                                                '${item.numero}',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      fontSize: 13.0,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 6.0),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0),
                                                  bottom: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                      width: 1.0),
                                                ),
                                              ),
                                              child: Text(
                                                item.tipo,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      fontSize: 13.0,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 6.0),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0),
                                                  bottom: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                      width: 1.0),
                                                ),
                                              ),
                                              child: Text(
                                                item.unidad,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      fontSize: 13.0,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 4.0),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                      width: 1.0),
                                                ),
                                              ),
                                              child: Center(
                                                child: InkWell(
                                                  onTap: () async {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (dialogCtx) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Eliminar Paquete'),
                                                        content: Text(
                                                            '¿Deseas eliminar el Paquete N° ${item.numero}?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    dialogCtx,
                                                                    false),
                                                            child: const Text(
                                                                'Cancelar'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    dialogCtx,
                                                                    true),
                                                            child: const Text(
                                                              'Eliminar',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      try {
                                                        final delRes = await WSInventariosGroup
                                                            .eliminarPaqueteCall
                                                            .call(
                                                          docCode: docId,
                                                          packageNum:
                                                              item.numero,
                                                        );
                                                        if (!delRes.isEmbalajeSuccess) {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text(delRes.embalajeDescripcion.isNotEmpty
                                                                    ? delRes.embalajeDescripcion
                                                                    : 'No se pudo eliminar el paquete.'),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                          return;
                                                        }
                                                      } catch (e) {
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('Error de conexión al eliminar: $e'),
                                                              backgroundColor: Colors.red,
                                                            ),
                                                          );
                                                        }
                                                        return;
                                                      }
                                                      setState(() {
                                                        EmbalajeManager()
                                                            .removePaquete(
                                                                docId,
                                                                item.numero);
                                                        if (_model
                                                                .selectedNumeroPaquete ==
                                                            item.numero) {
                                                          _model
                                                              .selectedNumeroPaquete =
                                                              null;
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.black87,
                                                    size: 22.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                // Empty decorative striped rows
                                for (int i = 0;
                                    i <
                                        (paquetes.length < 3
                                            ? (4 - paquetes.length)
                                            : 2);
                                    i++)
                                  Container(
                                    height: 32.0,
                                    color: (paquetes.length + i) % 2 == 0
                                        ? Colors.white
                                        : const Color(0xFFF2F2F2),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black87,
                                                      width: 1.0)),
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          // Action buttons
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      await context.pushNamed(
                                        TipoPaqueteWidget.routeName,
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
                                      setState(() {});
                                    },
                                    text: 'Nuevo',
                                    icon: const Icon(
                                      Icons.add,
                                      size: 20.0,
                                      color: Colors.white,
                                    ),
                                    options: FFButtonOptions(
                                      height: 44.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 16.0, 0.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 6.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                          ),
                                      elevation: 0.0,
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10.0, 0.0, 0.0, 0.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      if (_model.selectedNumeroPaquete == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Selecciona un paquete primero.'),
                                          ),
                                        );
                                        return;
                                      }
                                      await context.pushNamed(
                                        DetallePaqueteWidget.routeName,
                                        queryParameters: {
                                          'docEntry': serializeParam(
                                            widget.docEntry,
                                            ParamType.int,
                                          ),
                                          'docInterno': serializeParam(
                                            widget.docInterno,
                                            ParamType.String,
                                          ),
                                          'numeroPaquete': serializeParam(
                                            _model.selectedNumeroPaquete,
                                            ParamType.int,
                                          ),
                                        }.withoutNulls,
                                      );
                                      setState(() {});
                                    },
                                    text: 'Detalle Paquete',
                                    options: FFButtonOptions(
                                      height: 44.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      color: const Color(0xFF9E9E9E),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            color: Colors.black87,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                      elevation: 0.0,
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1.0,
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
                  // Bottom bar
                  Container(
                    width: double.infinity,
                    height: 42.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4C4C4),
                      border: Border(
                        top: BorderSide(color: Colors.black87, width: 1.0),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: InkWell(
                          onTap: () => context.safePop(),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20.0,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
