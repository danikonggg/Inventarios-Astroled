// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

Future focusCodigoBarras(BuildContext context) async {
  // Espera a que el form termine de resetearse
  await Future.delayed(const Duration(milliseconds: 300));

  // Quita cualquier foco actual
  FocusScope.of(context).unfocus();

  await Future.delayed(const Duration(milliseconds: 100));

  // Vuelve a enfocar el árbol completo (esto hace que el TextField con autofocus recupere el foco)
  FocusScope.of(context).requestFocus(FocusNode());
}
