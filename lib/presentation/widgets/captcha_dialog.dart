import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CaptchaDialog extends StatefulWidget {
  final Function(String token) onVerified;

  const CaptchaDialog({super.key, required this.onVerified});

  @override
  State<CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  late final WebViewController _controller;
  bool _isProcesado = false;

  @override
  void initState() {
    super.initState();

    const String htmlContent = '''
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <title>CitaPro Captcha</title>
      <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
      <style>
        body, html {
          margin: 0;
          padding: 0;
          width: 100%;
          height: 100%;
          display: flex;
          justify-content: center;
          align-items: center;
          background-color: #FFFFFF; /* Fondo sólido para evitar colapso del emulador */
          overflow: hidden;
        }
      </style>
    </head>
    <body>

      <div class="cf-turnstile" data-sitekey="1x00000000000000000000AA" data-callback="onVerify"></div>

      <script>
        function onVerify(token) {
          try {
            if (window.onCaptchaVerified) {
              window.onCaptchaVerified.postMessage(token);
            }
          } catch (e) {
            console.error("Error transmitiendo token:", e);
          }
        }
      </script>

    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white) // Fondo blanco sólido para liberar memoria RAM del emulador
      ..addJavaScriptChannel(
        'onCaptchaVerified',
        onMessageReceived: (JavaScriptMessage message) {
          if (_isProcesado) return;
          _isProcesado = true;

          // Primero cerramos el diálogo para liberar el hilo de la interfaz
          if (mounted) {
            Navigator.of(context).pop();
            // Inmediatamente después ejecutamos tu función de éxito para avanzar
            widget.onVerified(message.message);
          }
        },
      );

    _controller.loadHtmlString(htmlContent, baseUrl: 'https://challenges.cloudflare.com');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Verificación de Seguridad", textAlign: TextAlign.center),
      content: SizedBox(
        width: 320,
        height: 120,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}