import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacegen/main.dart';
import 'package:spacegen/ui/game_screen.dart';
import 'package:spacegen/ui/planet_detail.dart';
import 'package:spacegen/ui/civ_detail.dart';
import 'package:spacegen/core/space_gen.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/enums/government.dart';

void main() {
  group('SpaceGenApp', () {
    testWidgets('app renders without crash', (tester) async {
      await tester.pumpWidget(const SpaceGenApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app uses dark theme', (tester) async {
      await tester.pumpWidget(const SpaceGenApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.dark);
    });
  });

  group('GameScreen', () {
    testWidgets('game screen renders', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('displays SPACEGEN title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('SPACEGEN'), findsOneWidget);
    });

    testWidgets('displays year counter', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.textContaining('Year'), findsOneWidget);
    });

    testWidgets('displays planet count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.textContaining('Planets:'), findsOneWidget);
    });

    testWidgets('displays civ count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.textContaining('Civs:'), findsOneWidget);
    });

    testWidgets('displays CIVILISATIONS section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('CIVILISATIONS'), findsOneWidget);
    });

    testWidgets('displays HISTORY section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('HISTORY'), findsOneWidget);
    });

    testWidgets('STEP button exists', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('STEP'), findsOneWidget);
    });

    testWidgets('AUTO button exists', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('AUTO'), findsOneWidget);
    });

    testWidgets('NEW GAME button exists', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('NEW GAME'), findsOneWidget);
    });

    testWidgets('STEP button increments year', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      expect(find.text('Year 0'), findsOneWidget);
      await tester.tap(find.text('STEP'));
      await tester.pump();
      expect(find.text('Year 1'), findsOneWidget);
    });

    testWidgets('NEW GAME button resets year', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.tap(find.text('STEP'));
      await tester.pump();
      expect(find.text('Year 1'), findsOneWidget);
      await tester.tap(find.text('NEW GAME'));
      await tester.pump();
      expect(find.text('Year 0'), findsOneWidget);
    });

    testWidgets('AUTO toggles to PAUSE', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.tap(find.text('AUTO'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);
    });

    testWidgets('controls work - pause stops auto run', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.tap(find.text('AUTO'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('AUTO'), findsOneWidget);
    });
  });

  group('PlanetDetail', () {
    late SpaceGen sg;
    late Planet planet;

    setUp(() {
      sg = SpaceGen(42);
      sg.init();
      planet = sg.planets.first;
    });

    testWidgets('planet detail renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.byType(PlanetDetail), findsOneWidget);
    });

    testWidgets('displays planet name in app bar', (tester) async {
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.text(planet.name), findsWidgets);
    });

    testWidgets('displays habitable status', (tester) async {
      planet.habitable = true;
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.text('HABITABLE'), findsOneWidget);
    });

    testWidgets('displays barren status', (tester) async {
      planet.habitable = false;
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.text('BARREN'), findsOneWidget);
    });

    testWidgets('displays population section when inhabited', (tester) async {
      final st = SentientType(birth: 0, base: SentientBase.humanoids, personality: 'bold', goal: 'survive', name: 'Humans');
      planet.habitable = true;
      planet.inhabitants.add(Population(type: st, size: 3, planet: planet));
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.text('POPULATION'), findsOneWidget);
    });

    testWidgets('displays owner section when owned', (tester) async {
      final civ = Civilization(government: Government.republic, name: 'Republic', birthYear: 0, fullMembers: []);
      planet.owner = civ;
      await tester.pumpWidget(MaterialApp(home: PlanetDetail(planet: planet, sg: sg)));
      expect(find.text('OWNER'), findsOneWidget);
    });

    testWidgets('back button navigates away', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (ctx) => TextButton(
        onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlanetDetail(planet: planet, sg: sg))),
        child: const Text('go'),
      )))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanetDetail), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(PlanetDetail), findsNothing);
    });
  });

  group('CivDetail', () {
    late SpaceGen sg;
    late Civilization civ;

    setUp(() {
      sg = SpaceGen(42);
      sg.init();
      civ = Civilization(
        government: Government.republic,
        name: 'Test Republic',
        birthYear: 0,
        fullMembers: [],
      );
      sg.civs.add(civ);
    });

    testWidgets('civ detail renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.byType(CivDetail), findsOneWidget);
    });

    testWidgets('displays civ name in app bar', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.text('Test Republic'), findsWidgets);
    });

    testWidgets('displays GOVERNMENT section', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.text('GOVERNMENT'), findsOneWidget);
    });

    testWidgets('displays tech level chip', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.textContaining('TECH'), findsOneWidget);
    });

    testWidgets('displays resources chip', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.textContaining('RES'), findsOneWidget);
    });

    testWidgets('displays military chip', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.textContaining('MIL'), findsOneWidget);
    });

    testWidgets('displays colonies when present', (tester) async {
      final p = sg.planets.first;
      p.owner = civ;
      await tester.pumpWidget(MaterialApp(home: CivDetail(civ: civ, sg: sg)));
      expect(find.text('COLONIES'), findsOneWidget);
    });

    testWidgets('back button navigates away', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (ctx) => TextButton(
        onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => CivDetail(civ: civ, sg: sg))),
        child: const Text('go'),
      )))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(CivDetail), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(CivDetail), findsNothing);
    });
  });

  group('complete game flow', () {
    testWidgets('game can run multiple ticks via STEP', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('STEP'));
        await tester.pump();
      }
      expect(find.text('Year 5'), findsOneWidget);
    });
  });
}
