import '/backend/api_requests/api_load_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/custom_code/embalaje_manager.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detalle_paquete_model.dart';
export 'detalle_paquete_model.dart';

class DetallePaqueteWidget extends StatefulWidget {
  const DetallePaqueteWidget({
    super.key,
    required this.docEntry,
    required this.docInterno,
    required this.numeroPaquete,
  });

  final int? docEntry;
  final String? docInterno;
  final int? numeroPaquete;

  static String routeName = 'DetallePaquete';
  static String routePath = '/detallePaquete';

  @override
  State<DetallePaqueteWidget> createState() => _DetallePaqueteWidgetState();
}

class _DetallePaqueteWidgetState extends State<DetallePaqueteWidget> {
  late DetallePaqueteModel _model;
  late ScrollController _disponiblesScrollController;
  late ScrollController _contenidoScrollController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetallePaqueteModel());
    _disponiblesScrollController = ScrollController();
    _contenidoScrollController = ScrollController();
  }

  @override
  void dispose() {
    _disponiblesScrollController.dispose();
    _contenidoScrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docId = widget.docInterno ?? '';
    final numPaq = widget.numeroPaquete ?? 1;

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
          child: FutureBuilder<List<ApiCallResponse>>(
            future: Future.wait([
              WSInventariosGroup.articulosDisponiblesEmbalajeCall.call(
                docCode: widget.docInterno,
              ),
              WSInventariosGroup.contenidoPaqueteCall.call(
                docCode: widget.docInterno,
                packageNum: numPaq,
              ),
            ]),
            builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: () => setState(() {}), fullScreen: false);
        if (loadState != null) return loadState;
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }

              final disponiblesResponse = snapshot.data![0];
              final contenidoResponse = snapshot.data![1];

              // Parsear disponibles desde backend
              final List<Map<String, dynamic>> disponiblesList = [];
              final rawDisponibles = (getJsonField(
                    disponiblesResponse.jsonBody,
                    r'''$.valores''',
                    true,
                  ) as List?) ??
                  (disponiblesResponse.jsonBody is List
                      ? disponiblesResponse.jsonBody as List
                      : []);

              for (final raw in rawDisponibles) {
                final itemCode = (getJsonField(raw, r'''$.itemCode''') ??
                        getJsonField(raw, r'''$.codigoArticulo'''))
                    ?.toString()
                    .trim();
                final nombre = (getJsonField(raw, r'''$.nombre''') ??
                            getJsonField(raw, r'''$.descripcion'''))
                        ?.toString()
                        .trim() ??
                    '';
                final double disponible = double.tryParse(
                        getJsonField(raw, r'''$.disponible''')?.toString() ??
                            getJsonField(raw, r'''$.cantidad''')?.toString() ??
                            getJsonField(raw, r'''$.cantidadPendiente''')
                                ?.toString() ??
                            '0') ??
                    0.0;
                final int uomEntry = int.tryParse(
                        getJsonField(raw, r'''$.uomEntry''')?.toString() ??
                            '0') ??
                    0;

                if (itemCode != null && itemCode.isNotEmpty && disponible > 0) {
                  disponiblesList.add({
                    'itemCode': itemCode,
                    'nombre': nombre,
                    'disponible': disponible,
                    'uomEntry': uomEntry,
                  });
                }
              }

              // Parsear contenido desde backend
              final List<Map<String, dynamic>> contenidoList = [];
              final dynamic valoresContenido = getJsonField(
                contenidoResponse.jsonBody,
                r'''$.valores''',
              );

              final List rawContenido = (getJsonField(
                    valoresContenido,
                    r'''$.articulos''',
                    true,
                  ) as List?) ??
                  (valoresContenido is List
                      ? valoresContenido
                      : (contenidoResponse.jsonBody is List
                          ? contenidoResponse.jsonBody as List
                          : []));

              for (final raw in rawContenido) {
                final itemCode = (getJsonField(raw, r'''$.itemCode''') ??
                        getJsonField(raw, r'''$.codigoArticulo'''))
                    ?.toString()
                    .trim();
                final nombre = (getJsonField(raw, r'''$.nombre''') ??
                            getJsonField(raw, r'''$.descripcion'''))
                        ?.toString()
                        .trim() ??
                    '';
                final double cantidad = double.tryParse(
                        getJsonField(raw, r'''$.cantidad''')?.toString() ??
                            '0') ??
                    0.0;
                final int codeLinea = int.tryParse(
                        getJsonField(raw, r'''$.codeLinea''')?.toString() ??
                            getJsonField(raw, r'''$.lineNum''')?.toString() ??
                            getJsonField(raw, r'''$.linea''')?.toString() ??
                            '0') ??
                    0;

                if (itemCode != null && itemCode.isNotEmpty) {
                  contenidoList.add({
                    'itemCode': itemCode,
                    'nombre': nombre,
                    'cantidad': cantidad,
                    'codeLinea': codeLinea,
                  });
                }
              }

              // Sincronizar fallback con EmbalajeManager si el backend aún no tiene datos
              if (disponiblesList.isEmpty && contenidoList.isEmpty) {
                final paquete = EmbalajeManager().getPaquete(docId, numPaq);
                final Map<String, double> localContenido =
                    paquete?.articulos ?? <String, double>{};
                localContenido.forEach((k, v) {
                  contenidoList.add({
                    'itemCode': k,
                    'nombre': paquete?.nombres[k] ?? '',
                    'cantidad': v,
                    'codeLinea': 0,
                  });
                });
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
                          // 1. Articulos disponibles Header
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 8.0),
                            child: Text(
                              'Artículos disponibles',
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                          // Table 1: Disponibles
                          Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  color: const Color(0xFFC4C4C4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
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
                                            'Artículo',
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
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Disponible',
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
                                    ],
                                  ),
                                ),
                                // Table List
                                Expanded(
                                  child: Scrollbar(
                                    controller: _disponiblesScrollController,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      controller: _disponiblesScrollController,
                                      padding: EdgeInsets.zero,
                                      itemCount: disponiblesList.length > 3
                                          ? disponiblesList.length
                                          : 4,
                                      itemBuilder: (context, index) {
                                        if (index >= disponiblesList.length) {
                                          return Container(
                                            height: 28.0,
                                            color: index % 2 == 0
                                                ? const Color(0xFFF7F7F7)
                                                : Colors.white,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Expanded(
                                                    flex: 5, child: SizedBox()),
                                              ],
                                            ),
                                          );
                                        }

                                        final item = disponiblesList[index];
                                        final isSelected =
                                            _model.selectedItemDisponible ==
                                                item['itemCode'];
                                        final rowColor = isSelected
                                            ? const Color(0xFF90CAF9)
                                            : (index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF7F7F7));

                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _model.selectedItemDisponible =
                                                  item['itemCode'];
                                              _model.selectedItemDisponibleNombre =
                                                  item['nombre'];
                                              _model.selectedItemMaxDisponible =
                                                  (item['disponible'] as num)
                                                      .toDouble();
                                              _model.selectedUomEntry =
                                                  item['uomEntry'] as int?;
                                            });
                                          },
                                          child: Container(
                                            color: rowColor,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            width: 1.0),
                                                        bottom: BorderSide(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${item['itemCode']}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            fontSize: 13.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${(item['disponible'] as num).toStringAsFixed(0)}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            fontSize: 13.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14.0),

                          // Middle Transfer Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Quantity Input
                              Container(
                                width: 90.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black87,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: TextFormField(
                                  controller: _model.cantidadController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        fontSize: 15.0,
                                      ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              // Down Arrow Button (Assign to package)
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final double qty = double.tryParse(
                                            _model.cantidadController?.text ??
                                                '0') ??
                                        0.0;
                                    if (_model.selectedItemDisponible == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Selecciona un artículo disponible primero.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (qty <= 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Ingresa una cantidad mayor a 0.'),
                                        ),
                                      );
                                      return;
                                    }
                                    final maxDispon =
                                        _model.selectedItemMaxDisponible ?? 0.0;

                                    if (kDebugMode) {
                                      debugPrint(
                                          '⬇️ [DetallePaquete] Transfiriendo artículo al paquete #$numPaq: itemCode=${_model.selectedItemDisponible}, qty=$qty, uomEntry=${_model.selectedUomEntry}');
                                    }

                                    try {
                                      final addRes = await WSInventariosGroup
                                          .agregarArticuloPaqueteCall
                                          .call(
                                        docCode: docId,
                                        packageNum: numPaq,
                                        itemCode: _model.selectedItemDisponible,
                                        uomEntry: _model.selectedUomEntry ?? 0,
                                        cantidad: qty,
                                      );

                                      if (!addRes.isEmbalajeSuccess) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(addRes
                                                      .embalajeDescripcion
                                                      .isNotEmpty
                                                  ? addRes.embalajeDescripcion
                                                  : 'Error al agregar artículo a la caja.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error de conexión al agregar artículo: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    EmbalajeManager().transferToPackage(
                                      docInterno: docId,
                                      numeroPaquete: numPaq,
                                      itemCode: _model.selectedItemDisponible!,
                                      itemName:
                                          _model.selectedItemDisponibleNombre,
                                      cantidad: qty,
                                      maxDisponible: maxDispon,
                                    );

                                    setState(() {
                                      _model.selectedItemDisponible = null;
                                      _model.selectedItemDisponibleNombre =
                                          null;
                                      _model.selectedItemMaxDisponible = null;
                                      _model.selectedUomEntry = null;
                                      _model.cantidadController?.clear();
                                    });
                                  },
                                  child: Container(
                                    height: 38.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      border: Border.all(
                                          color: Colors.black87, width: 1.0),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              // Up Arrow Button (Remove from package)
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final double qty = double.tryParse(
                                            _model.cantidadController?.text ??
                                                '0') ??
                                        0.0;
                                    if (_model.selectedItemContenido == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Selecciona un artículo del paquete primero.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (qty <= 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Ingresa una cantidad mayor a 0.'),
                                        ),
                                      );
                                      return;
                                    }

                                    if (kDebugMode) {
                                      debugPrint(
                                          '⬆️ [DetallePaquete] Removiendo artículo del paquete #$numPaq: itemCode=${_model.selectedItemContenido}, qty=$qty, codeLinea=${_model.selectedItemContenidoCodeLinea}');
                                    }

                                    try {
                                      final ApiCallResponse quitRes;
                                      if (_model.selectedItemContenidoCodeLinea !=
                                              null &&
                                          _model.selectedItemContenidoCodeLinea! >
                                              0) {
                                        quitRes = await WSInventariosGroup
                                            .eliminarArticuloPaqueteCall
                                            .call(
                                          docCode: docId,
                                          packageNum: numPaq,
                                          codeLinea: _model
                                                  .selectedItemContenidoCodeLinea ??
                                              0,
                                        );
                                      } else {
                                        quitRes = await WSInventariosGroup
                                            .quitarCantidadPaqueteCall
                                            .call(
                                          docCode: docId,
                                          packageNum: numPaq,
                                          itemCode:
                                              _model.selectedItemContenido,
                                          cantidad: qty,
                                        );
                                      }

                                      if (!quitRes.isEmbalajeSuccess) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(quitRes
                                                      .embalajeDescripcion
                                                      .isNotEmpty
                                                  ? quitRes.embalajeDescripcion
                                                  : 'Error al retirar artículo del paquete.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error de conexión al remover artículo: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    EmbalajeManager().transferFromPackage(
                                      docInterno: docId,
                                      numeroPaquete: numPaq,
                                      itemCode: _model.selectedItemContenido!,
                                      cantidad: qty,
                                    );

                                    setState(() {
                                      _model.selectedItemContenido = null;
                                      _model.selectedItemContenidoCantidad =
                                          null;
                                      _model.selectedItemContenidoCodeLinea =
                                          null;
                                      _model.cantidadController?.clear();
                                    });
                                  },
                                  child: Container(
                                    height: 38.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      border: Border.all(
                                          color: Colors.black87, width: 1.0),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.keyboard_arrow_up,
                                        color: Colors.white,
                                        size: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),

                          // 2. Contenido paquete Header with Badge
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Contenido paquete',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC4C4C4),
                                    border: Border.all(
                                      color: Colors.black87,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    '$numPaq',
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
                              ],
                            ),
                          ),

                          // Table 2: Contenido
                          Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  color: const Color(0xFFC4C4C4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
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
                                            'Artículo',
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
                                        flex: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black87,
                                                  width: 1.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Cantidad',
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
                                    ],
                                  ),
                                ),
                                // Table List
                                Expanded(
                                  child: Scrollbar(
                                    controller: _contenidoScrollController,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      controller: _contenidoScrollController,
                                      padding: EdgeInsets.zero,
                                      itemCount: contenidoList.length > 3
                                          ? contenidoList.length
                                          : 4,
                                      itemBuilder: (context, index) {
                                        if (index >= contenidoList.length) {
                                          return Container(
                                            height: 28.0,
                                            color: index % 2 == 0
                                                ? const Color(0xFFF7F7F7)
                                                : Colors.white,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Expanded(
                                                    flex: 5, child: SizedBox()),
                                              ],
                                            ),
                                          );
                                        }

                                        final entry = contenidoList[index];
                                        final isSelected =
                                            _model.selectedItemContenido ==
                                                entry['itemCode'];
                                        final rowColor = isSelected
                                            ? const Color(0xFF90CAF9)
                                            : (index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF7F7F7));

                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _model.selectedItemContenido =
                                                  entry['itemCode'] as String?;
                                              _model.selectedItemContenidoCantidad =
                                                  (entry['cantidad'] as num)
                                                      .toDouble();
                                              _model.selectedItemContenidoCodeLinea =
                                                  entry['codeLinea'] as int?;
                                            });
                                          },
                                          child: Container(
                                            color: rowColor,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            width: 1.0),
                                                        bottom: BorderSide(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${entry['itemCode']}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            fontSize: 13.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${(entry['cantidad'] as num).toStringAsFixed(0)}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            fontSize: 13.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
