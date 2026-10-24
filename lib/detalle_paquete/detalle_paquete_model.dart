import '/flutter_flow/flutter_flow_util.dart';
import 'detalle_paquete_widget.dart' show DetallePaqueteWidget;
import 'package:flutter/material.dart';

class DetallePaqueteModel extends FlutterFlowModel<DetallePaqueteWidget> {
  // State fields
  TextEditingController? cantidadController;
  String? Function(BuildContext, String?)? cantidadControllerValidator;

  String? selectedItemDisponible;
  String? selectedItemDisponibleNombre;
  double? selectedItemMaxDisponible;
  int? selectedUomEntry;

  String? selectedItemContenido;
  double? selectedItemContenidoCantidad;
  int? selectedItemContenidoCodeLinea;

  @override
  void initState(BuildContext context) {
    cantidadController ??= TextEditingController(text: '1');
  }

  @override
  void dispose() {
    cantidadController?.dispose();
  }
}
