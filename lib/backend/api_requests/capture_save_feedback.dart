import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_calls.dart';

Map? _captureResponseBody(ApiCallResponse? response) {
  if (response?.jsonBody is Map) return response!.jsonBody as Map;
  try {
    final decoded = jsonDecode(response?.bodyText ?? 'null');
    return decoded is Map ? decoded : null;
  } on FormatException {
    return null;
  }
}

bool captureSaveSucceeded(ApiCallResponse? response) {
  final body = _captureResponseBody(response);
  return response?.succeeded == true &&
      (body is! Map || (body['error'] != true && body['success'] != false));
}

Future<void> showCaptureSaveError(
    BuildContext context, ApiCallResponse? response) async {
  final body = _captureResponseBody(response);
  final description =
      body is Map ? body['descripcion']?.toString().trim() : null;
  final quantityLimit =
      description?.toLowerCase().contains('no hay más cantidad pendiente') ==
          true;
  ScaffoldMessenger.of(context).clearSnackBars();
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.error_outline, color: Colors.red),
      title: Text(quantityLimit
          ? 'Cantidad pendiente agotada o excedida'
          : 'Motivo del rechazo'),
      content: SingleChildScrollView(
        child: Text(response?.userMessage ??
            'No se recibió confirmación del servidor. Actualiza antes de repetir la captura.'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
