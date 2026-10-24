/// Reads a positive whole quantity suffix without changing the barcode itself.
/// Codes without a valid *quantity suffix retain the normal capture behavior.
int? quantityFromBarcode(String barcode) {
  final match = RegExp(r'\*(\d+)$').firstMatch(barcode.trim());
  if (match == null) return null;
  final quantity = int.tryParse(match.group(1)!);
  return quantity != null && quantity > 0 ? quantity : null;
}
