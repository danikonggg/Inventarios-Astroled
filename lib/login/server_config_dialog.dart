import 'package:flutter/material.dart';
import '/backend/api_requests/server_config.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  final _controller = TextEditingController(text: ServerConfig.baseUrl);
  bool _busy = false;
  String? _message;
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run({required bool save}) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final url = ServerConfig.normalize(_controller.text);
      if (save) {
        await ServerConfig.save(url);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final result = await ServerConfig.probe(url);
        if (mounted)
          setState(() {
            _message = result;
            _error = false;
          });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = error is FormatException
              ? error.message
              : save
                  ? 'No se pudo guardar la dirección. Intenta de nuevo.'
                  : 'No se pudo conectar. Revisa la dirección, la red y que la API esté encendida.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: AlertDialog(
          title: const Text('Configurar servidor'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Esta dirección se guarda en este dispositivo hasta que la cambies o borres los datos de la app.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    enabled: !_busy,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Dirección de la API',
                      hintText: 'http://192.168.1.73:5123/api',
                      helperText:
                          'Sin ruta se agrega /api. Incluye el puerto si aplica.',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() => _message = null),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _controller.text = ServerConfig.defaultUrl;
                              _message = null;
                            }),
                    child: const Text('Usar dirección original'),
                  ),
                  if (_busy) const LinearProgressIndicator(),
                  if (_message != null)
                    Text(_message!,
                        style: TextStyle(
                          color: _error
                              ? Theme.of(context).colorScheme.error
                              : null,
                        )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: _busy ? null : () => _run(save: false),
                child: const Text('Probar conexión')),
            FilledButton(
                onPressed: _busy ? null : () => _run(save: true),
                child: const Text('Guardar')),
          ],
        ),
      );
}
