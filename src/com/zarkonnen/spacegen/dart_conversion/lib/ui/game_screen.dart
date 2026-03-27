import 'dart:async';
import 'package:flutter/material.dart';
import '../core/space_gen.dart';
import '../models/planet.dart';
import 'planet_detail.dart';
import 'civ_detail.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SpaceGen _sg;
  bool _running = false;
  Timer? _timer;
  final ScrollController _logScrollController = ScrollController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _sg = SpaceGen(DateTime.now().millisecondsSinceEpoch);
    _sg.init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  void _tick() {
    try {
      setState(() {
        _error = null;
        _sg.tick();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logScrollController.hasClients) {
          _logScrollController.jumpTo(_logScrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error during tick: $e';
        _running = false;
        _timer?.cancel();
        _timer = null;
      });
    }
  }

  void _toggleAutoRun() {
    setState(() {
      _running = !_running;
      if (_running) {
        _timer = Timer.periodic(const Duration(milliseconds: 300), (_) => _tick());
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void _newGame() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _timer = null;
      _sg = SpaceGen(DateTime.now().millisecondsSinceEpoch);
      _sg.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildTopBar(),
          if (_error != null)
            Container(
              color: const Color(0xFF3A0000),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFFF5252), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11))),
                  GestureDetector(
                    onTap: () => setState(() => _error = null),
                    child: const Icon(Icons.close, color: Color(0xFFFF5252), size: 16),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildMapView()),
                Container(width: 1, color: const Color(0xFF333366)),
                SizedBox(width: 280, child: _buildSidePanel()),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 48,
      color: const Color(0xFF0D0D1A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('SPACEGEN', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
          const SizedBox(width: 24),
          Text('Year ${_sg.year}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(width: 16),
          Text('Age ${_sg.age}', style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const Spacer(),
          Text('Planets: ${_sg.planets.length}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(width: 16),
          Text('Civs: ${_sg.civs.length}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(width: 16),
          Text('Agents: ${_sg.agents.length}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return GestureDetector(
      onTapUp: (details) => _handleMapTap(details.localPosition, context),
      child: Container(
        color: const Color(0xFF05050F),
        child: CustomPaint(
          painter: _StarfieldPainter(_sg),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _handleMapTap(Offset pos, BuildContext context) {
    if (_sg.planets.isEmpty) return;
    const mapPad = 40.0;
    final size = MediaQuery.of(context).size;
    final mapWidth = size.width * 0.75 - mapPad * 2;
    final mapHeight = size.height - 48 - 48 - mapPad * 2;

    Planet? closest;
    double closestDist = double.infinity;
    for (final p in _sg.planets) {
      final px = mapPad + (p.x / 20.0) * mapWidth;
      final py = mapPad + (p.y / 20.0) * mapHeight;
      final d = (pos - Offset(px, py)).distance;
      if (d < closestDist) {
        closestDist = d;
        closest = p;
      }
    }
    if (closest != null && closestDist < 30) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlanetDetail(planet: closest!, sg: _sg)));
    }
  }

  Widget _buildSidePanel() {
    return Container(
      color: const Color(0xFF0A0A1A),
      child: Column(
        children: [
          _buildCivList(),
          Container(height: 1, color: const Color(0xFF333366)),
          _buildLogPanel(),
        ],
      ),
    );
  }

  Widget _buildCivList() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CIVILISATIONS', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 6),
          Expanded(
            child: _sg.civs.isEmpty
                ? const Text('None', style: TextStyle(color: Colors.white38, fontSize: 12))
                : ListView.builder(
                    itemCount: _sg.civs.length,
                    itemBuilder: (_, i) {
                      final c = _sg.civs[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CivDetail(civ: c, sg: _sg))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111128),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: _civColor(i), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
                              Text('T${c.techLevel}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _civColor(int index) {
    const colors = [Color(0xFF4FC3F7), Color(0xFF81C784), Color(0xFFFFB74D), Color(0xFFCE93D8), Color(0xFFFF8A65), Color(0xFF4DB6AC)];
    return colors[index % colors.length];
  }

  Widget _buildLogPanel() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HISTORY', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                controller: _logScrollController,
                itemCount: _sg.fullLog.length,
                itemBuilder: (_, i) {
                  final msg = _sg.fullLog[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(msg, style: TextStyle(color: msg.startsWith('Year') ? const Color(0xFF4FC3F7) : Colors.white60, fontSize: 10)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 48,
      color: const Color(0xFF0D0D1A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _BarButton(label: _running ? 'PAUSE' : 'AUTO', onPressed: _toggleAutoRun, active: _running),
          const SizedBox(width: 8),
          _BarButton(label: 'STEP', onPressed: _running ? null : _tick),
          const SizedBox(width: 8),
          _BarButton(label: 'NEW GAME', onPressed: _newGame),
          const Spacer(),
          if (_sg.turnLog.isNotEmpty)
            Expanded(
              child: Text(
                _sg.turnLog.last,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool active;

  const _BarButton({required this.label, this.onPressed, this.active = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: active ? const Color(0xFF1A3A5C) : const Color(0xFF111128),
        foregroundColor: onPressed == null ? Colors.white24 : const Color(0xFF4FC3F7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3), side: BorderSide(color: active ? const Color(0xFF4FC3F7) : const Color(0xFF333366))),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1)),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final SpaceGen sg;

  _StarfieldPainter(this.sg);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 40.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final bgPaint = Paint()..color = const Color(0xFF05050F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final starPaint = Paint()..color = Colors.white24;
    for (int i = 0; i < 200; i++) {
      final sx = (i * 137.5) % size.width;
      final sy = (i * 97.3 + i * i * 0.7) % size.height;
      canvas.drawCircle(Offset(sx, sy), 0.5 + (i % 3) * 0.3, starPaint..color = Colors.white.withValues(alpha: 0.1 + (i % 5) * 0.04));
    }

    for (final p in sg.planets) {
      final px = pad + (p.x / 20.0) * w;
      final py = pad + (p.y / 20.0) * h;

      Color color;
      if (p.owner != null) {
        color = const Color(0xFF4FC3F7);
      } else if (p.habitable) {
        color = const Color(0xFF81C784);
      } else if (p.inhabitants.isNotEmpty) {
        color = const Color(0xFFFFB74D);
      } else {
        color = const Color(0xFF616161);
      }

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(px, py), 10, glowPaint);

      final planetPaint = Paint()..color = color;
      canvas.drawCircle(Offset(px, py), 6, planetPaint);

      if (p.pollution > 3) {
        final pollPaint = Paint()..color = const Color(0xFFFF7043).withValues(alpha: 0.6);
        canvas.drawCircle(Offset(px, py), 8, pollPaint..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }

      final textPainter = TextPainter(
        text: TextSpan(text: p.name, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(px - textPainter.width / 2, py + 9));
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => true;
}
