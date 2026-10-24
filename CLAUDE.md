# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`astroled_ofc` is a **FlutterFlow-generated** Flutter app (channel: stable, SDK `>=3.0.0 <4.0.0`) for warehouse/inventory operations backed by SAP Business One (via a custom REST middleware). It handles goods receipt (entrada de mercancías) and goods issue (salida de mercancías) workflows: pulling open purchase/sales orders assigned to a user, capturing line items by barcode scan, and posting captured documents back to the API.

Because this is FlutterFlow-generated code, most files under `lib/` follow FlutterFlow's generated conventions and carry `// Automatic FlutterFlow imports` / `DO NOT REMOVE OR MODIFY THE CODE ABOVE!` markers. If this project is still edited in FlutterFlow, prefer making structural/UI changes there and pulling code back down, rather than hand-editing generated widget files — hand edits in FlutterFlow-managed files can be overwritten on next export. Files under `lib/custom_code/` are the sanctioned place for hand-written logic (see below).

## Commands

Standard Flutter tooling applies; there are no custom scripts/Makefiles.

```bash
flutter pub get                 # install dependencies
flutter run                     # run on a connected device/emulator (or `-d chrome`, `-d windows`, etc.)
flutter analyze                 # static analysis (uses analysis_options.yaml / flutter_lints)
flutter test                    # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter build apk|ios|web|windows    # platform builds
```

Notes:
- `test/widget_test.dart` is the default Flutter counter-app smoke test scaffold and does not exercise this app's actual widgets — there is no real test suite yet.
- `analysis_options.yaml` only overrides `unnecessary_string_escapes: false` from `flutter_lints`; otherwise standard lints apply.

## Architecture

### Entry point & app shell
- [lib/main.dart](lib/main.dart) bootstraps `FlutterFlowTheme`, the custom auth manager, and `FFAppState` (a `ChangeNotifier` singleton, provided via `provider`), then runs `MaterialApp.router` with a `go_router`-based router built in [lib/flutter_flow/nav/nav.dart](lib/flutter_flow/nav/nav.dart).
- `AppStateNotifier` (in `nav.dart`) drives routing based on auth state (`loggedIn`/`showSplashImage`) and is the `refreshListenable` for the router — auth changes trigger automatic redirects between `SplashWidget`, `LoginWidget`, and `PrincipalWidget`.
- [lib/index.dart](lib/index.dart) re-exports every page widget; new pages must be exported here and registered as an `FFRoute` in `nav.dart` to be reachable.

### App-wide state
- [lib/app_state.dart](lib/app_state.dart) (`FFAppState`) holds cross-page state (current employee, SAP base, user id, login flag, scanned barcode, warehouse, etc.), persisted via `shared_preferences` (`ff_*` keys). Read via `FFAppState()` singleton or `context.watch<FFAppState>()`.

### Auth
- Custom (non-Firebase) auth lives in `lib/auth/custom_auth/`: `CustomAuthManager` holds the session (token/refresh token/expiration/user data), persists it to `shared_preferences`, and pushes updates through `astroledOfcAuthUserSubject`/`astroledOfcAuthUserStream` (see `custom_auth_user_provider.dart`). [lib/auth/custom_auth/auth_util.dart](lib/auth/custom_auth/auth_util.dart) exposes the global `authManager` and convenience getters (`currentUserUid`, `currentUserData`, etc.).
- Login itself is a plain API call (`WSInventariosGroup.loginCall`), not a Firebase/OAuth flow — the login page widget calls the API, then calls `authManager.signIn(...)` on success.

### Backend / API layer
- All backend calls go through [lib/backend/api_requests/api_calls.dart](lib/backend/api_requests/api_calls.dart), a single `WSInventariosGroup` class exposing one `*Call` object per endpoint (e.g. `loginCall`, `guardarArticuloCall`, `documentoNuevoCall`, `obtenerArticulosCapturadosCall`, `ordenesPorUsuarioCall`/`ordenesVPorUsuarioCall`, `obtenerUbicacionesCall`, `leerCodigoBarrasCall`, ...). Each call class builds a JSON body/query and delegates to `ApiManager.instance.makeApiCall(...)` ([lib/backend/api_requests/api_manager.dart](lib/backend/api_requests/api_manager.dart)), then exposes typed getters (e.g. `.docEntry(response)`, `.cardName(response)`) that pull fields out of the response via JSONPath (`getJsonField`).
- `WSInventariosGroup.getBaseUrl()` is currently hardcoded to an ngrok tunnel URL — this is a dev/staging backend, expect it to change; check with the user before assuming it's the real endpoint.
- The backend is effectively a SAP Business One integration layer: entities are SAP-flavored (`DocEntry`, `CardCode`/`CardName`, `docCode`, `almacenO`/`almacenD` = source/destination warehouse, `BaseType`/`BaseEntry` for document linking).
- [lib/backend/schema/structs/](lib/backend/schema/structs/) defines `UserStruct` (FlutterFlow "struct" pattern with `fromSerializableMap`/`toSerializableMap` for persistence).

### Pages (feature folders)
Each page lives in its own top-level folder under `lib/`, following the FlutterFlow widget+model pattern: `<page>_widget.dart` (the `StatefulWidget`/UI) paired with `<page>_model.dart` (a `FlutterFlowModel` holding controllers/form state, created via `createModel(context, () => XModel())` in `initState` and disposed in `dispose`). Pages fetch data with `FutureBuilder`s wired directly to `WSInventariosGroup` calls rather than a separate repository/service layer.

Pages, in the warehouse workflow order:
- `splash` → `login` → `principal` (home/menu)
- `entrada_mercancias` (goods receipt entry) → `captura_entrada` (list pending items for a doc, params: `docEntry`, `docInterno`) → `captura_articulos` (scan/capture an item) → `articulos_capturados` (review captured items) → `detalle_orden` (order detail)
- `salida_mercancias` (goods issue) with its own `detalle_orden_v` (sales-order-side detail)
- `ubicaciones` (warehouse locations) and `captura_rapida` (quick capture) are standalone utility flows

### Custom code (hand-written, non-generated)
- [lib/custom_code/actions/scan_barcode.dart](lib/custom_code/actions/scan_barcode.dart): full-screen barcode scanner built on `mobile_scanner`, pushed via `Navigator.push`. On detection it writes the code into `FFAppState().globalBarcode` (no return value — FlutterFlow action outputs aren't used) and auto-closes. Any changes to scan behavior (formats, debounce, haptics) belong here.
- [lib/custom_code/actions/focus_codigo_barras.dart](lib/custom_code/actions/focus_codigo_barras.dart): focus helper for the barcode text field.
- New custom actions must be registered in [lib/custom_code/actions/index.dart](lib/custom_code/actions/index.dart).

### FlutterFlow framework code
`lib/flutter_flow/` contains FlutterFlow's generated framework/util code (theme, widgets, animations, nav helpers, form field controller, custom functions). Treat this as vendored infrastructure — it's regenerated by FlutterFlow exports, so avoid hand-editing unless necessary, and prefer adding new custom logic under `lib/custom_code/` instead.
