import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for codigoUsuario widget.
  FocusNode? codigoUsuarioFocusNode;
  TextEditingController? codigoUsuarioTextController;
  String? Function(BuildContext, String?)? codigoUsuarioTextControllerValidator;
  // State field(s) for passwordUsuario widget.
  FocusNode? passwordUsuarioFocusNode;
  TextEditingController? passwordUsuarioTextController;
  late bool passwordUsuarioVisibility;
  String? Function(BuildContext, String?)?
      passwordUsuarioTextControllerValidator;
  // Stores action output result for [Backend Call - API (Login)] action in BtnIniciar widget.
  ApiCallResponse? apiResulti5x;

  @override
  void initState(BuildContext context) {
    passwordUsuarioVisibility = false;
  }

  @override
  void dispose() {
    codigoUsuarioFocusNode?.dispose();
    codigoUsuarioTextController?.dispose();

    passwordUsuarioFocusNode?.dispose();
    passwordUsuarioTextController?.dispose();
  }
}
