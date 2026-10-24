import '/custom_code/barcode_quantity.dart';
import 'traslado_design.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_load_state.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'captura_traslado_model.dart';
export 'captura_traslado_model.dart';

class TrasladoArticulo {
  const TrasladoArticulo({
    required this.lineNum,
    required this.itemCode,
    required this.itemName,
    required this.almacenO,
    required this.almacenD,
    required this.pendiente,
  });

  final int lineNum;
  final String itemCode;
  final String itemName;
  final String almacenO;
  final String almacenD;
  final double pendiente;
}

class CapturaTrasladoWidget extends StatefulWidget {
  const CapturaTrasladoWidget({
    super.key,
    required this.docCode,
    required this.docEntry,
    required this.docNum,
    this.articulo,
    this.soloCapturados = false,
  });

  final String? docCode;
  final int? docEntry;
  final String? docNum;
  final TrasladoArticulo? articulo;
  final bool soloCapturados;

  static String routeName = 'CapturaTraslado';
  static String routePath = '/capturaTraslado';

  @override
  State<CapturaTrasladoWidget> createState() => _CapturaTrasladoWidgetState();
}

class _CapturaTrasladoWidgetState extends State<CapturaTrasladoWidget> {
  late CapturaTrasladoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Key _pendientesKey = UniqueKey();
  Key _capturadosKey = UniqueKey();

  Future<ApiCallResponse>? _pendientesFuture;
  Future<ApiCallResponse>? _capturadosFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CapturaTrasladoModel());
    final articulo = widget.articulo;
    if (articulo != null) {
      _model.selectedLineNum = articulo.lineNum;
      _model.selectedItemCode = articulo.itemCode;
      _model.selectedItemName = articulo.itemName;
      _model.selectedAlmacenO = articulo.almacenO;
      _model.selectedAlmacenD = articulo.almacenD;
      _model.selectedPendiente = articulo.pendiente;
    }

    _model.codigoBarrasController ??= TextEditingController();
    _model.codigoBarrasFocusNode ??= FocusNode();

    _model.cantidadController ??= TextEditingController();
    _model.cantidadFocusNode ??= FocusNode();

    _model.loteController ??= TextEditingController();
    _model.loteFocusNode ??= FocusNode();

    _model.ubicacionOController ??= TextEditingController();
    _model.ubicacionOFocusNode ??= FocusNode();

    _model.ubicacionDController ??= TextEditingController();
    _model.ubicacionDFocusNode ??= FocusNode();

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
    _model.dispose();
    super.dispose();
  }

  void _refrescarListas() {
    safeSetState(() {
      _pendientesKey = UniqueKey();
      _capturadosKey = UniqueKey();
      _pendientesFuture = null;
      _capturadosFuture = null;
    });
  }

  void _limpiarFormularioCaptura() {
    safeSetState(() {
      _model.selectedLineNum = null;
      _model.selectedItemCode = null;
      _model.selectedItemName = null;
      _model.selectedAlmacenO = null;
      _model.selectedAlmacenD = null;
      _model.selectedPendiente = null;
      _model.codigoBarrasController?.clear();
      _model.cantidadController?.clear();
      _model.loteController?.clear();
      _model.ubicacionOController?.clear();
      _model.ubicacionDController?.clear();
    });
  }

  Future<void> _escanearOLeerCodigo({String? codigoManual}) async {
    if (_model.isLoadingReader || _model.isSaving) return;
    String barcode = codigoManual?.trim() ?? '';
    if (barcode.isEmpty) {
      // Escanear mediante cámara
      await actions.scanBarcode(context);
      barcode = FFAppState().globalBarcode.trim();
    }

    if (barcode.isEmpty) return;

    _model.codigoBarrasController?.text = barcode;
    safeSetState(() {
      _model.isLoadingReader = true;
    });

    try {
      List pendientes = [];
      if (_model.selectedLineNum == null) {
        final pendientesResponse =
            await WSInventariosGroup.articulosPendientesCall.call(
          docCode: widget.docCode,
        );
        if (!pendientesResponse.succeeded) {
          throw Exception('No se pudieron consultar las líneas pendientes.');
        }
        final body = pendientesResponse.jsonBody;
        if (body is List) {
          pendientes = body;
        } else if (body is Map && body['valores'] is List) {
          pendientes = body['valores'] as List;
        }
      }

      final almacenes = _model.selectedLineNum != null
          ? <String>[_model.selectedAlmacenO ?? '']
          : pendientes
              .map((item) => (getJsonField(item, r'''$.almacenO''') ??
                      getJsonField(item, r'''$.AlmacenO''') ??
                      getJsonField(item, r'''$.almacen''') ??
                      '')
                  .toString())
              .toSet()
              .toList();
      ApiCallResponse? response;
      String itemCodeLeido = '';
      for (final almacenOrigen in almacenes) {
        final lectura = await WSInventariosGroup.leerCodigoBarrasCall.call(
          codigoBarras: barcode,
          almacen: almacenOrigen,
        );
        response = lectura;
        if (lectura.succeeded &&
            WSInventariosGroup.loginCall.respuestaError(lectura.jsonBody) !=
                true) {
          final valores = getJsonField(lectura.jsonBody, r'''$.valores''');
          final codigo =
              getJsonField(valores, r'''$.itemCode''')?.toString() ?? '';
          if (codigo.isNotEmpty &&
              (_model.selectedLineNum != null ||
                  pendientes.any((item) =>
                      (getJsonField(item, r'''$.itemCode''') ??
                              getJsonField(item, r'''$.ItemCode''') ??
                              '')
                          .toString()
                          .toUpperCase() ==
                      codigo.toUpperCase()))) {
            itemCodeLeido = codigo;
            break;
          }
        }
      }

      if (response == null) {
        throw Exception('No hay líneas pendientes para capturar.');
      }

      if (response.succeeded &&
          (WSInventariosGroup.loginCall.respuestaError(response.jsonBody) !=
              true)) {
        final valores = getJsonField(response.jsonBody, r'''$.valores''');
        itemCodeLeido =
            getJsonField(valores, r'''$.itemCode''')?.toString() ?? '';
        final itemNameLeido =
            getJsonField(valores, r'''$.itemName''')?.toString() ?? '';
        final loteSugerido =
            getJsonField(valores, r'''$.loteSugerido''')?.toString() ?? '';

        if (!mounted) return;

        if (_model.selectedLineNum == null) {
          final coincidencias = pendientes
              .where((item) =>
                  (getJsonField(item, r'''$.itemCode''') ??
                          getJsonField(item, r'''$.ItemCode''') ??
                          '')
                      .toString()
                      .toUpperCase() ==
                  itemCodeLeido.toUpperCase())
              .toList();
          if (coincidencias.length != 1) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(coincidencias.isEmpty
                  ? 'El código no corresponde a una línea pendiente.'
                  : 'Hay varias líneas de este artículo. Selecciona una línea pendiente.'),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ));
            return;
          }
          final item = coincidencias.single;
          safeSetState(() {
            _model.selectedLineNum =
                castToType<int>(getJsonField(item, r'''$.lineNum''')) ??
                    castToType<int>(getJsonField(item, r'''$.LineNum''')) ??
                    pendientes.indexOf(item);
            _model.selectedItemCode = itemCodeLeido;
            _model.selectedItemName = (getJsonField(item, r'''$.itemName''') ??
                    getJsonField(item, r'''$.ItemName''') ??
                    itemNameLeido)
                .toString();
            _model.selectedAlmacenO = (getJsonField(item, r'''$.almacenO''') ??
                    getJsonField(item, r'''$.AlmacenO''') ??
                    getJsonField(item, r'''$.almacen''') ??
                    '')
                .toString();
            _model.selectedAlmacenD = (getJsonField(item, r'''$.almacenD''') ??
                    getJsonField(item, r'''$.AlmacenD''') ??
                    '')
                .toString();
            _model.selectedPendiente = castToType<double>(
                    getJsonField(item, r'''$.cantidadPendiente''')) ??
                castToType<double>(
                    getJsonField(item, r'''$.CantidadPendiente'''));
          });
        }

        // Validar que el artículo corresponda a la línea seleccionada
        if (itemCodeLeido.toUpperCase() !=
            _model.selectedItemCode!.toUpperCase()) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Artículo no coincide'),
              content: Text(
                'El código escaneado pertenece al artículo "$itemCodeLeido" ($itemNameLeido), '
                'pero la línea seleccionada es "${_model.selectedItemCode}".\n\n'
                'Por favor selecciona la línea correcta o escanea el artículo correspondiente.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
          return;
        }

        final barcodeQuantity = quantityFromBarcode(barcode);
        if (barcodeQuantity != null) {
          _model.cantidadController?.text = barcodeQuantity.toString();
        }
        // Llenar datos sugeridos
        safeSetState(() {
          if (loteSugerido.isNotEmpty) {
            _model.loteController?.text = loteSugerido;
          }
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Artículo verificado: $itemCodeLeido',
              style: TextStyle(color: FlutterFlowTheme.of(context).info),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;

        final desc =
            getJsonField(response.jsonBody, r'''$.descripcion''')?.toString() ??
                'No se encontró información para el código de barras.';
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Lectura fallida'),
            content: Text(desc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No se pudo leer el código: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ));
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          _model.isLoadingReader = false;
        });
      }
    }
  }

  Future<void> _guardarCaptura() async {
    if (_model.isSaving || _model.isLoadingReader) return;

    if (_model.selectedLineNum == null || _model.selectedItemCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una línea pendiente.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    if ((_model.selectedAlmacenO ?? '').trim().isEmpty ||
        (_model.selectedAlmacenD ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ingresa el almacén origen y el almacén destino.'),
      ));
      return;
    }

    final cantidadText = _model.cantidadController?.text.trim() ?? '';
    final cantidadNum = int.tryParse(cantidadText);
    if (cantidadNum == null || cantidadNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Ingresa una cantidad válida mayor a 0 en unidades de inventario.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    final barcode = _model.codigoBarrasController?.text.trim() ?? '';
    final lote = _model.loteController?.text.trim() ?? '';
    final ubicacionO = _model.ubicacionOController?.text.trim() ?? '';
    final ubicacionD = _model.ubicacionDController?.text.trim() ?? '';

    safeSetState(() {
      _model.isSaving = true;
    });

    try {
      final response = await WSInventariosGroup.guardarArticuloCall.call(
        docCode: widget.docCode,
        tipoDocumento: '3',
        codigoArticulo: _model.selectedItemCode,
        nombre: _model.selectedItemName ?? '',
        codigoBarras: barcode,
        linea: _model.selectedLineNum.toString(), // Conservar '0' como válido
        cantidad: cantidadNum,
        unidad: 0, // Inventario por defecto
        lote: lote,
        almacenO: _model.selectedAlmacenO ?? '',
        almacenD: _model.selectedAlmacenD ?? '',
        ubicacionO: ubicacionO,
        ubicacionD: ubicacionD,
        usuario: FFAppState().idUsuario,
        fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      final success = response.succeeded &&
          (WSInventariosGroup.loginCall.respuestaError(response.jsonBody) !=
              true);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Captura guardada correctamente.',
              style: TextStyle(color: FlutterFlowTheme.of(context).info),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
        if (widget.articulo != null) {
          Navigator.of(context).pop(true);
        } else {
          _limpiarFormularioCaptura();
          _refrescarListas();
        }
      } else {
        final desc =
            getJsonField(response.jsonBody, r'''$.descripcion''')?.toString() ??
                response.response?.body ??
                'Error al guardar la captura.';
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error al guardar'),
            content: Text(desc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          _model.isSaving = false;
        });
      }
    }
  }

  Future<void> _eliminarCapturasArticulo(String itemCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar capturas del artículo'),
        content: Text(
          'ADVERTENCIA:\n\n'
          'Esta acción eliminará TODAS las capturas registradas para el artículo '
          '"$itemCode" dentro de este documento (incluyendo capturas en otras líneas, '
          'lotes o ubicaciones distintas).\n\n'
          '¿Estás seguro de que deseas eliminarlas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    safeSetState(() {
      _model.isDeleting = true;
    });

    try {
      final response = await WSInventariosGroup.eliminarArticuloCall.call(
        docCode: widget.docCode,
        codigoArticulo: itemCode,
      );

      final success = response.succeeded &&
          (WSInventariosGroup.loginCall.respuestaError(response.jsonBody) !=
              true);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Capturas de $itemCode eliminadas.',
              style: TextStyle(color: FlutterFlowTheme.of(context).info),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
        _refrescarListas();
      } else {
        final desc =
            getJsonField(response.jsonBody, r'''$.descripcion''')?.toString() ??
                'Error al eliminar capturas.';
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Aviso'),
            content: Text(desc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          _model.isDeleting = false;
        });
      }
    }
  }

  Future<void> _generarTransferencia() async {
    if (_model.isProcessing || _model.isSaving) return;

    // Captured items have their own route; validate against the server even
    // when that screen has never been opened in this session.
    _model.isProcessing = true;
    safeSetState(() {});
    List capturas;
    try {
      final response = await WSInventariosGroup.obtenerArticulosCapturadosCall
          .call(docCode: widget.docCode);
      if (!mounted) return;
      if (!response.succeeded) {
        throw StateError('No se pudieron consultar las capturas.');
      }
      final body = response.jsonBody;
      capturas = body is List
          ? body
          : (body is Map && body['valores'] is List
              ? body['valores'] as List
              : []);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No se pudieron consultar las capturas. Intenta nuevamente.'),
        ));
      }
      return;
    } finally {
      if (mounted) safeSetState(() => _model.isProcessing = false);
    }
    if (capturas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'No hay capturas registradas para procesar la transferencia.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generar Transferencia en SAP'),
        content: Text(
          '¿Deseas procesar las capturas realizadas para la solicitud #${widget.docNum}?\n\n'
          'Se creará el documento de Transferencia de Stock en SAP con las líneas capturadas. '
          'Se admiten transferencias parciales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar y Procesar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    safeSetState(() {
      _model.isProcessing = true;
    });

    try {
      final response = await WSInventariosGroup.procesarDocumentoCall.call(
        docCode: widget.docCode,
      );

      final success = response.succeeded &&
          (WSInventariosGroup.procesarDocumentoCall
                  .respuestaSuccess(response.jsonBody) ==
              true);

      if (!mounted) return;

      if (success) {
        final sapDocNum = WSInventariosGroup.procesarDocumentoCall
            .sapDocNum(response.jsonBody);
        final sapDocEntry = WSInventariosGroup.procesarDocumentoCall
            .sapDocEntry(response.jsonBody);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle,
                    color: FlutterFlowTheme.of(context).success),
                const SizedBox(width: 8.0),
                const Text('Transferencia creada'),
              ],
            ),
            content: Text(
              'La transferencia se generó exitosamente en SAP.\n\n'
              'Folio SAP (DocNum): ${sapDocNum ?? "-"}\n'
              'Identificador SAP (DocEntry): ${sapDocEntry ?? "-"}\n\n'
              'La captura actual ha sido cerrada.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    context.pushNamed(PrincipalWidget.routeName);
                  }
                },
                child: const Text('Finalizar'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;

        final desc = WSInventariosGroup.procesarDocumentoCall
                .descripcion(response.jsonBody) ??
            getJsonField(response.jsonBody, r'''$.descripcion''')?.toString() ??
            response.response?.body ??
            'Error al procesar la transferencia en SAP.';

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error al procesar'),
            content: Text(
              '$desc\n\n'
              'La captura se ha conservado para que puedas corregir los datos o reintentar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error de comunicación'),
          content: Text(
            'Ocurrió un problema de conexión al procesar: $e\n\n'
            'El estado en SAP es desconocido. Por favor revisa las capturas abiertas '
            'o verifica en SAP antes de intentar crear otra captura.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } finally {
      safeSetState(() {
        _model.isProcessing = false;
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
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () async {
              if (widget.articulo != null || widget.soloCapturados) {
                Navigator.of(context).pop();
              } else {
                context.safePop();
              }
            },
          ),
          title: Text(
            widget.articulo == null && !widget.soloCapturados
                ? 'Artículos pendientes'
                : 'It One - Inventarios Móviles',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.readexPro(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            if (widget.articulo == null)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refrescarListas,
              ),
          ],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
            child: ListView(children: [
          _buildResumenTraslado(),
          if (widget.articulo != null) ...[
            _buildFormularioCaptura(),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              child: Row(children: [
                Expanded(
                    child: trasladoCaptureButton(
                        context,
                        _model.isSaving ? 'Guardando...' : 'Capturar',
                        _model.isSaving || _model.isLoadingReader
                            ? null
                            : _guardarCaptura,
                        color: FlutterFlowTheme.of(context).accent1,
                        bold: true)),
                const SizedBox(width: 15),
                Expanded(
                    child: trasladoCaptureButton(
                        context,
                        'Volver',
                        _model.isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        bold: true)),
              ]),
            ),
          ] else if (widget.soloCapturados) ...[
            _buildArticulosPanel(capturados: true),
          ] else ...[
            _buildArticulosPanel(capturados: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: trasladoCaptureButton(
                  context, 'Artículos Capturados', _abrirArticulosCapturados),
            ),
            _buildBotonGenerarTransferencia(),
          ],
        ])),
      ),
    );
  }

  Future<void> _abrirArticulosCapturados() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ArticulosCapturadosTraslado'),
      builder: (_) => CapturaTrasladoWidget(
        docCode: widget.docCode,
        docEntry: widget.docEntry,
        docNum: widget.docNum,
        soloCapturados: true,
      ),
    ));
    if (mounted) _refrescarListas();
  }

  Widget _buildArticulosPanel({required bool capturados}) {
    final theme = FlutterFlowTheme.of(context);
    final future = capturados
        ? (_capturadosFuture ??= WSInventariosGroup
            .obtenerArticulosCapturadosCall
            .call(docCode: widget.docCode))
        : (_pendientesFuture ??= WSInventariosGroup.articulosPendientesCall
            .call(docCode: widget.docCode));
    return Container(
      height: capturados ? 440 : 373,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
        boxShadow: const [
          BoxShadow(
              blurRadius: 6, color: Color(0x1B090F13), offset: Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(
                  child: Text(
                      capturados
                          ? 'Artículos capturados'
                          : 'Artículos pendientes',
                      style: theme.bodyMedium.copyWith(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              FutureBuilder<ApiCallResponse>(
                  future: future,
                  builder: (context, snapshot) {
                    final body = snapshot.data?.jsonBody;
                    final items = body is List
                        ? body
                        : (body is Map ? body['valores'] : null);
                    return Text(items is List ? '${items.length}' : '',
                        style: theme.bodySmall
                            .copyWith(color: theme.secondaryText));
                  }),
            ])),
        Expanded(
            child:
                capturados ? _buildListaCapturados() : _buildListaPendientes()),
      ]),
    );
  }

  Widget _buildResumenTraslado() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(15.0, 15.0, 15.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x1B090F13),
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.soloCapturados
                      ? 'Artículos Capturados'
                      : widget.articulo == null
                          ? 'Captura Traslado'
                          : 'Captura de artículo',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              const SizedBox(height: 10.0),
              Text.rich(
                TextSpan(text: 'Solicitud No: ', children: [
                  TextSpan(
                      text: widget.docNum ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 8.0),
              Text.rich(
                TextSpan(text: 'Documento interno captura: ', children: [
                  TextSpan(
                      text: widget.docCode ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FORMULARIO DE CAPTURA
  // ==========================================
  Widget _buildFormularioCaptura() {
    final theme = FlutterFlowTheme.of(context);
    Widget field(
            String label, TextEditingController? controller, FocusNode? focus,
            {TextInputType? keyboard}) =>
        _captureRow(
            label,
            TextFormField(
              controller: controller,
              focusNode: focus,
              keyboardType: keyboard,
              style: theme.bodyMedium,
              decoration: _captureField(label),
            ));
    return TrasladoPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _captureRow(
            'Código',
            Row(children: [
              Expanded(
                  child: TextFormField(
                controller: _model.codigoBarrasController,
                focusNode: _model.codigoBarrasFocusNode,
                enabled: !_model.isLoadingReader && !_model.isSaving,
                style: theme.bodyMedium,
                decoration: _captureField('Ingresa o escanea el código',
                    hint: _model.selectedItemCode,
                    suffix: IconButton(
                        tooltip: 'Buscar código',
                        icon: const Icon(Icons.search, size: 20),
                        onPressed: _model.isLoadingReader
                            ? null
                            : () => _escanearOLeerCodigo(
                                codigoManual:
                                    _model.codigoBarrasController?.text))),
                onFieldSubmitted: (value) =>
                    _escanearOLeerCodigo(codigoManual: value),
              )),
              const SizedBox(width: 7),
              Tooltip(
                  message: 'Escanear código',
                  child: FlutterFlowIconButton(
                    borderRadius: 8,
                    buttonSize: 52,
                    fillColor: theme.primary,
                    icon: Icon(Icons.qr_code_scanner,
                        color: theme.info, size: 26),
                    onPressed: _model.isLoadingReader || _model.isSaving
                        ? null
                        : () => _escanearOLeerCodigo(),
                  )),
            ])),
        if (_model.isLoadingReader)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 16),
            child: Row(children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: theme.primary),
              ),
              const SizedBox(width: 12),
              Text('Leyendo código...', style: theme.bodyMedium),
            ]),
          ),
        field('Cantidad', _model.cantidadController, _model.cantidadFocusNode,
            keyboard: TextInputType.number),
        Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(builder: (context, constraints) {
            final origen = _almacenCard(
                'Almacén origen',
                _model.selectedAlmacenO,
                Icons.warehouse_outlined,
                (value) => _model.selectedAlmacenO = value.trim());
            final destino = _almacenCard(
                'Almacén destino',
                _model.selectedAlmacenD,
                Icons.move_to_inbox_outlined,
                (value) => _model.selectedAlmacenD = value.trim());
            if (constraints.maxWidth < 280) {
              return Column(
                  children: [origen, const SizedBox(height: 12), destino]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: origen),
              const SizedBox(width: 12),
              Expanded(child: destino),
            ]);
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _almacenCard(
                  'Ubicación origen',
                  null,
                  Icons.location_on_outlined,
                  null,
                  controller: _model.ubicacionOController,
                  focusNode: _model.ubicacionOFocusNode,
                  hint: 'Ubicación'),
              const SizedBox(height: 12),
              _almacenCard(
                  'Ubicación destino',
                  null,
                  Icons.location_on_outlined,
                  null,
                  controller: _model.ubicacionDController,
                  focusNode: _model.ubicacionDFocusNode,
                  hint: 'Ubicación'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _captureRow(String label, Widget child) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label,
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ]),
      );

  InputDecoration _captureField(String label, {String? hint, Widget? suffix}) {
    final theme = FlutterFlowTheme.of(context);
    return InputDecoration(
      hintText: hint ?? label,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: theme.labelMedium,
      hintStyle: theme.labelMedium,
      filled: true,
      fillColor: theme.secondaryBackground,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate),
          borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primary, width: 2),
          borderRadius: BorderRadius.circular(12)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _almacenCard(String label, String? value, IconData icon,
      ValueChanged<String>? onChanged,
      {TextEditingController? controller,
      FocusNode? focusNode,
      String hint = 'Almacén'}) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: theme.primary, size: 22),
        const SizedBox(height: 10),
        Text(label, style: theme.labelMedium),
        const SizedBox(height: 4),
        TextFormField(
            initialValue: controller == null ? (value ?? '') : null,
            controller: controller,
            focusNode: focusNode,
            enabled: !_model.isLoadingReader && !_model.isSaving,
            onChanged: onChanged,
            textInputAction: TextInputAction.next,
            decoration: _captureField(hint),
            style: theme.titleMedium.copyWith(
                color: theme.primaryText, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _abrirCapturaArticulo(TrasladoArticulo articulo) async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => CapturaTrasladoWidget(
        docCode: widget.docCode,
        docEntry: widget.docEntry,
        docNum: widget.docNum,
        articulo: articulo,
      ),
    ));
    if (mounted) _refrescarListas();
  }

  Widget _buildListaPendientes() {
    return FutureBuilder<ApiCallResponse>(
      key: _pendientesKey,
      future: _pendientesFuture ??=
          WSInventariosGroup.articulosPendientesCall.call(
        docCode: widget.docCode,
      ),
      builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: _refrescarListas);
        if (loadState != null) return loadState;
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40.0),
                const SizedBox(height: 8.0),
                const Text('Error al cargar pendientes.'),
                ElevatedButton(
                  onPressed: _refrescarListas,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final response = snapshot.data!;
        final body = response.jsonBody;

        List pendientes = [];
        if (body is List) {
          pendientes = body;
        } else if (body is Map &&
            body.containsKey('valores') &&
            body['valores'] is List) {
          pendientes = body['valores'];
        }

        if (pendientes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: FlutterFlowTheme.of(context).success, size: 48.0),
                  const SizedBox(height: 12.0),
                  Text(
                    'No hay artículos pendientes',
                    style: FlutterFlowTheme.of(context).titleMedium,
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Todos los artículos de la solicitud han sido capturados.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: pendientes.length,
          itemBuilder: (context, index) {
            final item = pendientes[index];
            final lineNum =
                castToType<int>(getJsonField(item, r'''$.lineNum''')) ??
                    castToType<int>(getJsonField(item, r'''$.LineNum''')) ??
                    index;
            final itemCode =
                getJsonField(item, r'''$.itemCode''')?.toString() ??
                    getJsonField(item, r'''$.ItemCode''')?.toString() ??
                    '';
            final itemName =
                getJsonField(item, r'''$.itemName''')?.toString() ??
                    getJsonField(item, r'''$.ItemName''')?.toString() ??
                    '';
            final cantidadPendiente = castToType<double>(
                    getJsonField(item, r'''$.cantidadPendiente''')) ??
                castToType<double>(
                    getJsonField(item, r'''$.CantidadPendiente''')) ??
                0.0;
            final almacenO =
                getJsonField(item, r'''$.almacenO''')?.toString() ??
                    getJsonField(item, r'''$.AlmacenO''')?.toString() ??
                    getJsonField(item, r'''$.almacen''')?.toString() ??
                    '-';
            final almacenD =
                getJsonField(item, r'''$.almacenD''')?.toString() ??
                    getJsonField(item, r'''$.AlmacenD''')?.toString() ??
                    '-';

            final articulo = TrasladoArticulo(
              lineNum: lineNum,
              itemCode: itemCode,
              itemName: itemName,
              almacenO: almacenO,
              almacenD: almacenD,
              pendiente: cantidadPendiente,
            );
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: FlutterFlowTheme.of(context).alternate),
              ),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(itemCode,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText)),
                      const SizedBox(height: 2),
                      if (itemName.isNotEmpty)
                        Text(itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Origen: $almacenO - Destino: $almacenD',
                          style: FlutterFlowTheme.of(context).labelSmall),
                    ])),
                const SizedBox(width: 10),
                Column(children: [
                  Text(cantidadPendiente.toString(),
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primary)),
                  Text('pend.',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontSize: 10,
                          color: FlutterFlowTheme.of(context).secondaryText)),
                ]),
                const SizedBox(width: 6),
                FlutterFlowIconButton(
                  borderRadius: 8,
                  buttonSize: 40,
                  fillColor: FlutterFlowTheme.of(context).warning,
                  icon: Icon(Icons.add_circle_outline_outlined,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24),
                  onPressed: () => _abrirCapturaArticulo(articulo),
                ),
              ]),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 2: LISTA DE ARTÍCULOS CAPTURADOS
  // ==========================================
  Widget _buildListaCapturados() {
    return FutureBuilder<ApiCallResponse>(
      key: _capturadosKey,
      future: _capturadosFuture ??=
          WSInventariosGroup.obtenerArticulosCapturadosCall.call(
        docCode: widget.docCode,
      ),
      builder: (context, snapshot) {
        final loadState = apiLoadState(snapshot, onRetry: _refrescarListas);
        if (loadState != null) return loadState;
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40.0),
                const SizedBox(height: 8.0),
                const Text('Error al cargar capturas.'),
                ElevatedButton(
                  onPressed: _refrescarListas,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final response = snapshot.data!;
        final body = response.jsonBody;

        List capturas = [];
        if (body is Map && body.containsKey('valores')) {
          final v = body['valores'];
          if (v is List) capturas = v;
        } else if (body is List) {
          capturas = body;
        }

        if (capturas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 48.0),
                  const SizedBox(height: 12.0),
                  Text(
                    'No hay artículos capturados',
                    style: FlutterFlowTheme.of(context).titleMedium,
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Vuelve a los pendientes para capturar un artículo.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: capturas.length,
          itemBuilder: (context, index) {
            final item = capturas[index];
            final itemCode =
                getJsonField(item, r'''$.codigoArticulo''')?.toString() ??
                    getJsonField(item, r'''$.itemCode''')?.toString() ??
                    '';
            final itemName = getJsonField(item, r'''$.nombre''')?.toString() ??
                getJsonField(item, r'''$.itemName''')?.toString() ??
                '';
            final lineNum = getJsonField(item, r'''$.linea''')?.toString() ??
                getJsonField(item, r'''$.lineNum''')?.toString() ??
                '-';
            final cantidad =
                getJsonField(item, r'''$.cantidad''')?.toString() ?? '0';
            final lote = getJsonField(item, r'''$.lote''')?.toString() ?? '';
            final almacenO =
                getJsonField(item, r'''$.almacenO''')?.toString() ?? '-';
            final almacenD =
                getJsonField(item, r'''$.almacenD''')?.toString() ?? '-';
            final ubicacionO =
                getJsonField(item, r'''$.ubicacionO''')?.toString() ?? '';
            final ubicacionD =
                getJsonField(item, r'''$.ubicacionD''')?.toString() ?? '';

            final theme = FlutterFlowTheme.of(context);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.alternate)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(itemCode,
                                style: theme.bodySmall.copyWith(
                                    color: theme.secondaryText,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(itemName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ])),
                      const SizedBox(width: 10),
                      Column(children: [
                        Text(cantidad,
                            style: theme.bodyMedium.copyWith(
                                color: theme.primary,
                                fontWeight: FontWeight.bold)),
                        Text('cant.',
                            style: theme.bodySmall.copyWith(
                                fontSize: 10, color: theme.secondaryText)),
                      ]),
                      const SizedBox(width: 6),
                      Tooltip(
                          message: 'Eliminar capturas del artículo',
                          child: FlutterFlowIconButton(
                            borderRadius: 8,
                            buttonSize: 40,
                            fillColor: theme.secondaryText,
                            icon:
                                Icon(Icons.delete, color: theme.info, size: 24),
                            onPressed: _model.isDeleting
                                ? null
                                : () => _eliminarCapturasArticulo(itemCode),
                          )),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                        'Línea: $lineNum${lote.isEmpty ? '' : ' - Lote: $lote'}',
                        style: theme.labelSmall),
                    Text('Origen: $almacenO - Destino: $almacenD',
                        style: theme.labelSmall),
                    if (ubicacionO.isNotEmpty || ubicacionD.isNotEmpty)
                      Text('Ubicaciones: $ubicacionO - $ubicacionD',
                          style: theme.labelSmall),
                  ]),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // BOTÓN GENERAR TRANSFERENCIA EN SAP
  // ==========================================
  Widget _buildBotonGenerarTransferencia() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: trasladoCaptureButton(
          context,
          _model.isProcessing
              ? 'Procesando transferencia...'
              : 'Generar transferencia en SAP',
          (_model.isProcessing || _model.isSaving)
              ? null
              : _generarTransferencia,
          color: FlutterFlowTheme.of(context).accent3),
    );
  }
}
