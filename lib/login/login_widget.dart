import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
import 'server_config_dialog.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.codigoUsuarioTextController ??= TextEditingController();
    _model.codigoUsuarioFocusNode ??= FocusNode();

    _model.passwordUsuarioTextController ??= TextEditingController();
    _model.passwordUsuarioFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  width: 100.0,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140.0,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                          ),
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(8.0),
                          child: Semantics(
                            label: 'Configurar servidor',
                            child: IconButton(
                              icon: const Icon(Icons.settings_outlined, size: 20),
                              color: const Color(0xFF757575),
                              onPressed: () async {
                                final saved = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const ServerConfigDialog(),
                                );
                                if (saved == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Servidor guardado. Ya puedes iniciar sesión.')),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 20.0),
                                    child: Container(
                                      width: 72.0,
                                      height: 72.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF006BB8),
                                        borderRadius: BorderRadius.circular(20.0),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 12.0,
                                            color: const Color(0xFF006BB8)
                                                .withValues(alpha: 0.3),
                                            offset: const Offset(0.0, 4.0),
                                          ),
                                        ],
                                      ),
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: Colors.white,
                                        size: 36.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    'Inventarios Astroled',
                                    style: FlutterFlowTheme.of(context)
                                        .displaySmall
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmall
                                                    .fontStyle,
                                          ),
                                          color: const Color(0xFF101213),
                                          fontSize: 30.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .displaySmall
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 24.0),
                                    child: Text(
                                      'SAP Business One',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            color: const Color(0xFF006BB8),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller:
                                          _model.codigoUsuarioTextController,
                                      focusNode: _model.codigoUsuarioFocusNode,
                                      onChanged: (_) => EasyDebounce.debounce(
                                        '_model.codigoUsuarioTextController',
                                        const Duration(milliseconds: 2000),
                                        () async {
                                          _model.codigoUsuarioTextController
                                                  ?.text =
                                              _model.codigoUsuarioTextController
                                                  .text;
                                        },
                                      ),
                                      autofocus: true,
                                      autofillHints: const [AutofillHints.name],
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Usuario ',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              color: const Color(0xFF57636C),
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFF1F4F8),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4B39EF),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E3E7),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E3E7),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F4F8),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: const Color(0xFF101213),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      validator: _model
                                          .codigoUsuarioTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller:
                                          _model.passwordUsuarioTextController,
                                      focusNode:
                                          _model.passwordUsuarioFocusNode,
                                      autofocus: true,
                                      autofillHints: const [AutofillHints.password],
                                      obscureText:
                                          !_model.passwordUsuarioVisibility,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              color: const Color(0xFF57636C),
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFF1F4F8),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4B39EF),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E3E7),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E3E7),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F4F8),
                                        suffixIcon: InkWell(
                                          onTap: () async {
                                            safeSetState(() => _model
                                                    .passwordUsuarioVisibility =
                                                !_model
                                                    .passwordUsuarioVisibility);
                                          },
                                          focusNode:
                                              FocusNode(skipTraversal: true),
                                          child: Icon(
                                            _model.passwordUsuarioVisibility
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: const Color(0xFF57636C),
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: const Color(0xFF101213),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      validator: _model
                                          .passwordUsuarioTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      _model.apiResulti5x =
                                          await WSInventariosGroup.loginCall
                                              .call(
                                        username: _model
                                            .codigoUsuarioTextController.text,
                                        password: _model
                                            .passwordUsuarioTextController.text,
                                      );

                                      final loginResponse =
                                          _model.apiResulti5x;
                                      // A successful login from our API is
                                      // always JSON. On rejected logins,
                                      // though, our API answers with a plain
                                      // text body (e.g. "Usuario inválido",
                                      // Content-Type: text/plain) instead of
                                      // JSON. So jsonBody == null does NOT by
                                      // itself mean we failed to reach our
                                      // API — it could be either that plain
                                      // text rejection or a truly unrelated
                                      // response (e.g. an offline ngrok
                                      // tunnel returning its own error page).
                                      // Content-Type alone doesn't reliably
                                      // separate those two: an offline ngrok
                                      // tunnel can also answer with
                                      // Content-Type: text/plain, so we also
                                      // check the body for ngrok's own error
                                      // markers (e.g. "ERR_NGROK_3200") and
                                      // treat those as an unreachable server,
                                      // never as our API's response.
                                      final contentType = (loginResponse
                                                  ?.getHeader(
                                                      'content-type') ??
                                              '')
                                          .toLowerCase();
                                      final bodyText =
                                          loginResponse?.bodyText.trim() ?? '';
                                      final isNgrokErrorPage = bodyText
                                              .toLowerCase()
                                              .contains('ngrok') &&
                                          bodyText
                                              .toUpperCase()
                                              .contains('ERR_NGROK');
                                      final isPlainTextApiResponse =
                                          contentType.contains('text/plain') &&
                                              bodyText.isNotEmpty &&
                                              !isNgrokErrorPage;
                                      final isApiJsonResponse =
                                          loginResponse?.jsonBody != null;
                                      final reachedApi = isApiJsonResponse ||
                                          isPlainTextApiResponse;
                                      final loginSucceeded =
                                          (loginResponse?.succeeded ??
                                                  false) &&
                                              isApiJsonResponse &&
                                              (WSInventariosGroup.loginCall
                                                          .respuestaError(
                                                        loginResponse
                                                                ?.jsonBody ??
                                                            '',
                                                      ) !=
                                                      true);

                                      if (loginSucceeded) {
                                        FFAppState().nombreEmpleado =
                                            getJsonField(
                                          (_model.apiResulti5x?.jsonBody ?? ''),
                                          r'''$.valores.nombreEmpleado''',
                                        ).toString();
                                        safeSetState(() {});
                                        FFAppState().modulosUsuario =
                                            getJsonField(
                                          (_model.apiResulti5x?.jsonBody ?? ''),
                                          r'''$.valores.modulos''',
                                        ).toString();
                                        safeSetState(() {});
                                        FFAppState().idUsuario = getJsonField(
                                          (_model.apiResulti5x?.jsonBody ?? ''),
                                          r'''$.valores.user''',
                                        ).toString();
                                        safeSetState(() {});
                                        FFAppState().baseDsap = getJsonField(
                                          (_model.apiResulti5x?.jsonBody ?? ''),
                                          r'''$.valores.baseSAP''',
                                        ).toString();
                                        safeSetState(() {});
                                        FFAppState().isLogged = true;
                                        safeSetState(() {});

                                        context.pushNamed(
                                            PrincipalWidget.routeName);
                                      } else {
                                        // statusCode == -1: the request never
                                        // left the device (no internet, DNS
                                        // failure, timeout, unreachable host).
                                        // !reachedApi: we did get a response,
                                        // but it was neither our API's JSON
                                        // nor its plain-text rejection (e.g.
                                        // an offline ngrok tunnel answering
                                        // with its own HTML error page, a
                                        // proxy/gateway page, etc.) — that's
                                        // still "can't reach the server", not
                                        // a rejected login. Only once we know
                                        // we're actually talking to our API
                                        // do we trust its error message / a
                                        // genuine 5xx.
                                        final statusCode =
                                            loginResponse?.statusCode ?? -1;
                                        String errorTitle;
                                        String errorMessage;

                                        if (statusCode == -1) {
                                          errorTitle = 'Error del servidor';
                                          errorMessage =
                                              'No se pudo conectar con el servidor. Es posible que esté caído en este momento. Intenta de nuevo más tarde.';
                                        } else if (!reachedApi) {
                                          errorTitle = 'Error del servidor';
                                          errorMessage =
                                              'El servidor no está disponible en este momento. Es posible que esté caído. Intenta de nuevo más tarde.';
                                        } else if (statusCode >= 500) {
                                          errorTitle = 'Error del servidor';
                                          errorMessage =
                                              'El servidor tuvo un problema al procesar la solicitud. Intenta de nuevo en unos minutos.';
                                        } else if (isApiJsonResponse) {
                                          errorTitle = 'Error';
                                          errorMessage = WSInventariosGroup
                                                  .loginCall
                                                  .respuestaMensaje(
                                                loginResponse?.jsonBody ?? '',
                                              ) ??
                                              'Usuario o contraseña incorrecta';
                                        } else {
                                          errorTitle = 'Error';
                                          errorMessage = 'No se pudo iniciar sesión. Revisa tus datos y la dirección del servidor.';
                                        }

                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              title: Text(errorTitle),
                                              content: Text(errorMessage),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: const Text('Aceptar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }

                                      safeSetState(() {});
                                    },
                                    text: 'Iniciar',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 44.0,
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: const Color(0xFF4B39EF),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 3.0,
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 12.0),
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Inventarios v2',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w300,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w300,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  )
                                ],
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: const Color(0xFF101213),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 100.0,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.network(
                            'https://images.unsplash.com/photo-1514924013411-cbf25faa35bb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1380&q=80',
                          ).image,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
