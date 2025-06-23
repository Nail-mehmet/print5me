import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/advert_model.dart';

class IlanDetailPage extends StatefulWidget {
  final Ilan ilan;
  const IlanDetailPage({super.key, required this.ilan});

  @override
  State<IlanDetailPage> createState() => _IlanDetailPageState();
}

class _IlanDetailPageState extends State<IlanDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _daysController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = false;

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final offer = {
      "modelid": widget.ilan.modelid,
      "printerId": "printer123", // Giriş yapan yazıcı ID'si
      "createdBy": widget.ilan.createdBy,
      "givenBy": "me", // Teklif veren kişi
      "ilanId": widget.ilan.ilanId,
      "offerAmount": double.parse(_amountController.text),
      "deliveryDays": _daysController.text,
      "note": _noteController.text,
    };

    final response = await http.post(
      Uri.parse('https://myprinter.tr/db/publishOffer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"offer": offer}),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teklif başarıyla gönderildi!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ilan = widget.ilan;
    return Scaffold(
      appBar: AppBar(title: Text(ilan.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ilan.pic != null)
                Image.network(ilan.pic!, width: double.infinity, height: 200, fit: BoxFit.cover),
              SizedBox(height: 16),
              Text("Açıklama: ${ilan.note}"),
              SizedBox(height: 8),
              Text("Bütçe: ${ilan.budget} TL"),
              Divider(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Teklif Ver",),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Teklif Tutarı (₺)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Boş bırakılamaz' : null,
                    ),
                    TextFormField(
                      controller: _daysController,
                      decoration: InputDecoration(labelText: 'Teslim Süresi (gün)'),
                      validator: (v) => v == null || v.isEmpty ? 'Boş bırakılamaz' : null,
                    ),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(labelText: 'Not'),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    _loading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _submitOffer,
                      child: Text('Teklif Gönder'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
