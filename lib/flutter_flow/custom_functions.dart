

String? joinList(List<String> lista) {
  return lista.join(", ");
}

bool? tieneModulo(
  String? modulos,
  String? buscado,
) {
  if (modulos == null || buscado == null) return false;
  return modulos.toUpperCase().contains(buscado.toUpperCase());
}
