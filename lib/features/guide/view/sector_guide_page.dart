import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<Map<String, String>> _sectors = [
  {
    "id": "dc",
    "title": "Data Center",
    "image": "assets/images/sector_dc.jpg",
    "efficiency": "85–95 %",
    "power": "60–70 %",
    "eff_causes":
        "Pérdidas en PSU/AC-DC y enfriamiento intensivo; mejora con virtualización y enfriamiento líquido.",
    "pow_causes":
        "Gran parte va a enfriamiento (≈30–40 %) y conversiones; solo una fracción es trabajo útil de procesamiento.",
  },
  {
    "id": "fabs",
    "title": "Fábricas de Semiconductores (Fabs)",
    "image": "assets/images/sector_fabs.jpg",
    "efficiency": "20–45 %",
    "power": "25–35 %",
    "eff_causes":
        "Litografía/deposición con vacío, plasma y hornos; condiciones ambientales estrictas elevan pérdidas.",
    "pow_causes":
        "Vacío y plasma consumen la mayor energía; pérdidas en calor y sistemas de bombeo/vacío.",
  },
  {
    "id": "battery",
    "title": "Manufactura de Baterías",
    "image": "assets/images/sector_battery.jpg",
    "efficiency": "40–60 %",
    "power": "45–55 %",
    "eff_causes":
        "Procesos electroquímicos y térmicos (secado de electrodos, hornos, recubrimientos); HVAC y equipos de secado.",
    "pow_causes":
        "Parte útil en recubrimiento/ensamblaje; pérdidas térmicas en hornos, secado y aire acondicionado.",
  },
  {
    "id": "telco",
    "title": "Telecomunicaciones (4G/5G)",
    "image": "assets/images/sector_telco.jpg",
    "efficiency": "70–85 %",
    "power": "50–60 %",
    "eff_causes":
        "Amplificación RF: solo una fracción se convierte en ondas EM; límites físicos de transistores y disipación térmica.",
    "pow_causes":
        "Transmisores RF con pérdidas altas (clases A/AB); solo una parte es potencia de radiofrecuencia efectiva.",
  },
  {
    "id": "electronics",
    "title": "Fabricación de Equipos Electrónicos",
    "image": "assets/images/sector_electronics.jpg",
    "efficiency": "60–80 %",
    "power": "65–75 %",
    "eff_causes":
        "Cadena de producción (fundición, soldadura, montaje) con motores, hornos, neumáticos; mejora con variadores y recuperación de calor.",
    "pow_causes":
        "Mucha potencia a motores/soldadores/maquinaria; pérdidas por conversiones eléctricas y disipación térmica.",
  },
];

const Map<String, String> subtitles = {
  'dc': 'TI intensivo, alta potencia continua',
  'fabs': 'Procesos en vacío, plasma y hornos',
  'battery': 'Procesos electroquímicos y térmicos',
  'telco': 'RF de alta potencia, conversión en calor',
  'electronics': 'Líneas de montaje y motores',
};

class SectorGuidePage extends StatefulWidget {
  const SectorGuidePage({super.key});

  @override
  State<SectorGuidePage> createState() => _SectorGuidePageState();
}

class _SectorGuidePageState extends State<SectorGuidePage> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE4), // Beige #F3EDE4
      appBar: AppBar(
        title: const Text(
          '¿Cómo elegir eficiencia y potencia?',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDE4),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isMobile ? 20 : 30),

              // Grid de cards de sectores
              _buildSectorCards(isMobile),
              SizedBox(height: isMobile ? 30 : 40),

              // Sección "Comparativa técnica" con divisor
              _buildComparativaHeader(),
              const SizedBox(height: 20),

              // Banner informativo
              _buildInfoBanner(),
              const SizedBox(height: 20),

              // Tabla responsiva (auto height to avoid excessive whitespace)
              _buildResponsiveTable(isMobile),
              // Reduce vertical gap before the CTA button
              SizedBox(height: isMobile ? 10 : 14),

              // Botón primario verde
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E8C1A), // Olive green #6E8C1A
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  // Navigate to calculator (screen 3) in percentage mode
                  // app_router recognizes query param `mode=percent`
                  context.push('/calc?mode=percent');
                },
                child: const Text(
                  'Continuar al cálculo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorCards(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: _sectors.map((sector) {
        final id = sector['id']!;
        final isSelected = _selectedId == id;

        return _buildSectorCard(
          imagePath: sector['image']!,
          title: sector['title']!,
          subtitle: subtitles[id] ?? '',
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedId = _selectedId == id ? null : id;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectorCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE8DFD3),
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(isSelected ? 0.5 : 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Texto
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparativaHeader() {
    return Column(
      children: [
        // Divisor decorativo con puntos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFCFE0A8), // Olive 200
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 2,
              color: const Color(0xFF6E8C1A), // Olive principal
            ),
            const SizedBox(width: 12),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFCFE0A8), // Olive 200
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Título centrado
        const Text(
          'Comparativa técnica',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E8), // Beige claro
        border: Border.all(
          color: const Color(0xFFCFE0A8), // Olive 200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Center(
          child: Text(
            'Estos rangos son orientativos según el sector. Podés usarlos como referencia rápida para elegir k (eficiencia) y c (potencia útil) en el cálculo siguiente.',
            style: const TextStyle(
              color: Color(0xFF2F2F2F),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveTable(bool isMobile) {
    if (isMobile) {
      return _buildStackedTable();
    }
    return _buildDataTable();
  }

  Widget _buildDataTable() {
    // Compact table implemented with Table so we can control column widths
    // and ensure the table fits within the available width (no horizontal scroll).
    return LayoutBuilder(builder: (context, constraints) {
  // final maxWidth = constraints.maxWidth; // unused

      // Column flex: [sector, causesEff, effPercent, causesPow, powPercent]
      // Give numeric columns small flex so text columns get most space but
      // overall still fits in the container.
      // Tighter column distribution for compact desktop view.
      final columnWidths = <int, TableColumnWidth>{
        // Sector column slightly smaller
        0: const FlexColumnWidth(1.5),
        // Text-heavy columns reduced to 4
        1: const FlexColumnWidth(4),
        2: const FlexColumnWidth(0.8),
        3: const FlexColumnWidth(4),
        4: const FlexColumnWidth(0.8),
      };

      // Slightly smaller typography for denser layout
      const headerStyle = TextStyle(
        color: Color(0xFF2F2F2F),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      );
      const cellStyle = TextStyle(
        color: Color(0xFF2F2F2F),
        fontSize: 11,
        height: 1.1,
      );

      // Build rows
      final rows = <TableRow>[];

      // Header row
      rows.add(TableRow(
        decoration: const BoxDecoration(color: Color(0xFFE8DFD3)),
        children: [
          _tableCell(const Text('Sector', style: headerStyle)),
          _tableCell(const Text('Eficiencia: Causas', style: headerStyle)),
          _tableCell(const Text('Eficiencia %', style: headerStyle)),
          _tableCell(const Text('Potencia: Causas', style: headerStyle)),
          _tableCell(const Text('Potencia %', style: headerStyle)),
        ],
      ));

      for (var i = 0; i < _sectors.length; i++) {
        final sector = _sectors[i];
        final isEven = i.isEven;

        rows.add(TableRow(
          decoration: BoxDecoration(
            color: isEven ? const Color(0xFFF3EDE4) : Colors.white,
          ),
          children: [
            // Allow sector names to wrap into two lines so they are fully readable
            _tableCell(Text(
              sector['title']!,
              style: cellStyle,
              maxLines: 2,
              softWrap: true,
            )),
            _tableCell(Text(sector['eff_causes']!, style: cellStyle, maxLines: 2)),
            _tableCell(Text(sector['efficiency']!, style: cellStyle, maxLines: 1)),
            _tableCell(Text(sector['pow_causes']!, style: cellStyle, maxLines: 2)),
            _tableCell(Text(sector['power']!, style: cellStyle, maxLines: 1)),
          ],
        ));
      }

      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Table(
          columnWidths: columnWidths,
          border: TableBorder(horizontalInside: const BorderSide(color: Color(0xFFE8DFD3), width: 1)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
      );
    });
  }

  // Helper to build a compact Table cell with small paddings
  Widget _tableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: child,
    );
  }

  Widget _buildStackedTable() {
    return Column(
      children: _sectors.map((sector) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sector['title']!,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildStackedRow('Eficiencia: Causas', sector['eff_causes']!),
              _buildStackedRow('Eficiencia %', sector['efficiency']!),
              _buildStackedRow('Potencia: Causas', sector['pow_causes']!),
              _buildStackedRow('Potencia %', sector['power']!),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStackedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2F2F2F),
                fontSize: 12,
              ),
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
