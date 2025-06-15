import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../domain/entities/advert_model.dart'; // Ilan sınıfın burada olmalı

class IlanlarPage extends StatefulWidget {
  final int pageSize;
  const IlanlarPage({super.key, this.pageSize = 20});

  @override
  State<IlanlarPage> createState() => _IlanlarPageState();
}
class _IlanlarPageState extends State<IlanlarPage> {
  late Future<List<Ilan>> ilanlarFuture;

  @override
  void initState() {
    super.initState();
    ilanlarFuture = fetchIlans(20); // örn. 20 ilan çek
  }

  Future<List<Ilan>> fetchIlans(int pageSize) async {
    final response = await http.post(
      Uri.parse('https://myprinter.tr/db/getAdvertsWPageSize'),
      body: jsonEncode({'pageSize': pageSize}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Ilan.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ilanlar');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İlanlar')),
      body: FutureBuilder<List<Ilan>>(
        future: ilanlarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('İlan bulunamadı'));
          }

          final ilanlar = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: ilanlar.length,
            itemBuilder: (context, index) {
              final ilan = ilanlar[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: ilan.pic != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(ilan.pic!, fit: BoxFit.cover, width: double.infinity),
                      )
                          : Container(color: Colors.grey[300]),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ilan.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('${ilan.budget} TL', style: TextStyle(color: Colors.green)),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
