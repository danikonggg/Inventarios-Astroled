import '/backend/api_requests/api_calls.dart';

String conteoErrorText(Object error) => error is StateError
    ? error.message
    : error is FormatException
        ? error.message
        : 'No se pudo comunicar con el servidor. Revisa la conexión y actualiza el documento.';

Map<String, dynamic> conteoArticulo(dynamic row) => {
      if (row is Map)
        ...row.map((key, value) => MapEntry(key.toString(), value)),
      'itemCode': conteoValue(row, ['ItemCode', 'CodigoArticulo']),
      'itemName': conteoValue(row, ['ItemName', 'Nombre']),
      'codigoArticulo': conteoValue(row, ['CodigoArticulo', 'ItemCode']),
      'nombre': conteoValue(row, ['Nombre', 'ItemName']),
      'almacen': conteoValue(row, ['Almacen', 'AlmacenD', 'WhsCode']),
      'ubicacion': conteoValue(row, ['Ubicacion', 'UbicacionD', 'BinCode']),
      'lineNum': conteoValue(row, ['LineNum', 'Linea']),
      'cantidadPendiente': conteoValue(row, ['CantidadPendiente']),
      'cantidad': conteoValue(row, ['Cantidad', 'CantidadCapturada']),
      'cantidadCapturada': conteoValue(row, ['CantidadCapturada', 'CountQty']),
      'existenciaReferencia':
          conteoValue(row, ['ExistenciaReferencia', 'Existencia', 'InWhsQty']),
      'codigoBarras': conteoValue(row, ['CodigoBarras', 'Barcode']),
      'lote': conteoValue(row, ['Lote']),
    };

dynamic conteoValue(dynamic row, List<String> names) {
  if (row is! Map) return null;
  for (final name in names) {
    for (final key in row.keys) {
      if (key.toString().toLowerCase() == name.toLowerCase() &&
          row[key] != null) {
        return row[key];
      }
    }
  }
  return null;
}

String conteoText(dynamic row, List<String> names) =>
    conteoValue(row, names)?.toString() ?? '';

List<dynamic> conteoRows(dynamic body) {
  final rows = body is List ? body : conteoValue(body, ['Valores']);
  if (rows is! List) {
    throw const FormatException(
        'La respuesta no contiene una lista de documentos o artículos.');
  }
  return rows;
}

void checkConteoResponse(ApiCallResponse response,
    {bool requireSuccess = false}) {
  if (response.hasFailure) throw StateError(response.userMessage);
  final success = conteoValue(response.jsonBody, ['Success']);
  if (!response.succeeded ||
      success == false ||
      conteoValue(response.jsonBody, ['Error']) == true ||
      (requireSuccess && success != true)) {
    final description = conteoText(response.jsonBody, ['Descripcion']);
    throw StateError(description.isEmpty
        ? 'No se pudo completar la operación.'
        : description);
  }
}
