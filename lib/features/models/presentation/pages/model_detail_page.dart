import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../adverts/domain/entities/advert_model.dart';
import '../../../auth/domain/repository/auth_repository.dart';
import '../../domain/entity/model.dart';

class ModelDetailPage extends StatefulWidget {
  final Model model;

  const ModelDetailPage({super.key, required this.model});

  @override
  State<ModelDetailPage> createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form field controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _filamentType = 'PLA';
  String _fillRate = '20%';
  String _support = 'Hayır';
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    // Model adını varsayılan başlık olarak ayarla
    _titleController.text = '${widget.model.title} Baskı İsteği';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitIlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthRepository().getCurrentUser();
      if (currentUser == null) throw Exception('Kullanıcı oturumu açık değil.');

      final idResponse = await http.post(
        Uri.parse('https://myprinter.tr/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': currentUser.email}),
      );

      if (idResponse.statusCode != 200) {
        throw Exception('Kullanıcı ID alınamadı: ${idResponse.body}');
      }

// Düz metin olduğu için doğrudan alıyoruz
      final String userId = idResponse.body.trim();

      final ilan = IlanWHid(
        budget: _budgetController.text,
        createdBy: userId,  // Buraya direkt uid atıyoruz
        custom: _custom,
        filamentType: _filamentType,
        fillRate: _fillRate,
        support: _support,
        title: _titleController.text,
        modelid: widget.model.modelid,
        offerIds: [],
        note: _noteController.text,
        fileURL: widget.model.url,
        pic: widget.model.pic,
      );


      final wrappedJson = {'ilan': ilan.toJson()};

      final response = await http.post(
        Uri.parse('https://myprinter.tr/db/publishAdvert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(wrappedJson),
      );

      debugPrint('API Yanıtı: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla oluşturuldu!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İstek zaman aşımına uğradı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }





  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.model.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Görsel
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.model.pic,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Kart içi bilgiler
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Kategori', widget.model.category),
                    _buildDetailRow('Oluşturan', widget.model.createdBy),
                    _buildDetailRow('Etiketler', widget.model.tags.join(', ')),
                    _buildDetailRow('Ek Bilgi', widget.model.additional),
                    const SizedBox(height: 12),

                    // Model Dosyaları Butonu (Radius'lu Expansion)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        collapsedBackgroundColor: Colors.grey.shade100,
                        backgroundColor: Colors.grey.shade100,
                        title: Center(
                          child: Text(
                            'Model Dosyalarını Göster',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        leading: const Icon(Icons.folder_open),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                        children: widget.model.url.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final url = entry.value;
                          return ListTile(
                            title: Text('Dosya $index'),
                            subtitle: Text(url, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.download_rounded),
                              onPressed: () {
                                // URL'yi indirilebilir yapmak burada
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // YATAYI KAPLAYAN BUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  setState(() => _showForm = !_showForm);
                },
                child: Text(_showForm
                    ? 'İptal'
                    : 'Bu Model İçin İlan Oluştur'),
              ),
            ),
            const SizedBox(height: 16),

            // FORM YAVAŞ AÇILSIN
            // FORM ANİMASYONU İÇİN GÜNCELLENMİŞ KISIM
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutQuad,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge, // Kenarlardan taşmaları keser
              child: _showForm
                  ? Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildFormArea(),
              )
                  : const SizedBox(height: 0), // Tamamen kapanması için height: 0
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFormArea() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_titleController, 'İlan Başlığı', validator: true),
          const SizedBox(height: 12),
          _buildTextField(_budgetController, 'Bütçe (TL)',
              inputType: TextInputType.number, validator: true),
          const SizedBox(height: 12),
          _buildDropdown('Filament Türü', _filamentType, ['PLA', 'ABS', 'PETG', 'TPU'],
                  (val) => setState(() => _filamentType = val!)),
          const SizedBox(height: 12),
          _buildDropdown('Doluluk Oranı', _fillRate,
              ['20%', '40%', '60%', '80%', '100%'],
                  (val) => setState(() => _fillRate = val!)),
          const SizedBox(height: 12),
          _buildDropdown('Destek Gerekli mi?', _support, ['Evet', 'Hayır'],
                  (val) => setState(() => _support = val!)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Özel Tasarım Gerekli mi?'),
            value: _custom,
            onChanged: (val) => setState(() => _custom = val),
          ),
          const SizedBox(height: 12),
          _buildTextField(_noteController, 'Ek Notlar', maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitIlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('İlanı Oluştur'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool validator = false, TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator
          ? (val) {
        if (val == null || val.isEmpty) return 'Lütfen $label girin';
        return null;
      }
          : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }




  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}