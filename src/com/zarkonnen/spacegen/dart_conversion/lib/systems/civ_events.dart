import '../models/civilization.dart';
import '../models/planet.dart';
import '../models/population.dart';
import '../models/plague.dart';
import '../models/sentient_type.dart';
import '../enums/government.dart';
import '../enums/diplomacy_outcome.dart';
import '../utils/random_utils.dart';
import 'civ_actions.dart';

class CivEvents {
  final RandomUtils random;
  final CivActions actions;

  CivEvents(this.random) : actions = CivActions(random);

  void processGoodEvent(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final events = [
      _goldenAgeOfScience,
      _goldenAgeOfIndustry,
      _goldenAgeOfArt,
      _populationBoom,
      _democratisation,
      _spawnAdventurer,
    ];
    random.pick(events)(actor, allPlanets, allCivs, historicalCivNames, year, log);
  }

  void processBadEvent(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final events = [
      _revolt,
      _putsch,
      _religiousRevival,
      _marketCrash,
      _darkAge,
      _massHysteria,
      _accident,
      _civilWar,
      _plague,
      _starvation,
      _spawnPirate,
    ];
    random.pick(events)(actor, allPlanets, allCivs, historicalCivNames, year, log);
  }

  void _goldenAgeOfScience(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    log('The ${actor.name} enters a golden age of science! ');
    actor.resources += 5;
    actions.buildScienceOutpost(actor, allPlanets, year, log);
    actor.science += 10;
  }

  void _goldenAgeOfIndustry(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    log('The ${actor.name} enters a golden age of industry! ');
    actor.resources += 10;
    actions.buildMiningBase(actor, allPlanets, year, log);
    log(' ');
    actions.buildMiningBase(actor, allPlanets, year, log);
  }

  void _goldenAgeOfArt(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final fullCols = actor.fullColonies(allPlanets);
    if (fullCols.isEmpty) return;
    final col = random.pick(fullCols);
    log('Artists on ${col.name} create a great work of art. ');
  }

  void _populationBoom(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    log('The ${actor.name} experiences a population boom! ');
    for (final col in actor.colonies(allPlanets)) {
      for (final p in col.inhabitants) {
        p.size += 2;
      }
    }
  }

  void _democratisation(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    if (actor.government == Government.republic) return;
    final oldName = actor.name;
    for (final col in actor.colonies(allPlanets)) {
      for (final p in col.inhabitants) {
        if (!actor.fullMembers.contains(p.type)) {
          actor.fullMembers.add(p.type);
        }
      }
    }
    actor.government = Government.republic;
    actor.updateName(historicalCivNames);
    log('A popular movement overthrows the old guard of the $oldName and declares the ${actor.name}.');
  }

  void _spawnAdventurer(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final cols = actor.colonies(allPlanets);
    if (cols.isEmpty) return;
    final p = random.pick(cols);
    log('A space adventurer blasts off from ${p.name}.');
  }

  void _revolt(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final fullCols = actor.fullColonies(allPlanets);
    if (fullCols.length < 2) return;
    for (final col in fullCols) {
      final rebels = col.inhabitants.where((p) => !actor.fullMembers.contains(p.type)).toList();
      final nRebels = rebels.fold(0, (sum, p) => sum + p.size);
      if (nRebels > col.totalPopulation / 2) {
        final resTaken = actor.resources ~/ actor.colonies(allPlanets).length;
        final milTaken = actor.military ~/ actor.colonies(allPlanets).length;
        final newCiv = Civilization(
          government: Government.republic,
          name: '',
          birthYear: year,
        );
        newCiv.fullMembers.add(rebels[0].type);
        newCiv.resources = resTaken;
        newCiv.techLevel = actor.techLevel;
        newCiv.weaponLevel = actor.weaponLevel;
        newCiv.updateName(historicalCivNames);
        actor.resources -= resTaken;
        actor.military -= milTaken;
        if (actor.military < 0) actor.military = 0;
        newCiv.military = milTaken;
        newCiv.setRelation(actor, DiplomacyOutcome.war);
        col.owner = newCiv;
        actor.setRelation(newCiv, DiplomacyOutcome.war);
        for (final pop in List<Population>.from(col.inhabitants)) {
          if (!rebels.contains(pop)) {
            col.depopulate(pop, year, null, 'during a slave revolt', null);
          }
        }
        allCivs.add(newCiv);
        log('Slaves on ${col.name} revolt, killing their oppressors and declaring the Free ${newCiv.name}.');
        return;
      }
    }
  }

  void _putsch(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    if (actor.government == Government.dictatorship) return;
    if (actor.fullMembers.isEmpty) return;
    final rulers = random.pick(actor.fullMembers);
    final oldName = actor.name;
    actor.fullMembers.clear();
    actor.fullMembers.add(rulers);
    actor.government = Government.dictatorship;
    actor.updateName(historicalCivNames);
    log('A military putsch turns the $oldName into the ${actor.name}.');
  }

  void _religiousRevival(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final oldName = actor.name;
    actor.government = Government.theocracy;
    actor.updateName(historicalCivNames);
    log('Religious fanatics sieze power in the $oldName and declare the ${actor.name}.');
  }

  void _marketCrash(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    actor.resources = actor.resources ~/ 5;
    log('A market crash impoverishes the ${actor.name}.');
  }

  void _darkAge(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    log('The ${actor.name} enters a dark age.');
    actor.techLevel -= 1;
    if (actor.techLevel < 0) actor.techLevel = 0;
    if (actor.techLevel == 0) {
      if (actor.fullMembers.length > 1) {
        log(' With the knowledge of faster-than-light travel lost, each planet in the empire has to fend for itself.');
      }
      for (final col in List<Planet>.from(actor.colonies(allPlanets))) {
        col.darkAge(year);
      }
    }
  }

  void _massHysteria(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    log('Mass hysteria breaks out in the ${actor.name}, killing billions.');
    for (final col in actor.fullColonies(allPlanets)) {
      final pop = col.totalPopulation;
      if (col.inhabitants.isNotEmpty) {
        col.inhabitants[0].size = 1;
      }
      if (pop > 1 && pop > 3) {
        while (col.inhabitants.length > 1) {
          col.depopulate(col.inhabitants[1], year, null, 'from mass hysteria', null);
        }
      }
    }
  }

  void _accident(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final fullCols = actor.fullColonies(allPlanets);
    if (fullCols.isEmpty) return;
    final p = random.pick(fullCols);
    log('An industrial accident on ${p.name} causes deadly levels of pollution.');
    p.pollution += 5;
  }

  void _civilWar(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final bigPlanets = actor.colonies(allPlanets).where((c) => c.totalPopulation > 2).toList();
    if (bigPlanets.length <= 1) return;

    random.shuffle(bigPlanets);
    final newCiv = Civilization(
      government: random.pick(Government.values),
      name: '',
      birthYear: year,
    );
    newCiv.military = actor.military ~/ 2;
    newCiv.techLevel = actor.techLevel;
    newCiv.weaponLevel = actor.weaponLevel;
    actor.military -= newCiv.military;
    final resGiven = actor.resources ~/ 2;
    newCiv.resources = resGiven;
    actor.resources -= resGiven;

    bigPlanets[0].owner = newCiv;
    for (final pop in bigPlanets[0].inhabitants) {
      if (!newCiv.fullMembers.contains(pop.type)) newCiv.fullMembers.add(pop.type);
    }

    for (int i = 1; i < bigPlanets.length ~/ 2; i++) {
      bigPlanets[i].owner = newCiv;
      for (final pop in bigPlanets[i].inhabitants) {
        if (!newCiv.fullMembers.contains(pop.type)) newCiv.fullMembers.add(pop.type);
      }
    }

    for (final col in List<Planet>.from(actor.colonies(allPlanets))) {
      if (bigPlanets.contains(col)) continue;
      if (random.coin()) col.owner = newCiv;
    }

    newCiv.updateName(historicalCivNames);
    newCiv.setRelation(actor, DiplomacyOutcome.war);
    actor.setRelation(newCiv, DiplomacyOutcome.war);
    allCivs.add(newCiv);
    log('The ${newCiv.name} secedes from the ${actor.name}, leading to a civil war!');
  }

  void _plague(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final fullCols = actor.fullColonies(allPlanets);
    if (fullCols.isEmpty) return;
    final p = random.pick(fullCols);
    final biologicals = p.inhabitants.where((pop) => pop.type.base != SentientBase.robots).toList();
    if (biologicals.isEmpty) return;
    final plague = Plague.generate(random);
    plague.affects.add(random.pick(biologicals).type);
    p.addPlague(plague);
    log('The deadly ${plague.description}, arises on ${p.name}.');
  }

  void _starvation(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final fullCols = actor.fullColonies(allPlanets);
    if (fullCols.isEmpty) return;
    final p = random.pick(fullCols);
    int deaths = 0;
    for (final pop in List<Population>.from(p.inhabitants)) {
      if (pop.type.base == SentientBase.robots) continue;
      final d = pop.size - pop.size ~/ 2;
      if (d >= pop.size) {
        deaths += pop.size;
        p.depopulate(pop, year, null, 'due to starvation', null);
      } else {
        pop.size -= d;
        deaths += d;
      }
    }
    if (deaths == 0) return;
    log('A famine breaks out on ${p.name}, killing $deaths billion');
    if (p.totalPopulation == 0) {
      log(', wiping out all sentient life.');
      p.decivilize(year, null, 'due to starvation');
    } else {
      log('.');
    }
  }

  void _spawnPirate(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    if (actor.fullMembers.isEmpty) return;
    final cols = actor.colonies(allPlanets);
    if (cols.isEmpty) return;
    final p = random.pick(cols);
    log('A pirate establishes ${random.coin() ? 'himself' : 'herself'} on ${p.name}.');
  }
}
