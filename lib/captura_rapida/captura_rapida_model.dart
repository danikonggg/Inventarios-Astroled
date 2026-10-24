import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'captura_rapida_widget.dart' show CapturaRapidaWidget;
import 'package:flutter/material.dart';

class CapturaRapidaModel extends FlutterFlowModel<CapturaRapidaWidget> {
  ///  Local state fields for this page.

  String articulo = '';

  String cantidad = '';

  String almacen = '';

  String nombre = '';

  bool isLoading = false;

  String? codigoEscaneado;

  String? loadingMessage;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Ubicacion widget.
  FocusNode? ubicacionFocusNode;
  TextEditingController? ubicacionTextController;
  String? Function(BuildContext, String?)? ubicacionTextControllerValidator;
  // State field(s) for CodigoBarras widget.
  FocusNode? codigoBarrasFocusNode;
  TextEditingController? codigoBarrasTextController;
  String? Function(BuildContext, String?)? codigoBarrasTextControllerValidator;
  // Stores action output result for [Backend Call - API (LeerCodigoBarras)] action in CodigoBarras widget.
  ApiCallResponse? codigobarras;
  // Stores action output result for [Backend Call - API (GuardarArticulo)] action in CodigoBarras widget.
  ApiCallResponse? apiResultm1b;
  // Stores action output result for [Backend Call - API (LeerCodigoBarras)] action in IconButton widget.
  ApiCallResponse? codigobar;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    ubicacionFocusNode?.dispose();
    ubicacionTextController?.dispose();

    codigoBarrasFocusNode?.dispose();
    codigoBarrasTextController?.dispose();
  }
}
