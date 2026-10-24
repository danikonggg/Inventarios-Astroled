import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'captura_articulos_widget.dart' show CapturaArticulosWidget;
import 'package:flutter/material.dart';

class CapturaArticulosModel extends FlutterFlowModel<CapturaArticulosWidget> {
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
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for CodigoBarras widget.
  FocusNode? codigoBarrasFocusNode;
  TextEditingController? codigoBarrasTextController;
  String? Function(BuildContext, String?)? codigoBarrasTextControllerValidator;
  // Stores action output result for [Backend Call - API (LeerCodigoBarras)] action in CodigoBarras widget.
  ApiCallResponse? codigobarras;
  // Stores action output result for [Backend Call - API (LeerCodigoBarras)] action in IconButton widget.
  ApiCallResponse? codigobar;
  // State field(s) for TextField1 widget.
  FocusNode? textField1FocusNode;
  TextEditingController? textField1TextController;
  String? Function(BuildContext, String?)? textField1TextControllerValidator;
  // State field(s) for Lote widget.
  FocusNode? loteFocusNode;
  TextEditingController? loteTextController;
  String? Function(BuildContext, String?)? loteTextControllerValidator;
  // State field(s) for Cantidad widget.
  FocusNode? cantidadFocusNode;
  TextEditingController? cantidadTextController;
  String? Function(BuildContext, String?)? cantidadTextControllerValidator;
  // Stores action output result for [Backend Call - API (GuardarArticulo)] action in Button widget.
  ApiCallResponse? resultadoGuardarArticulo;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    ubicacionFocusNode?.dispose();
    ubicacionTextController?.dispose();

    textFieldFocusNode?.dispose();
    textController2?.dispose();

    codigoBarrasFocusNode?.dispose();
    codigoBarrasTextController?.dispose();

    textField1FocusNode?.dispose();
    textField1TextController?.dispose();

    loteFocusNode?.dispose();
    loteTextController?.dispose();

    cantidadFocusNode?.dispose();
    cantidadTextController?.dispose();
  }
}
