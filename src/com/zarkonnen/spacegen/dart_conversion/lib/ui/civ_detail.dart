import 'package:flutter/material.dart';
import '../core/space_gen.dart';
import '../models/civilization.dart';
import '../enums/diplomacy_outcome.dart';

class CivDetail extends StatelessWidget {
  final Civilization civ;
  final SpaceGen sg;

  const CivDetail({super.key, required this.civ, required this.sg});

  @override
  Widget build(BuildContext context) {
    final colonies = civ.colonies(sg.planets);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: Text(civ.name, style: const TextStyle(color: Color(0xFF4FC3F7), letterSpacing: 2)),
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
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildSection('GOVERNMENT', [civ.government.typeName]),
            const SizedBox(height: 12),
            if (civ.fullMembers.isNotEmpty) ...[
              _buildSection('MEMBER SPECIES', civ.fullMembers.map((s) => '${s.name} — ${s.personality}, ${s.goal}').toList()),
              const SizedBox(height: 12),
            ],
            if (colonies.isNotEmpty) ...[
              _buildSection('COLONIES', colonies.map((p) => '${p.name} (pop ${p.totalPopulation}B)').toList()),
              const SizedBox(height: 12),
            ],
            if (civ.relations.isNotEmpty) ...[
              _buildRelationsSection(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF333366)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip('TECH ${civ.techLevel}', const Color(0xFF4FC3F7)),
          _chip('RES ${civ.resources}', const Color(0xFF81C784)),
          _chip('MIL ${civ.military}', const Color(0xFFFF7043)),
          _chip('SCI ${civ.science}', const Color(0xFFCE93D8)),
          _chip('AGE ${civ.decrepitude}', Colors.white38),
          _chip('BORN ${civ.birthYear}', Colors.white38),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
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
              Expanded(child: Text(item, style: TextStyle(color: color, fontSize: 12))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRelationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIPLOMATIC RELATIONS', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 6),
        ...civ.relations.entries.map((e) {
          Color color;
          switch (e.value) {
            case DiplomacyOutcome.war:
              color = const Color(0xFFFF7043);
            case DiplomacyOutcome.union:
              color = const Color(0xFF81C784);
            default:
              color = Colors.white54;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 3, left: 8),
            child: Row(
              children: [
                Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text('${e.key.name}: ${e.value.name}', style: TextStyle(color: color, fontSize: 12))),
              ],
            ),
          );
        }),
      ],
    );
  }
}
