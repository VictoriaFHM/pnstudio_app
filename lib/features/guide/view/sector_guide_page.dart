import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<Map<String, String>> _sectors = [
  {
    "id": "dc",
    "title": "Data Center",
    "image": "assets/images/sector_dc.png",
    "efficiency": "85–95 %",
    "power": "60–70 %",
    "eff_causes": "Pérdidas en PSU/AC-DC y enfriamiento intensivo; mejora con virtualización y enfriamiento líquido.",
    "pow_causes": "Gran parte va a enfriamiento (≈30–40%) y conversiones; solo una fracción es trabajo útil de procesamiento."
  },
  {
    "id": "fabs",
    "title": "Fábricas de Semiconductores (Fabs)",
    "image": "assets/images/sector_fabs.png",
    "efficiency": "20–45 %",
    "power": "25–35 %",
    "eff_causes": "Litografía/deposición con vacío, plasma y hornos; condiciones ambientales estrictas elevan pérdidas.",
    "pow_causes": "Vacío y plasma consumen la mayor energía; pérdidas en calor y sistemas de bombeo/vacío."
  },
  {
    "id": "battery",
    "title": "Manufactura de Baterías",
    "image": "assets/images/sector_battery.png",
    "efficiency": "40–60 %",
    "power": "45–55 %",
    "eff_causes": "Procesos electroquímicos y térmicos (secado de electrodos, hornos, recubrimientos); HVAC y equipos de secado.",
    "pow_causes": "Parte útil en recubrimiento/ensamblaje; pérdidas térmicas en hornos, secado y aire acondicionado."
  },
  {
    "id": "telco",
    "title": "Telecomunicaciones (4G/5G)",
    "image": "assets/images/sector_telco.png",
    "efficiency": "70–85 %",
    "power": "50–60 %",
    "eff_causes": "Amplificación RF: solo una fracción se convierte en ondas EM; límites físicos de transistores y disipación térmica.",
    "pow_causes": "Transmisores RF con pérdidas altas (clases A/AB); solo una parte es potencia de radiofrecuencia efectiva."
  },
  {
    "id": "electronics",
    "title": "Fabricación de Equipos Electrónicos",
    "image": "assets/images/sector_electronics.png",
    "efficiency": "60–80 %",
    "power": "65–75 %",
    "eff_causes": "Cadena de producción (fundición, soldadura, montaje) con motores, hornos, neumáticos; mejora con variadores y recuperación de calor.",
    "pow_causes": "Mucha potencia a motores/soldadores/maquinaria; pérdidas por conversiones eléctricas y disipación térmica."
  },
];

class SectorGuidePage extends StatelessWidget {
  const SectorGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final headerStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final cellStyle = theme.textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cómo elegir eficiencia y potencia?'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width < 700 ? 2 : (width < 1100 ? 3 : 5);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 6),

              // Responsive grid of sector cards
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: _sectors.map((s) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.asset(
                              s['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Center(
                                child: Icon(Icons.broken_image, size: 40, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              s['title']!,
                              style: theme.textTheme.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Table header
              Text('Comparativa técnica', style: headerStyle),
              const SizedBox(height: 8),

              // Horizontal scroll if table overflows
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: width < 700 ? 800 : width),
                  child: Table(
                    border: TableBorder.symmetric(
                      outside: BorderSide(color: theme.dividerColor),
                      inside: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(4),
                      4: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Header row
                      TableRow(children: [
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text('Sector tecnológico', style: headerStyle))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text('Causas técnicas de la eficiencia', style: headerStyle))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text('Eficiencia (%)', style: headerStyle))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text('Causas técnicas de potencia', style: headerStyle))),
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text('Potencia útil (%)', style: headerStyle))),
                      ]),

                      // Data rows
                      ..._sectors.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final s = entry.value;
                        return TableRow(
                          decoration: BoxDecoration(color: idx.isEven ? Colors.black12 : null),
                          children: [
                            TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(s['title']!, style: cellStyle))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 400, child: Text(s['eff_causes']!, style: cellStyle)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(s['efficiency']!, style: cellStyle))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 400, child: Text(s['pow_causes']!, style: cellStyle)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(s['power']!, style: cellStyle))),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Spacer before action
              const SizedBox(height: 24),

              // Centered "Calcular" button (max width 300)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // Navigate to the calculator in porcentaje mode so the user can
                        // enter k%/c% and view the graphs. The router understands
                        // the query parameter `mode=percent`.
                        // Use GoRouter's context extension to push the route with query
                        // parameters. This will open the calculator screen in porcentaje mode.
                        context.push('/calc?mode=percent');
                      },
                      child: const Text(
                        'Calcular',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
