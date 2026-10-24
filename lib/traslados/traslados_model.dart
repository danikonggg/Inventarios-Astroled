import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'traslados_widget.dart' show TrasladosWidget;
import 'package:flutter/material.dart';

class TrasladosModel extends FlutterFlowModel<TrasladosWidget> {
  /// Local state fields
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Filter controllers for Solicitudes
  FocusNode? docEntryFilterFocusNode;
  TextEditingController? docEntryFilterController;

  FocusNode? fechaDesdeFocusNode;
  TextEditingController? fechaDesdeController;

  FocusNode? fechaHastaFocusNode;
  TextEditingController? fechaHastaController;

  // Detail & capture creation fields
  bool isCreatingCapture = false;
  FocusNode? comentariosFocusNode;
  TextEditingController? comentariosController;
  FocusNode? fechaCapturaFocusNode;
  TextEditingController? fechaCapturaController;

  ApiCallResponse? apiResultDocumentoNuevo;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    docEntryFilterFocusNode?.dispose();
    docEntryFilterController?.dispose();
    fechaDesdeFocusNode?.dispose();
    fechaDesdeController?.dispose();
    fechaHastaFocusNode?.dispose();
    fechaHastaController?.dispose();
    comentariosFocusNode?.dispose();
    comentariosController?.dispose();
    fechaCapturaFocusNode?.dispose();
    fechaCapturaController?.dispose();
  }
}
