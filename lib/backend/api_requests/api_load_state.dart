import 'package:flutter/material.dart';
import 'api_manager.dart';

/// Handles loading and failures before a screen reads response fields.
/// An empty successful list is deliberately left to the screen's empty state.
Widget? apiLoadState(
  AsyncSnapshot<dynamic> snapshot, {
  required VoidCallback onRetry,
  bool fullScreen = false,
  String title = 'Consulta',
}) {
  final loading = snapshot.connectionState != ConnectionState.done;
  String? message;
  if (!loading) {
    if (snapshot.hasError) {
      final error = snapshot.error;
      message = error is StateError ? error.message :
          'No se pudo cargar la información. Revisa tu conexión y vuelve a intentar.';
    } else {
      final data = snapshot.data;
      final responses = data is ApiCallResponse
          ? [data]
          : data is List<ApiCallResponse> ? data : <ApiCallResponse>[];
      for (final response in responses) {
        if (response.hasFailure) {
          message = response.userMessage;
          break;
        }
        if (response.jsonBody is! Map && response.jsonBody is! List && response.statusCode != 204) {
          message = 'El servidor devolvió información con un formato no válido. Intenta de nuevo o consulta al administrador.';
          break;
        }
      }
      if (data == null) message = 'No se recibió información del servidor. Vuelve a intentar.';
    }
  }
  if (!loading && message == null) return null;
  final content = Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (loading) const CircularProgressIndicator()
          else const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(loading ? 'Consultando al servidor…' : 'No se pudo cargar la información',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (!loading) ...[
            const SizedBox(height: 8),
            Text(message!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ]),
      ),
    ),
  );
  return fullScreen
      ? Scaffold(appBar: AppBar(title: Text(title)), body: SafeArea(child: content))
      : content;
}
