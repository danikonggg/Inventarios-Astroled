import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _nombreEmpleado = prefs.getString('ff_nombreEmpleado') ?? _nombreEmpleado;
    });
    _safeInit(() {
      _baseDsap = prefs.getString('ff_baseDsap') ?? _baseDsap;
    });
    _safeInit(() {
      _idUsuario = prefs.getString('ff_idUsuario') ?? _idUsuario;
    });
    _safeInit(() {
      _isLogged = prefs.getBool('ff_isLogged') ?? _isLogged;
    });
    _safeInit(() {
      _modulosUsuario = prefs.getString('ff_modulosUsuario') ?? _modulosUsuario;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _nombreEmpleado = '';
  String get nombreEmpleado => _nombreEmpleado;
  set nombreEmpleado(String value) {
    _nombreEmpleado = value;
    prefs.setString('ff_nombreEmpleado', value);
  }

  String _baseDsap = '';
  String get baseDsap => _baseDsap;
  set baseDsap(String value) {
    _baseDsap = value;
    prefs.setString('ff_baseDsap', value);
  }

  String _idUsuario = '';
  String get idUsuario => _idUsuario;
  set idUsuario(String value) {
    _idUsuario = value;
    prefs.setString('ff_idUsuario', value);
  }

  bool _isLogged = false;
  bool get isLogged => _isLogged;
  set isLogged(bool value) {
    _isLogged = value;
    prefs.setBool('ff_isLogged', value);
  }

  String _almacen = '';
  String get almacen => _almacen;
  set almacen(String value) {
    _almacen = value;
  }

  String _codigoBarras = '';
  String get codigoBarras => _codigoBarras;
  set codigoBarras(String value) {
    _codigoBarras = value;
  }

  int _unidad = 0;
  int get unidad => _unidad;
  set unidad(int value) {
    _unidad = value;
  }

  String _globalBarcode = '';
  String get globalBarcode => _globalBarcode;
  set globalBarcode(String value) {
    _globalBarcode = value;
  }

  int _TipoDoc = 1;
  int get TipoDoc => _TipoDoc;
  set TipoDoc(int value) {
    _TipoDoc = value;
  }

  String _NombrePrincipal = 'Documentos abiertos Entrada';
  String get NombrePrincipal => _NombrePrincipal;
  set NombrePrincipal(String value) {
    _NombrePrincipal = value;
  }

  String _Ubicaciones = '';
  String get Ubicaciones => _Ubicaciones;
  set Ubicaciones(String value) {
    _Ubicaciones = value;
  }

  List<String> _MiLista = [];
  List<String> get MiLista => _MiLista;
  set MiLista(List<String> value) {
    _MiLista = value;
  }

  void addToMiLista(String value) {
    MiLista.add(value);
  }

  void removeFromMiLista(String value) {
    MiLista.remove(value);
  }

  void removeAtIndexFromMiLista(int index) {
    MiLista.removeAt(index);
  }

  void updateMiListaAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    MiLista[index] = updateFn(_MiLista[index]);
  }

  void insertAtIndexInMiLista(int index, String value) {
    MiLista.insert(index, value);
  }

  String _DocNumDetalle = '';
  String get DocNumDetalle => _DocNumDetalle;
  set DocNumDetalle(String value) {
    _DocNumDetalle = value;
  }

  String _modulosUsuario = '';
  String get modulosUsuario => _modulosUsuario;
  set modulosUsuario(String value) {
    _modulosUsuario = value;
    prefs.setString('ff_modulosUsuario', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
