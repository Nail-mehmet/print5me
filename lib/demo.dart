import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // HttpOverrides için

class PrinterAuthPage extends StatefulWidget {
  @override
  _PrinterAuthPageState createState() => _PrinterAuthPageState();
}

class _PrinterAuthPageState extends State<PrinterAuthPage> {
  String _response = 'Henüz bir istek yapılmadı.';
  bool _isLoading = false;

  Future<void> _sendPostRequest() async {
    setState(() {
      _isLoading = true;
      _response = 'İstek gönderiliyor...';
    });

    final url = Uri.parse('https://myprinter.tr/auth');
    final body = jsonEncode({'email': 'testsatici@gmail.com'});

    print('URL: $url');
    print('Body: $body');
    print('Headers: {\'Content-Type\': \'application/json\'}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));

      print('Yanıt alındı: ${response.statusCode}');
      print('Yanıt body: ${response.body}');

      setState(() {
        if (response.statusCode == 200) {
          final uid = response.body.trim();
          _response = 'Başarılı!\nDurum kodu: ${response.statusCode}\nUID: $uid';
        } else {
          _response = 'Hata!\nDurum kodu: ${response.statusCode}\nMesaj: ${response.body}';
        }
        _isLoading = false;
      });
    } on SocketException catch (e) {
      setState(() {
        _response = 'Network hatası: $e\nİnternet bağlantınızı kontrol edin.';
        _isLoading = false;
      });
    } on http.ClientException catch (e) {
      setState(() {
        _response = 'İstek hatası: $e\nSunucuya ulaşılamıyor.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Printer Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPostRequest,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Post İsteği Gönder'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}