import '/backend/api_requests/api_load_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detalle_orden_v_model.dart';
export 'detalle_orden_v_model.dart';

class DetalleOrdenVWidget extends StatefulWidget {
  const DetalleOrdenVWidget({
    super.key,
    required this.docEntry,
  });

  final int? docEntry;

  static String routeName = 'DetalleOrdenV';
  static String routePath = '/detalleOrdenV';

  @override
  State<DetalleOrdenVWidget> createState() => _DetalleOrdenVWidgetState();
}

class _DetalleOrdenVWidgetState extends State<DetalleOrdenVWidget> {
  late DetalleOrdenVModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetalleOrdenVModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 18.0,
        ),
        const SizedBox(width: 10.0),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 11.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: WSInventariosGroup.obtenerDetalleOrdenVCall.call(
        docEntry: widget.docEntry,
      ),
      builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: () => setState(() {}), fullScreen: true);
        if (loadState != null) return loadState;
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
        final detalleOrdenVObtenerDetalleOrdenVResponse = snapshot.data!;
        final docNum = getJsonField(
          detalleOrdenVObtenerDetalleOrdenVResponse.jsonBody,
          r'''$.docNum''',
        ).toString();
        final docDate = getJsonField(
          detalleOrdenVObtenerDetalleOrdenVResponse.jsonBody,
          r'''$.docDate''',
        ).toString();
        final cardName = getJsonField(
          detalleOrdenVObtenerDetalleOrdenVResponse.jsonBody,
          r'''$.cardName''',
        ).toString();
        final detalle = (getJsonField(
              detalleOrdenVObtenerDetalleOrdenVResponse.jsonBody,
              r'''$.lineas''',
            ) as List?) ??
            [];

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
                      font: GoogleFonts.readexPro(fontWeight: FontWeight.w600),
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .tertiary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.call_made_rounded,
                                      color: FlutterFlowTheme.of(context).tertiary,
                                      size: 14.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      'Orden de Venta',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                            color:
                                                FlutterFlowTheme.of(context).tertiary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '#$docNum',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  font:
                                      GoogleFonts.readexPro(fontWeight: FontWeight.bold),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 14.0),
                          _buildInfoRow(
                            context,
                            icon: Icons.event_outlined,
                            label: 'Fecha',
                            value: docDate,
                          ),
                          const SizedBox(height: 10.0),
                          _buildInfoRow(
                            context,
                            icon: Icons.person_outline,
                            label: 'Cliente',
                            value: cardName,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Artículos',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${detalle.length}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: detalle.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 48.0,
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Sin artículos',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                            scrollDirection: Axis.vertical,
                            itemCount: detalle.length,
                            itemBuilder: (context, detalleIndex) {
                              final detalleItem = detalle[detalleIndex];
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 3.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                      child: Text(
                                        getJsonField(
                                          detalleItem,
                                          r'''$.itemCode''',
                                        ).toString(),
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      getJsonField(
                                        detalleItem,
                                        r'''$.descripcion''',
                                      ).toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStat(
                                            context,
                                            'Cantidad',
                                            getJsonField(
                                              detalleItem,
                                              r'''$.cantidad''',
                                            ).toString(),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildStat(
                                            context,
                                            'Pendiente',
                                            getJsonField(
                                              detalleItem,
                                              r'''$.cantidadPendiente''',
                                            ).toString(),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildStat(
                                            context,
                                            'Precio',
                                            getJsonField(
                                              detalleItem,
                                              r'''$.precio''',
                                            ).toString(),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildStat(
                                            context,
                                            'Almacén',
                                            getJsonField(
                                              detalleItem,
                                              r'''$.almacen''',
                                            ).toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
