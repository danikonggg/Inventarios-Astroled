import 'package:flutter/foundation.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PaqueteItem {
  final int numero;
  final String tipo;
  final String unidad;
  final int articulosCount;
  final double pesoTotal;
  final double pesoMaximo;
  final Map<String, double> articulos; // itemCode -> cantidad asignada
  final Map<String, String> nombres; // itemCode -> nombre del articulo

  PaqueteItem({
    required this.numero,
    required this.tipo,
    this.unidad = 'Piezas',
    this.articulosCount = 0,
    this.pesoTotal = 0.0,
    this.pesoMaximo = 12.0,
    Map<String, double>? articulos,
    Map<String, String>? nombres,
  })  : articulos = articulos ?? <String, double>{},
        nombres = nombres ?? <String, String>{};
}

class EmbalajeManager extends ChangeNotifier {
  static final EmbalajeManager _instance = EmbalajeManager._internal();
  factory EmbalajeManager() => _instance;
  EmbalajeManager._internal();

  // docInterno -> Lista de paquetes
  final Map<String, List<PaqueteItem>> _docPaquetes = {};

  List<PaqueteItem> getPaquetes(String docInterno) {
    return _docPaquetes[docInterno] ?? [];
  }

  void syncFromBackend(String docInterno, List<dynamic> rawList) {
    final List<PaqueteItem> items = [];
    for (final p in rawList) {
      if (p is Map) {
        final num = castToType<int>(p['packageNum']) ??
            castToType<int>(p['nroPaquete']) ??
            castToType<int>(p['numero']);
        if (num != null) {
          final tipo = (p['tipoPaquete'] ?? p['tipo'] ?? 'Caja').toString();
          final arts = castToType<int>(p['articulos']) ?? 0;
          final pesoT = castToType<double>(p['pesoTotal']) ?? 0.0;
          final pesoM = castToType<double>(p['pesoMaximo']) ?? 12.0;
          items.add(PaqueteItem(
            numero: num,
            tipo: tipo,
            articulosCount: arts,
            pesoTotal: pesoT,
            pesoMaximo: pesoM,
          ));
        }
      }
    }
    _docPaquetes[docInterno] = items;
    notifyListeners();
  }

  PaqueteItem? getPaquete(String docInterno, int numero) {
    final list = getPaquetes(docInterno);
    try {
      return list.firstWhere((p) => p.numero == numero);
    } catch (_) {
      return null;
    }
  }

  PaqueteItem addPaquete(String docInterno, String tipo, [String unidad = 'Piezas', int? serverPackageNum]) {
    _docPaquetes[docInterno] ??= [];
    final currentList = _docPaquetes[docInterno]!;
    final nextNum = serverPackageNum ??
        (currentList.isEmpty
            ? 1
            : currentList.map((p) => p.numero).reduce((a, b) => a > b ? a : b) + 1);

    final newPaquete = PaqueteItem(
      numero: nextNum,
      tipo: tipo,
      unidad: unidad,
    );
    currentList.add(newPaquete);
    notifyListeners();
    return newPaquete;
  }

  bool removePaquete(String docInterno, int numero) {
    final list = _docPaquetes[docInterno];
    if (list == null) return false;
    list.removeWhere((p) => p.numero == numero);
    notifyListeners();
    return true;
  }

  double getTotalAssigned(String docInterno, String itemCode) {
    final list = getPaquetes(docInterno);
    double total = 0;
    for (final p in list) {
      total += p.articulos[itemCode] ?? 0.0;
    }
    return total;
  }

  bool transferToPackage({
    required String docInterno,
    required int numeroPaquete,
    required String itemCode,
    String? itemName,
    required double cantidad,
    required double maxDisponible,
  }) {
    if (cantidad <= 0) return false;
    final paquete = getPaquete(docInterno, numeroPaquete);
    if (paquete == null) return false;

    final actualQty = cantidad > maxDisponible ? maxDisponible : cantidad;
    if (actualQty <= 0) return false;

    paquete.articulos[itemCode] = (paquete.articulos[itemCode] ?? 0.0) + actualQty;
    if (itemName != null && itemName.isNotEmpty) {
      paquete.nombres[itemCode] = itemName;
    }
    notifyListeners();
    return true;
  }

  bool transferFromPackage({
    required String docInterno,
    required int numeroPaquete,
    required String itemCode,
    required double cantidad,
  }) {
    if (cantidad <= 0) return false;
    final paquete = getPaquete(docInterno, numeroPaquete);
    if (paquete == null) return false;

    final currentInPaq = paquete.articulos[itemCode] ?? 0.0;
    if (currentInPaq <= 0) return false;

    final actualQty = cantidad > currentInPaq ? currentInPaq : cantidad;
    final remaining = currentInPaq - actualQty;
    if (remaining <= 0) {
      paquete.articulos.remove(itemCode);
    } else {
      paquete.articulos[itemCode] = remaining;
    }
    notifyListeners();
    return true;
  }
}
