import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'salida_mercancias_widget.dart' show SalidaMercanciasWidget;
import 'package:flutter/material.dart';

class SalidaMercanciasModel extends FlutterFlowModel<SalidaMercanciasWidget> {
  ///  Local state fields for this page.

  String selectedDocNum = '';

  String selectedCardCode = '';

  String docEntry = '';

  String docNum = '';

  String cardCode = '';

  String docDate = '';

  String almacen = '';

  String docEntrySearch = '';

  String ok = '1';

  int? docEntry1;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textFieldTextController;
  String? Function(BuildContext, String?)? textFieldTextControllerValidator;
  // State field(s) for verdetalle widget.
  FocusNode? verdetalleFocusNode;
  TextEditingController? verdetalleTextController;
  String? Function(BuildContext, String?)? verdetalleTextControllerValidator;
  // State field(s) for provedor widget.
  FocusNode? provedorFocusNode;
  TextEditingController? provedorTextController;
  String? Function(BuildContext, String?)? provedorTextControllerValidator;
  // State field(s) for TextReferencia widget.
  FocusNode? textReferenciaFocusNode;
  TextEditingController? textReferenciaTextController;
  String? Function(BuildContext, String?)?
      textReferenciaTextControllerValidator;
  // State field(s) for TextAlmacen widget.
  FocusNode? textAlmacenFocusNode;
  TextEditingController? textAlmacenTextController;
  String? Function(BuildContext, String?)? textAlmacenTextControllerValidator;
  // Stores action output result for [Backend Call - API (DocumentoNuevo)] action in Button widget.
  ApiCallResponse? apiResultglx;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textFieldTextController?.dispose();

    verdetalleFocusNode?.dispose();
    verdetalleTextController?.dispose();

    provedorFocusNode?.dispose();
    provedorTextController?.dispose();

    textReferenciaFocusNode?.dispose();
    textReferenciaTextController?.dispose();

    textAlmacenFocusNode?.dispose();
    textAlmacenTextController?.dispose();
  }
}
