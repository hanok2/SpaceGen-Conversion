import 'package:flutter/material.dart';
import '../core/space_gen.dart';
import '../models/planet.dart';
import '../models/strata/remnant.dart';
import '../models/strata/ruin.dart';
import '../models/strata/lost_artefact.dart';
import '../models/strata/fossil.dart';

class PlanetDetail extends StatelessWidget {
  final Planet planet;
  final SpaceGen sg;

  const PlanetDetail({super.key, required this.planet, required this.sg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: Text(planet.name, style: const TextStyle(color: Color(0xFF4FC3F7), letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4FC3F7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(),
            const SizedBox(height: 16),
            if (planet.owner != null) ...[
              _buildSection('OWNER', [planet.owner!.name]),
              const SizedBox(height: 12),
            ],
            if (planet.inhabitants.isNotEmpty) ...[
              _buildSection('POPULATION', planet.inhabitants.map((p) => '${p.type.name}: ${p.size} billion').toList()),
              const SizedBox(height: 12),
            ],
            if (planet.specials.isNotEmpty) ...[
              _buildSection('SPECIAL FEATURES', planet.specials.map((s) => s.name).toList()),
              const SizedBox(height: 12),
            ],
            if (planet.lifeforms.isNotEmpty) ...[
              _buildSection('LIFEFORMS', planet.lifeforms.map((l) => l.name).toList()),
              const SizedBox(height: 12),
            ],
            if (planet.structures.isNotEmpty) ...[
              _buildSection('STRUCTURES', planet.structures.map((s) => s.type.name).toList()),
              const SizedBox(height: 12),
            ],
            if (planet.plagues.isNotEmpty) ...[
              _buildSection('PLAGUES', planet.plagues.map((p) => p.name).toList(), color: const Color(0xFFFF7043)),
              const SizedBox(height: 12),
            ],
            if (planet.artefacts.isNotEmpty) ...[
              _buildSection('ARTEFACTS', planet.artefacts.map((a) => a.description).toList(), color: const Color(0xFFCE93D8)),
              const SizedBox(height: 12),
            ],
            if (planet.strata.isNotEmpty) ...[
              _buildStrataSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF333366)),
      ),
      child: Row(
        children: [
          _statusChip(planet.habitable ? 'HABITABLE' : 'BARREN', planet.habitable ? const Color(0xFF81C784) : const Color(0xFF757575)),
          const SizedBox(width: 8),
          _statusChip('POP ${planet.totalPopulation}B', const Color(0xFF4FC3F7)),
          const SizedBox(width: 8),
          if (planet.pollution > 0)
            _statusChip('POLLUTION ${planet.pollution}', const Color(0xFFFF7043)),
          const SizedBox(width: 8),
          _statusChip('(${planet.x}, ${planet.y})', Colors.white38),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, letterSpacing: 1)),
    );
  }

  Widget _buildSection(String title, List<String> items, {Color color = Colors.white70}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 3, left: 8),
          child: Row(
            children: [
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(item, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStrataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GEOLOGICAL STRATA', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 6),
        ...planet.strata.map((s) {
          Color color;
          if (s is Remnant) {
            color = Colors.white38;
          } else if (s is Ruin) {
            color = Colors.white54;
          } else if (s is LostArtefact) {
            color = const Color(0xFFCE93D8);
          } else if (s is Fossil) {
            color = const Color(0xFFFFB74D);
          } else {
            color = Colors.white38;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 3, left: 8),
            child: Row(
              children: [
                Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(s.toString(), style: TextStyle(color: color, fontSize: 12))),
              ],
            ),
          );
        }),
      ],
    );
  }
}
