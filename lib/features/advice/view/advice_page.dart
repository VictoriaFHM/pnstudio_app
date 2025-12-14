import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../models/sector_advice.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  late Future<List<SectorAdvice>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadFromAsset();
  }

  Future<List<SectorAdvice>> _loadFromAsset() async {
    final s = await rootBundle.loadString('assets/data/sector_advice.json');
    final list = json.decode(s) as List<dynamic>;
    return list
        .map((e) => SectorAdvice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Widget _buildSmallCard(SectorAdvice item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 56,
                child: item.imageAsset != null
                    ? Image.asset(
                        item.imageAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Center(
                          child: Text('No se pudo cargar la imagen'),
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              const SizedBox(height: 8),
              Text(
                item.sector,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo elegir eficiencia y potencia')),
      body: FutureBuilder<List<SectorAdvice>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¿Cómo elegir la eficiencia y la potencia dependiendo del trabajo?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                // Small cards row (up to 5)
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 800;
                    final cards = items.take(5).map(_buildSmallCard).toList();
                    return isWide
                        ? Row(
                            children: cards
                                .map(
                                  (w) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: w,
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Column(
                            children: cards
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: w,
                                  ),
                                )
                                .toList(),
                          );
                  },
                ),

                const SizedBox(height: 20),

                // DataTable
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Sector')),
                      DataColumn(label: Text('Causas técnicas')),
                      DataColumn(label: Text('Eficiencia (%)')),
                      DataColumn(label: Text('Potencia (W)')),
                    ],
                    rows: items
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(Text(e.sector)),
                              DataCell(
                                SizedBox(
                                  width: 300,
                                  child: Text(e.causasTecnicas),
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.eficiencia == null
                                      ? '—'
                                      : e.eficiencia!.toStringAsFixed(1),
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.potencia == null
                                      ? '—'
                                      : e.potencia!.toStringAsFixed(1),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/mode'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('Comenzar a calcular'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
