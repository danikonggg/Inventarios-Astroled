import '/flutter_flow/flutter_flow_util.dart';
import 'ubicaciones_widget.dart' show UbicacionesWidget;
import 'package:flutter/material.dart';

class UbicacionesModel extends FlutterFlowModel<UbicacionesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
