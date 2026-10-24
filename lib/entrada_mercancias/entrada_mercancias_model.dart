import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'entrada_mercancias_widget.dart' show EntradaMercanciasWidget;
import 'package:flutter/material.dart';

class EntradaMercanciasModel extends FlutterFlowModel<EntradaMercanciasWidget> {
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

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textFieldTextController;
  String? Function(BuildContext, String?)? textFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (ObtenerDetalleOrden)] action in Button widget.
  ApiCallResponse? apiResult6j6;
  // State field(s) for verdetalle widget.
  FocusNode? verdetalleFocusNode;
  TextEditingController? verdetalleTextController;
  String? Function(BuildContext, String?)? verdetalleTextControllerValidator;
  // State field(s) for lote widget.
  FocusNode? loteFocusNode;
  TextEditingController? loteTextController;
  String? Function(BuildContext, String?)? loteTextControllerValidator;
  // State field(s) for aduana widget.
  FocusNode? aduanaFocusNode;
  TextEditingController? aduanaTextController;
  String? Function(BuildContext, String?)? aduanaTextControllerValidator;
  // State field(s) for pedimento widget.
  FocusNode? pedimentoFocusNode;
  TextEditingController? pedimentoTextController;
  String? Function(BuildContext, String?)? pedimentoTextControllerValidator;
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

    loteFocusNode?.dispose();
    loteTextController?.dispose();

    aduanaFocusNode?.dispose();
    aduanaTextController?.dispose();

    pedimentoFocusNode?.dispose();
    pedimentoTextController?.dispose();

    provedorFocusNode?.dispose();
    provedorTextController?.dispose();

    textReferenciaFocusNode?.dispose();
    textReferenciaTextController?.dispose();

    textAlmacenFocusNode?.dispose();
    textAlmacenTextController?.dispose();
  }
}
