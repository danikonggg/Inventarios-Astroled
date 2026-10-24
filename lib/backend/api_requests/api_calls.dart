import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'server_config.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start WSInventarios Group Code

class WSInventariosGroup {
  static String getBaseUrl() => ServerConfig.baseUrl;
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  static LoginCall loginCall = LoginCall();
  static ObtenerDetalleOrdenCall obtenerDetalleOrdenCall =
      ObtenerDetalleOrdenCall();
  static ObtenerDetalleOrdenVCall obtenerDetalleOrdenVCall =
      ObtenerDetalleOrdenVCall();
  static GuardarArticuloCall guardarArticuloCall = GuardarArticuloCall();
  static DocumentoNuevoCall documentoNuevoCall = DocumentoNuevoCall();
  static ConteosCall conteosCall = ConteosCall();
  static ObtenerArticulosPorDocumentoCall obtenerArticulosPorDocumentoCall =
      ObtenerArticulosPorDocumentoCall();
  static ProcesarDocumentoCall procesarDocumentoCall = ProcesarDocumentoCall();
  static DocumentoEntradaCall documentoEntradaCall = DocumentoEntradaCall();
  static DocumentosAbiertosCall documentosAbiertosCall =
      DocumentosAbiertosCall();
  static ArticulosPendientesCall articulosPendientesCall =
      ArticulosPendientesCall();
  static LeerCodigoBarrasCall leerCodigoBarrasCall = LeerCodigoBarrasCall();
  static EliminarArticuloCall eliminarArticuloCall = EliminarArticuloCall();
  static ObtenerArticulosCapturadosCall obtenerArticulosCapturadosCall =
      ObtenerArticulosCapturadosCall();
  static OrdenesPorUsuarioCall ordenesPorUsuarioCall = OrdenesPorUsuarioCall();
  static OrdenesVPorUsuarioCall ordenesVPorUsuarioCall =
      OrdenesVPorUsuarioCall();
  static ObtenerUbicacionesCall obtenerUbicacionesCall =
      ObtenerUbicacionesCall();
  static ObtenerPaquetesCall obtenerPaquetesCall = ObtenerPaquetesCall();
  static DetallePaquetesCall detallePaquetesCall = DetallePaquetesCall();
  static CrearPaqueteCall crearPaqueteCall = CrearPaqueteCall();
  static EliminarPaqueteCall eliminarPaqueteCall = EliminarPaqueteCall();
  static ArticulosDisponiblesEmbalajeCall articulosDisponiblesEmbalajeCall =
      ArticulosDisponiblesEmbalajeCall();
  static ContenidoPaqueteCall contenidoPaqueteCall = ContenidoPaqueteCall();
  static AgregarArticuloPaqueteCall agregarArticuloPaqueteCall =
      AgregarArticuloPaqueteCall();
  static QuitarCantidadPaqueteCall quitarCantidadPaqueteCall =
      QuitarCantidadPaqueteCall();
  static EliminarArticuloPaqueteCall eliminarArticuloPaqueteCall =
      EliminarArticuloPaqueteCall();
  static TipoPaquetesCall tipoPaquetesCall = TipoPaquetesCall();
  static UnidadesPesoCall unidadesPesoCall = UnidadesPesoCall();
  static SolicitudesTrasladoCall solicitudesTrasladoCall =
      SolicitudesTrasladoCall();
  static ObtenerDetalleSolicitudTrasladoCall
      obtenerDetalleSolicitudTrasladoCall =
          ObtenerDetalleSolicitudTrasladoCall();
}

class LoginCall {
  Future<ApiCallResponse> call({
    String? username = '',
    String? password = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "username": "${escapeStringForJson(username)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Login',
      apiUrl: '$baseUrl/Login',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  String? respuestaMensaje(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  String? nombreEmp(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.valores.nombreEmpleado''',
      ));
  String? basedSAP(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.valores.baseSAP''',
      ));
  dynamic usuariosap(dynamic response) => getJsonField(
        response,
        r'''$.valores.user''',
      );
}

class ObtenerDetalleOrdenCall {
  Future<ApiCallResponse> call({
    int? docEntry,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerDetalleOrden',
      apiUrl: '$baseUrl/DocumentoEntrada/ObtenerDetalleOrden/$docEntry',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? docEntry(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.docEntry''',
      ));
  String? docNum(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.docNum''',
      ));
  String? cardCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.cardCode''',
      ));
  String? cardName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.cardName''',
      ));
  String? docDate(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.docDate''',
      ));
  List? lineas(dynamic response) => getJsonField(
        response,
        r'''$.lineas''',
        true,
      ) as List?;
  int? lineNUm(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.lineas[:].lineNum''',
      ));
  String? itemCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].itemCode''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].descripcion''',
      ));
  double? cantidad(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].cantidad''',
      ));
  double? cantidadPendiente(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].cantidadPendiente''',
      ));
  double? precio(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].precio''',
      ));
  String? almacen(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].almacen''',
      ));
}

class ObtenerDetalleOrdenVCall {
  Future<ApiCallResponse> call({
    int? docEntry,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerDetalleOrdenV',
      apiUrl: '$baseUrl/DocumentoEntrada/ObtenerDetalleOrdenV/$docEntry',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? docEntry(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.docEntry''',
      ));
  String? docNum(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.docNum''',
      ));
  String? cardCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.cardCode''',
      ));
  String? cardName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.cardName''',
      ));
  String? docDate(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.docDate''',
      ));
  List? lineas(dynamic response) => getJsonField(
        response,
        r'''$.lineas''',
        true,
      ) as List?;
  int? lineNUm(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.lineas[:].lineNum''',
      ));
  String? itemCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].itemCode''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].descripcion''',
      ));
  double? cantidad(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].cantidad''',
      ));
  double? cantidadPendiente(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].cantidadPendiente''',
      ));
  double? precio(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.lineas[:].precio''',
      ));
  String? almacen(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lineas[:].almacen''',
      ));
}

class GuardarArticuloCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    String? codigoArticulo = '',
    String? nombre = '',
    String? codigoBarras = '',
    int? cantidad,
    String? lote = '',
    String? almacenO = '',
    String? almacenD = '',
    String? usuario = '',
    String? tipoDocumento = '',
    int? unidad,
    double? precio,
    String? fecha = '',
    String? ubicacionO = '',
    String? ubicacionD = '',
    String? linea = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final requestPayload = {
      'docCode': docCode,
      'codigoArticulo': codigoArticulo,
      'nombre': nombre,
      'codigoBarras': codigoBarras,
      'linea': linea ?? '',
      'cantidad': cantidad,
      'lote': lote,
      'pedimento': '',
      'almacenO': almacenO,
      'almacenD': almacenD,
      'ubicacionO': ubicacionO,
      'ubicacionD': ubicacionD,
      'precio': precio,
      'impuesto': '',
      'fecha': fecha,
      'usuario': usuario,
      'tipoDocumento': tipoDocumento,
      'unidad': '$unidad',
    };
    final ffApiRequestBody = jsonEncode(tipoDocumento == '4' ? {
      'DocCode': docCode,
      'TipoDocumento': '4',
      'Usuario': usuario,
      'CodigoArticulo': codigoArticulo,
      'CodigoBarras': codigoBarras,
      'Linea': linea,
      'Cantidad': cantidad,
      'AlmacenD': almacenD,
      'UbicacionD': ubicacionD,
      'Lote': lote,
      'Unidad': 0,
    } : requestPayload);
    if (kDebugMode) {
      debugPrint('[API][GuardarArticulo] request.json.start');
      debugPrint(const JsonEncoder.withIndent('  ').convert(jsonDecode(ffApiRequestBody)));
      debugPrint('[API][GuardarArticulo] request.json.end');
    }
    return ApiManager.instance.makeApiCall(
      callName: 'GuardarArticulo',
      apiUrl: '$baseUrl/DocumentoEntrada/GuardarArticulo',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': tipoDocumento == '4'
            ? 'application/json'
            : 'application/json-patch+json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DocumentoNuevoCall {
  Future<ApiCallResponse> call({
    String? documento = '',
    String? estado = '',
    String? fecha = '',
    String? usuario = '',
    String? almacen0 = '',
    String? referencia = '',
    String? baseType = '',
    String? baseEntry = '',
    String? comentarios = '',
    String? pedimento = '',
    String? socio = '',
    String? almacenD = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "Documento": "${escapeStringForJson(documento)}",
  "Estado": "${escapeStringForJson(estado)}",
  "Fecha": "${escapeStringForJson(fecha)}",
  "Usuario": "${escapeStringForJson(usuario)}",
  "Socio": "${escapeStringForJson(socio)}",
  "AlmacenO": "${escapeStringForJson(almacen0)}",
  "AlmacenD": "${escapeStringForJson(almacenD)}",
  "Referencia": "${escapeStringForJson(referencia)}",
  "BaseType": "${escapeStringForJson(baseType)}",
  "BaseEntry": "${escapeStringForJson(baseEntry)}",
  "Comentarios": "${escapeStringForJson(comentarios)}",
  "Pedimento": "${escapeStringForJson(pedimento)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'DocumentoNuevo',
      apiUrl: '$baseUrl/DocumentoEntrada/DocumentoNuevo',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: documento == '4'
          ? jsonEncode({'Documento': '4', 'Usuario': usuario,
              'BaseType': '1000', 'BaseEntry': baseEntry})
          : ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ObtenerArticulosPorDocumentoCall {
  Future<ApiCallResponse> call({
    String? docId = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerArticulosPorDocumento',
      apiUrl: '$baseUrl/DocumentoEntrada/ObtenerArticulos/$docId',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ProcesarDocumentoCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    String? docId = '',
    String? comentariosFF = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final effectiveDocCode = (docCode != null && docCode.isNotEmpty)
        ? docCode
        : (docId ?? '');

    Map<String, dynamic> params = {};
    if (comentariosFF != null && comentariosFF.isNotEmpty) {
      params['comentariosFF'] = comentariosFF;
    }

    final response = await ApiManager.instance.makeApiCall(
      callName: 'ProcesarDocumento',
      apiUrl: '$baseUrl/DocumentoEntrada/Procesar/$effectiveDocCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'ProcesarDocumento',
      method: 'GET',
      endpoint: '/DocumentoEntrada/Procesar/$effectiveDocCode${params.isNotEmpty ? '?comentariosFF=${params['comentariosFF']}' : ''}',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  String? documentoInterno(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.documentoInterno''',
      ));
  int? sapDocEntry(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.sapDocEntry''',
      ));
  int? sapDocNum(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.sapDocNum''',
      ));
}

class DocumentoEntradaCall {
  Future<ApiCallResponse> call({
    String? docEntry = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Documento Entrada',
      apiUrl: '$baseUrl/DocumentoEntrada',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      params: {
        'docEntry': docEntry,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
  List<int>? docNum(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].docNum''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? docEntry(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].docEntry''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? cardCode(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].cardCode''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? cardName(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].cardName''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? docDate(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].docDate''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<double>? docTotal(dynamic response) => (getJsonField(
        response,
        r'''$.valores[:].docTotal''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<double>(x))
          .withoutNulls
          .toList();
}

class DocumentosAbiertosCall {
  Future<ApiCallResponse> call({
    int? tipo,
    String? usuario = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'DocumentosAbiertos',
      apiUrl: '$baseUrl/DocumentoEntrada/DocumentosAbiertos/$tipo/$usuario',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ArticulosPendientesCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ArticulosPendientes',
      apiUrl: '$baseUrl/DocumentoEntrada/ArticulosPendientes/$docCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class LeerCodigoBarrasCall {
  Future<ApiCallResponse> call({
    String? codigoBarras = '',
    String? almacen = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final requestPayload = {
      'codigoBarras': codigoBarras,
      'almacen': almacen,
    };
    final ffApiRequestBody = jsonEncode(requestPayload);
    if (kDebugMode) {
      debugPrint('[API][LeerCodigoBarras] request.json.start');
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestPayload));
      debugPrint('[API][LeerCodigoBarras] request.json.end');
    }
    return ApiManager.instance.makeApiCall(
      callName: 'LeerCodigoBarras',
      apiUrl: '$baseUrl/DocumentoEntrada/LeerCodigoBarra',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class EliminarArticuloCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    String? codigoArticulo = '',
    int? linea,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "docCode": "${escapeStringForJson(docCode)}",
  "codigoArticulo": "${escapeStringForJson(codigoArticulo)}",
  "linea": $linea
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'EliminarArticulo',
      apiUrl: '$baseUrl/DocumentoEntrada/EliminarArticuloCapturado',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ObtenerArticulosCapturadosCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerArticulosCapturados',
      apiUrl: '$baseUrl/DocumentoEntrada/ObtenerArticulosCapturados/$docCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class OrdenesPorUsuarioCall {
  Future<ApiCallResponse> call({
    String? usuarioAsig = '',
    String? docEntry = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Ordenes Por Usuario',
      apiUrl: '$baseUrl/OrdenesCompra/por-usuario',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'usuarioAsig': usuarioAsig,
        'docEntry': docEntry,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? error(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.Valores''',
        true,
      ) as List?;
  int? docEntry(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.Valores[:].DocEntry''',
      ));
  String? almacen(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.Valores[:].Almacen''',
      ));
  double? docTotal(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.Valores[:].DocTotal''',
      ));
  String? docDate(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.Valores[:].DocDate''',
      ));
  String? cardName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.Valores[:].CardName''',
      ));
  String? cardCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.Valores[:].CardCode''',
      ));
  int? docNum(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.Valores[:].DocNum''',
      ));
}

class OrdenesVPorUsuarioCall {
  Future<ApiCallResponse> call({
    String? usuarioAsig = '',
    String? docEntry = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'OrdenesV Por Usuario ',
      apiUrl: '$baseUrl/OrdenesVenta/por-usuarioV',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'usuarioAsig': usuarioAsig,
        'docEntry': docEntry,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? error(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
}

class ObtenerUbicacionesCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerUbicaciones',
      apiUrl: '$baseUrl/DocumentoEntrada/ObtenerUbicaciones',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SolicitudesTrasladoCall {
  Future<ApiCallResponse> call({
    String? usuario = '',
    String? usuarioAsig = '',
    String? fechaDesde = '',
    String? fechaHasta = '',
    String? docEntry = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final params = <String, dynamic>{};
    if (usuario != null && usuario.isNotEmpty) params['usuario'] = usuario;
    if (usuarioAsig != null && usuarioAsig.isNotEmpty) {
      params['usuarioAsig'] = usuarioAsig;
    }
    if (fechaDesde != null && fechaDesde.isNotEmpty) {
      params['fechaDesde'] = fechaDesde;
    }
    if (fechaHasta != null && fechaHasta.isNotEmpty) {
      params['fechaHasta'] = fechaHasta;
    }
    if (docEntry != null && docEntry.isNotEmpty) params['docEntry'] = docEntry;

    return ApiManager.instance.makeApiCall(
      callName: 'SolicitudesTraslado',
      apiUrl: '$baseUrl/DocumentoEntrada/SolicitudesTraslado',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? error(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class ObtenerDetalleSolicitudTrasladoCall {
  Future<ApiCallResponse> call({
    int? docEntry,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ObtenerDetalleSolicitudTraslado',
      apiUrl:
          '$baseUrl/DocumentoEntrada/ObtenerDetalleSolicitudTraslado/$docEntry',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? error(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  dynamic valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
      );
  List? lineas(dynamic response) => getJsonField(
        response,
        r'''$.valores.lineas''',
        true,
      ) as List?;
}

void _logEmbalajeCall({
  required String callName,
  required String method,
  required String endpoint,
  dynamic payload,
  required ApiCallResponse response,
}) {
  if (!kDebugMode) return;

  final isSuccess = response.isEmbalajeSuccess;
  final icon = isSuccess ? '✅' : '❌';
  final status = response.statusCode;

  debugPrint('──────────────────────────────────────────────────');
  debugPrint('$icon [$callName] $method $endpoint (HTTP $status)');
  if (payload != null && payload.toString().isNotEmpty) {
    debugPrint('   📥 Request: $payload');
  }

  if (!isSuccess) {
    final codigo = response.embalajeCodigo;
    final desc = response.embalajeDescripcion;
    debugPrint('   ⚠️ Error Backend: ${codigo != null ? "[$codigo] " : ""}$desc');
  } else {
    final json = response.jsonBody;
    if (json is Map) {
      final valores = json['valores'];
      if (valores is List) {
        debugPrint('   📦 Lista (${valores.length} elementos):');
        for (var i = 0; i < valores.length; i++) {
          final item = valores[i];
          if (item is Map) {
            final summary = item.entries.map((e) => '${e.key}: ${e.value}').join(', ');
            debugPrint('      [$i] $summary');
          } else {
            debugPrint('      [$i] $item');
          }
        }
      } else if (valores is Map) {
        if (valores.containsKey('articulos') && valores['articulos'] is List) {
          final articulos = valores['articulos'] as List;
          final pesoT = valores['pesoTotal'];
          final pesoM = valores['pesoMaximo'];
          debugPrint('   📦 Contenido: ${articulos.length} líneas | Peso total: ${pesoT}kg / Máx: ${pesoM}kg');
          for (var i = 0; i < articulos.length; i++) {
            final art = articulos[i];
            if (art is Map) {
              debugPrint('      • Línea [code: ${art['code']}]: ${art['itemCode']} - ${art['descripcion']} (Cant: ${art['cantidad']}, Peso: ${art['peso']}kg)');
            } else {
              debugPrint('      • $art');
            }
          }
        } else {
          final summary = valores.entries.map((e) => '${e.key}: ${e.value}').join(', ');
          debugPrint('   📦 Valores: $summary');
        }
      }
      if (json['descripcion'] != null && json['descripcion'].toString().isNotEmpty) {
        debugPrint('   💬 Mensaje: ${json['descripcion']}');
      }
      if (json['sapDocNum'] != null) {
        debugPrint('   📋 Entrega SAP creada: #${json['sapDocNum']} (DocEntry: ${json['sapDocEntry']})');
      }
    }
  }
  debugPrint('──────────────────────────────────────────────────');
}

class ObtenerPaquetesCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'ObtenerPaquetes',
      apiUrl: '$baseUrl/Embalaje/Paquetes/$docCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'ObtenerPaquetes',
      method: 'GET',
      endpoint: '/Embalaje/Paquetes/$docCode',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class DetallePaquetesCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'DetallePaquetes',
      apiUrl: '$baseUrl/Embalaje/DetallePaquetes/$docCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'DetallePaquetes',
      method: 'GET',
      endpoint: '/Embalaje/DetallePaquetes/$docCode',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class CrearPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    String? tipoDocumento = '2',
    String? tipoPaquete,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "docCode": "${escapeStringForJson(docCode)}",
  "tipoDocumento": "${escapeStringForJson(tipoDocumento ?? '2')}"
}''';

    final response = await ApiManager.instance.makeApiCall(
      callName: 'CrearPaquete',
      apiUrl: '$baseUrl/Embalaje/CrearPaquete',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'CrearPaquete',
      method: 'POST',
      endpoint: '/Embalaje/CrearPaquete',
      payload: 'docCode: $docCode, tipoDocumento: ${tipoDocumento ?? '2'}',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  dynamic valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
      );
  int? packageNum(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.valores.packageNum''',
      ));
}

class EliminarPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    int? packageNum,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'EliminarPaquete',
      apiUrl: '$baseUrl/Embalaje/Paquetes/$docCode/$packageNum',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'EliminarPaquete',
      method: 'DELETE',
      endpoint: '/Embalaje/Paquetes/$docCode/$packageNum',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
}

class ArticulosDisponiblesEmbalajeCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'ArticulosDisponiblesEmbalaje',
      apiUrl: '$baseUrl/Embalaje/ArticulosDisponibles/$docCode',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'ArticulosDisponibles',
      method: 'GET',
      endpoint: '/Embalaje/ArticulosDisponibles/$docCode',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class ContenidoPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    int? packageNum,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'ContenidoPaquete',
      apiUrl: '$baseUrl/Embalaje/ContenidoPaquete/$docCode/$packageNum',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'ContenidoPaquete',
      method: 'GET',
      endpoint: '/Embalaje/ContenidoPaquete/$docCode/$packageNum',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  dynamic valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
      );
  List? articulos(dynamic response) => getJsonField(
        response,
        r'''$.valores.articulos''',
        true,
      ) as List?;
  double? pesoTotal(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.valores.pesoTotal''',
      ));
  double? pesoMaximo(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.valores.pesoMaximo''',
      ));
}

class AgregarArticuloPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    int? packageNum,
    String? itemCode = '',
    int? uomEntry = 0,
    dynamic cantidad = 0.0,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "docCode": "${escapeStringForJson(docCode)}",
  "packageNum": $packageNum,
  "itemCode": "${escapeStringForJson(itemCode)}",
  "uomEntry": ${uomEntry ?? 0},
  "cantidad": $cantidad
}''';

    final response = await ApiManager.instance.makeApiCall(
      callName: 'AgregarArticuloPaquete',
      apiUrl: '$baseUrl/Embalaje/AgregarArticulo',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'AgregarArticulo',
      method: 'POST',
      endpoint: '/Embalaje/AgregarArticulo',
      payload: 'docCode: $docCode, paq: #$packageNum, item: $itemCode, cant: $cantidad',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  dynamic valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
      );
  int? code(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.valores.code''',
      ));
  double? pesoAcumuladoPaquete(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.valores.pesoAcumuladoPaquete''',
      ));
}

class QuitarCantidadPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    int? packageNum,
    String? itemCode = '',
    dynamic cantidad = 0.0,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "docCode": "${escapeStringForJson(docCode)}",
  "packageNum": $packageNum,
  "itemCode": "${escapeStringForJson(itemCode)}",
  "cantidad": $cantidad
}''';

    final response = await ApiManager.instance.makeApiCall(
      callName: 'QuitarCantidadPaquete',
      apiUrl: '$baseUrl/Embalaje/QuitarCantidad',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'QuitarCantidad',
      method: 'POST',
      endpoint: '/Embalaje/QuitarCantidad',
      payload: 'docCode: $docCode, paq: #$packageNum, item: $itemCode, cant: $cantidad',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
}

class EliminarArticuloPaqueteCall {
  Future<ApiCallResponse> call({
    String? docCode = '',
    int? packageNum,
    int? codeLinea,
  }) async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'EliminarArticuloPaquete',
      apiUrl: '$baseUrl/Embalaje/ElimarArticulo/$docCode/$packageNum/$codeLinea',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'ElimarArticulo',
      method: 'DELETE',
      endpoint: '/Embalaje/ElimarArticulo/$docCode/$packageNum/$codeLinea',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
}

class TipoPaquetesCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'TipoPaquetes',
      apiUrl: '$baseUrl/Embalaje/TipoPaquetes',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'TipoPaquetes',
      method: 'GET',
      endpoint: '/Embalaje/TipoPaquetes',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

class UnidadesPesoCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = WSInventariosGroup.getBaseUrl();
    final response = await ApiManager.instance.makeApiCall(
      callName: 'UnidadesPeso',
      apiUrl: '$baseUrl/Embalaje/UnidadesPeso',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    _logEmbalajeCall(
      callName: 'UnidadesPeso',
      method: 'GET',
      endpoint: '/Embalaje/UnidadesPeso',
      response: response,
    );

    return response;
  }

  bool? respuestaSuccess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? respuestaError(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.error''',
      ));
  int? codigo(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.codigo''',
      ));
  String? descripcion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.descripcion''',
      ));
  List? valores(dynamic response) => getJsonField(
        response,
        r'''$.valores''',
        true,
      ) as List?;
}

extension EmbalajeResponseExtension on ApiCallResponse {
  /// Devuelve true únicamente cuando HTTP es 2xx y `success == true` (o no viene en el JSON).
  /// Crítico porque /api/Embalaje puede responder HTTP 200 con `{"success": false, "error": true, ...}`.
  bool get isEmbalajeSuccess {
    if (hasFailure) return false;
    if (jsonBody is Map) {
      final s = jsonBody['success'];
      if (s is bool) return s;
    }
    return succeeded;
  }

  /// Mensaje o descripción devuelta por el servicio
  String get embalajeDescripcion {
    if (hasFailure) return userMessage;
    if (jsonBody is Map) {
      final desc = jsonBody['descripcion'];
      if (desc != null && desc.toString().isNotEmpty) {
        return desc.toString();
      }
    }
    return 'El servidor no indicó una descripción.';
  }

  /// Código interno de error del servicio
  int? get embalajeCodigo {
    if (jsonBody is Map) {
      final c = jsonBody['codigo'];
      if (c is int) return c;
      if (c != null) return int.tryParse(c.toString());
    }
    return null;
  }
}

/// End WSInventarios Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

class ConteosCall {
  Future<ApiCallResponse> call({required String usuario}) =>
      ApiManager.instance.makeApiCall(
        callName: 'Conteos',
        apiUrl: '${WSInventariosGroup.getBaseUrl()}/DocumentoEntrada/Conteos/${Uri.encodeComponent(usuario)}',
        callType: ApiCallType.GET,
        headers: {'Content-Type': 'application/json'},
        params: {}, returnBody: true, cache: false,
      );
}
