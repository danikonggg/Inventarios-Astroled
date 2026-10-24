import '/backend/api_requests/api_calls.dart';
import '/custom_code/embalaje_manager.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tipo_paquete_model.dart';
export 'tipo_paquete_model.dart';

class TipoPaqueteWidget extends StatefulWidget {
  const TipoPaqueteWidget({
    super.key,
    required this.docEntry,
    required this.docInterno,
  });

  final int? docEntry;
  final String? docInterno;

  static String routeName = 'TipoPaquete';
  static String routePath = '/tipoPaquete';

  @override
  State<TipoPaqueteWidget> createState() => _TipoPaqueteWidgetState();
}

class _TipoPaqueteWidgetState extends State<TipoPaqueteWidget> {
  late TipoPaqueteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _tipos = [
    {'codigo': 1, 'nombre': 'Caja'},
    {'codigo': 2, 'nombre': 'Contenedor'},
    {'codigo': 3, 'nombre': 'Tarima'},
    {'codigo': 4, 'nombre': 'Bolsa'},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TipoPaqueteModel());
    _model.selectedCodigo = 1;
    _model.selectedNombre = 'Caja';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
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
                          'Tipo Paquete',
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
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
                                  Container(
                                    width: 90.0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            color: Colors.black87, width: 1.0),
                                        bottom: BorderSide(
                                            color: Colors.black87, width: 1.0),
                                      ),
                                    ),
                                    child: Text(
                                      'Codigo',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            fontSize: 14.0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black87, width: 1.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Nombre',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              fontSize: 14.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Data Rows
                            ..._tipos.map((item) {
                              final isSelected =
                                  _model.selectedCodigo == item['codigo'];
                              final rowBg = isSelected
                                  ? const Color(0xFF90CAF9)
                                  : Colors.white;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _model.selectedCodigo = item['codigo'];
                                    _model.selectedNombre = item['nombre'];
                                  });
                                },
                                child: Container(
                                  color: rowBg,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 90.0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 8.0),
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
                                          '${item['codigo']}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                fontSize: 14.0,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 8.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Color(0xFFE0E0E0),
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            '${item['nombre']}',
                                            style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                fontSize: 14.0,
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
                            for (int i = 0; i < 4; i++)
                              Container(
                                height: 32.0,
                                color: i % 2 == 0
                                    ? const Color(0xFFF2F2F2)
                                    : Colors.white,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90.0,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                              color: Colors.black87,
                                              width: 1.0),
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
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
                                  if (_model.selectedNombre == null ||
                                      _model.selectedNombre!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Selecciona un tipo de paquete.'),
                                      ),
                                    );
                                    return;
                                  }
                                  final docId = widget.docInterno ?? '';
                                  if (docId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No hay un documento seleccionado.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  ApiCallResponse? res;
                                  try {
                                    res = await WSInventariosGroup.crearPaqueteCall.call(
                                      docCode: docId,
                                      tipoDocumento: '2',
                                    );
                                  } catch (e) {
                                    if (kDebugMode) {
                                      debugPrint('❌ Error creando paquete: $e');
                                    }
                                  }

                                  if (res == null || !res.isEmbalajeSuccess) {
                                    final msg = res?.embalajeDescripcion ??
                                        'Error al crear la caja en el servidor.';
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final int? serverPackageNum = castToType<int>(
                                          getJsonField(res.jsonBody, r'''$.valores.packageNum''')) ??
                                      castToType<int>(
                                          getJsonField(res.jsonBody, r'''$.packageNum'''));

                                  EmbalajeManager().addPaquete(
                                    docId,
                                    _model.selectedNombre ?? 'Caja',
                                    'Piezas',
                                    serverPackageNum,
                                  );

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Caja #${serverPackageNum ?? 1} creada correctamente.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  context.safePop();
                                },
                                text: 'Agregar',
                                options: FFButtonOptions(
                                  height: 44.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
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
                                  context.safePop();
                                },
                                text: 'Cancelar',
                                options: FFButtonOptions(
                                  height: 44.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  color: const Color(0xFF9E9E9E),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.black87,
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
          ),
        ),
      ),
    );
  }
}
