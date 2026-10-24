import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'captura_traslado_widget.dart' show CapturaTrasladoWidget;
import 'package:flutter/material.dart';

class CapturaTrasladoModel extends FlutterFlowModel<CapturaTrasladoWidget> {
  /// Tab controller for switching between Pendientes and Capturados
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Selected line state
  int? selectedLineNum;
  String? selectedItemCode;
  String? selectedItemName;
  String? selectedAlmacenO;
  String? selectedAlmacenD;
  double? selectedPendiente;

  // Form controllers
  FocusNode? codigoBarrasFocusNode;
  TextEditingController? codigoBarrasController;

  FocusNode? cantidadFocusNode;
  TextEditingController? cantidadController;

  FocusNode? loteFocusNode;
  TextEditingController? loteController;

  FocusNode? ubicacionOFocusNode;
  TextEditingController? ubicacionOController;

  FocusNode? ubicacionDFocusNode;
  TextEditingController? ubicacionDController;

  // Operation flags
  bool isLoadingReader = false;
  bool isSaving = false;
  bool isProcessing = false;
  bool isDeleting = false;

  // API outputs
  ApiCallResponse? apiResultLeerCodigoBarra;
  ApiCallResponse? apiResultGuardarArticulo;
  ApiCallResponse? apiResultEliminarArticulo;
  ApiCallResponse? apiResultProcesar;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    codigoBarrasFocusNode?.dispose();
    codigoBarrasController?.dispose();
    cantidadFocusNode?.dispose();
    cantidadController?.dispose();
    loteFocusNode?.dispose();
    loteController?.dispose();
    ubicacionOFocusNode?.dispose();
    ubicacionOController?.dispose();
    ubicacionDFocusNode?.dispose();
    ubicacionDController?.dispose();
  }
}
