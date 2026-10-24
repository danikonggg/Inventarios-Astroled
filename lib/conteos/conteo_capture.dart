import 'package:flutter/material.dart';
import '/backend/api_requests/api_calls.dart';
import 'conteo_data.dart';

/// Finds the document line without making the operator leave the capture form.
Future<Map<String, dynamic>?> resolverArticuloConteo(
  BuildContext context, {
  required String docCode,
  required String barcode,
  String ubicacion = '',
  String linea = '',
}) async {
  if (docCode.trim().isEmpty || barcode.trim().isEmpty) {
    throw StateError('Ingresa el código del artículo.');
  }
  final response =
      await WSInventariosGroup.articulosPendientesCall.call(docCode: docCode);
  checkConteoResponse(response);
  final rows = conteoRows(response.jsonBody)
      .map(conteoArticulo)
      .where((row) =>
          (linea.isEmpty || conteoText(row, ['lineNum']) == linea) &&
          (ubicacion.trim().isEmpty ||
              conteoText(row, ['ubicacion']) == ubicacion.trim()))
      .toList();
  final code = barcode.trim();
  var matches = rows
      .where((row) =>
          conteoText(row, ['codigoBarras']) == code ||
          conteoText(row, ['itemCode']) == code)
      .toList();
  if (matches.isEmpty) {
    for (final almacen in rows
        .map((row) => conteoText(row, ['almacen']))
        .where((v) => v.isNotEmpty)
        .toSet()) {
      final lookup = await WSInventariosGroup.leerCodigoBarrasCall
          .call(codigoBarras: code, almacen: almacen);
      checkConteoResponse(lookup);
      final item = conteoText(conteoValue(lookup.jsonBody, ['Valores']),
          ['ItemCode', 'CodigoArticulo']);
      if (item.isNotEmpty) {
        matches.addAll(rows.where((row) =>
            conteoText(row, ['itemCode']) == item &&
            conteoText(row, ['almacen']) == almacen));
      }
    }
  }
  if (!context.mounted) return null;
  if (matches.isEmpty) {
    throw StateError(
        'El artículo no pertenece a este conteo o a la ubicación indicada.');
  }
  Map<String, dynamic>? selected;
  if (matches.length == 1) {
    selected = matches.single;
  } else {
    selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Selecciona la ubicación'),
        children: [
          for (final row in matches)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, row),
              child: Text('${conteoText(row, ['almacen'])} · ${conteoText(row, [
                    'ubicacion'
                  ])} · Lote ${conteoText(row, [
                    'lote'
                  ])} · Línea ${conteoText(row, ['lineNum'])}'),
            )
        ],
      ),
    );
  }
  if (selected != null &&
      (conteoText(selected, ['lineNum']).isEmpty ||
          conteoText(selected, ['almacen']).isEmpty)) {
    throw StateError(
        'El artículo no contiene línea o almacén. Actualiza el conteo.');
  }
  return selected;
}
