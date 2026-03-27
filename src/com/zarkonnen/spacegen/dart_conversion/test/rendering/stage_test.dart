import 'package:test/test.dart';
import 'package:spacegen/rendering/sprite.dart';
import 'package:spacegen/rendering/stage.dart';

void main() {
  group('Sprite', () {
    test('globalX with no parent returns x', () {
      final s = Sprite(x: 10, y: 20);
      expect(s.globalX(), 10);
    });

    test('globalY with no parent returns y', () {
      final s = Sprite(x: 10, y: 20);
      expect(s.globalY(), 20);
    });

    test('globalX with parent adds parent x', () {
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 10, y: 5);
      child.parent = parent;
      expect(child.globalX(), 110);
    });

    test('globalY with parent adds parent y', () {
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 10, y: 5);
      child.parent = parent;
      expect(child.globalY(), 55);
    });

    test('globalX with nested parents accumulates', () {
      final grandparent = Sprite(x: 100, y: 0);
      final parent = Sprite(x: 50, y: 0);
      final child = Sprite(x: 10, y: 0);
      parent.parent = grandparent;
      child.parent = parent;
      expect(child.globalX(), 160);
    });

    test('sprite starts with no highlight or flash', () {
      final s = Sprite();
      expect(s.highlight, false);
      expect(s.flash, false);
    });
  });

  group('Stage', () {
    test('starts empty', () {
      final stage = Stage();
      expect(stage.sprites, isEmpty);
      expect(stage.animations, isEmpty);
    });

    test('tick returns true when no animations', () {
      final stage = Stage();
      expect(stage.tick(), true);
    });

    test('animate adds animation', () {
      final stage = Stage();
      stage.animate(Stage.defaultDelay());
      expect(stage.animations.length, 1);
    });

    test('animateAll adds multiple animations', () {
      final stage = Stage();
      stage.animateAll([Stage.defaultDelay(), Stage.bigDelay()]);
      expect(stage.animations.length, 2);
    });
  });

  group('Delay animation', () {
    test('delay of 0 completes immediately', () {
      final stage = Stage();
      final d = Stage.delay(0);
      expect(d.tick(stage), true);
    });

    test('delay of 3 takes 3 ticks', () {
      final stage = Stage();
      final d = Stage.delay(3);
      expect(d.tick(stage), false);
      expect(d.tick(stage), false);
      expect(d.tick(stage), false);
      expect(d.tick(stage), true);
    });

    test('delay with nested animation runs after wait', () {
      final stage = Stage();
      bool called = false;
      final inner = _TestAnimation(() { called = true; return true; });
      final d = Stage.delay(2, inner);
      d.tick(stage);
      d.tick(stage);
      expect(called, false);
      d.tick(stage);
      expect(called, true);
    });

    test('defaultDelay waits 10 ticks', () {
      final stage = Stage();
      final d = Stage.defaultDelay();
      for (int i = 0; i < 10; i++) {
        expect(d.tick(stage), false);
      }
      expect(d.tick(stage), true);
    });

    test('bigDelay waits 40 ticks', () {
      final stage = Stage();
      final d = Stage.bigDelay();
      for (int i = 0; i < 40; i++) {
        expect(d.tick(stage), false);
      }
      expect(d.tick(stage), true);
    });
  });

  group('Seq animation', () {
    test('empty seq completes immediately', () {
      final stage = Stage();
      final s = Stage.seq([]);
      expect(s.tick(stage), true);
    });

    test('seq runs animations in order', () {
      final stage = Stage();
      final order = <int>[];
      final a1 = _TestAnimation(() { order.add(1); return true; });
      final a2 = _TestAnimation(() { order.add(2); return true; });
      final s = Stage.seq([a1, a2]);
      s.tick(stage);
      s.tick(stage);
      expect(order, [1, 2]);
    });

    test('seq waits for each animation to complete', () {
      final stage = Stage();
      final a1 = Stage.delay(2);
      int count = 0;
      final a2 = _TestAnimation(() { count++; return true; });
      final s = Stage.seq([a1, a2]);
      s.tick(stage);
      s.tick(stage);
      s.tick(stage);
      expect(count, 0);
      s.tick(stage);
      expect(count, 1);
    });
  });

  group('Sim animation', () {
    test('empty sim completes immediately', () {
      final stage = Stage();
      final s = Stage.sim([]);
      expect(s.tick(stage), true);
    });

    test('sim runs all animations simultaneously', () {
      final stage = Stage();
      int a1Count = 0;
      int a2Count = 0;
      final a1 = _TestAnimation(() { a1Count++; return true; });
      final a2 = _TestAnimation(() { a2Count++; return true; });
      final s = Stage.sim([a1, a2]);
      s.tick(stage);
      expect(a1Count, 1);
      expect(a2Count, 1);
    });

    test('sim completes when all animations complete', () {
      final stage = Stage();
      final a1 = Stage.delay(1);
      final a2 = Stage.delay(3);
      final s = Stage.sim([a1, a2]);
      expect(s.tick(stage), false);
      expect(s.tick(stage), false);
      expect(s.tick(stage), false);
      expect(s.tick(stage), true);
    });
  });

  group('Move animation', () {
    test('move with explicit time moves sprite', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      final m = Stage.move(sprite, 100, 0, 10);
      for (int i = 0; i < 20; i++) {
        m.tick(stage);
      }
      expect(sprite.x, 100);
      expect(sprite.y, 0);
    });

    test('move sets highlight during animation', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      final m = Stage.move(sprite, 10, 0, 5);
      m.tick(stage);
      expect(sprite.highlight, true);
    });

    test('move clears highlight when done', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      final m = Stage.move(sprite, 0, 0, 1);
      bool done = false;
      while (!done) {
        done = m.tick(stage);
      }
      expect(sprite.highlight, false);
    });
  });

  group('Remove animation', () {
    test('remove removes sprite from stage after flash', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      stage.sprites.add(sprite);
      final r = Stage.remove(sprite);
      for (int i = 0; i < 10; i++) {
        r.tick(stage);
      }
      expect(stage.sprites, isEmpty);
    });

    test('remove sets flash during animation', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      stage.sprites.add(sprite);
      final r = Stage.remove(sprite);
      r.tick(stage);
      expect(sprite.flash, true);
    });

    test('remove from parent children', () {
      final stage = Stage();
      final parent = Sprite(x: 0, y: 0);
      final child = Sprite(x: 5, y: 5);
      child.parent = parent;
      parent.children.add(child);
      stage.sprites.add(parent);
      final r = Stage.remove(child);
      for (int i = 0; i < 10; i++) {
        r.tick(stage);
      }
      expect(parent.children, isEmpty);
    });
  });

  group('Add animation', () {
    test('add adds sprite to stage', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      final a = Stage.add(sprite);
      a.tick(stage);
      expect(stage.sprites, contains(sprite));
    });

    test('add with parent adds to parent children', () {
      final stage = Stage();
      final parent = Sprite(x: 0, y: 0);
      final child = Sprite(x: 5, y: 5);
      stage.sprites.add(parent);
      final a = Stage.add(child, parent);
      a.tick(stage);
      expect(parent.children, contains(child));
      expect(child.parent, parent);
    });

    test('add sets flash then clears', () {
      final stage = Stage();
      final sprite = Sprite(x: 0, y: 0);
      final a = Stage.add(sprite);
      a.tick(stage);
      expect(sprite.flash, true);
      bool done = false;
      while (!done) {
        done = a.tick(stage);
      }
      expect(sprite.flash, false);
    });
  });

  group('Change animation', () {
    test('change updates image path after delay', () {
      final stage = Stage();
      final sprite = Sprite(imagePath: 'old.png');
      final c = Stage.change(sprite, 'new.png');
      for (int i = 0; i < 10; i++) {
        c.tick(stage);
      }
      expect(sprite.imagePath, 'new.png');
    });

    test('change sets flash initially', () {
      final stage = Stage();
      final sprite = Sprite(imagePath: 'old.png');
      final c = Stage.change(sprite, 'new.png');
      c.tick(stage);
      expect(sprite.flash, true);
    });

    test('change clears flash when done', () {
      final stage = Stage();
      final sprite = Sprite(imagePath: 'old.png');
      final c = Stage.change(sprite, 'new.png');
      bool done = false;
      while (!done) {
        done = c.tick(stage);
      }
      expect(sprite.flash, false);
    });
  });

  group('Emancipate animation', () {
    test('emancipate moves child to root sprites', () {
      final stage = Stage();
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 10, y: 5);
      child.parent = parent;
      parent.children.add(child);
      stage.sprites.add(parent);
      final e = Stage.emancipate(child);
      e.tick(stage);
      expect(child.parent, isNull);
      expect(parent.children, isEmpty);
      expect(stage.sprites, contains(child));
    });

    test('emancipate converts to global coordinates', () {
      final stage = Stage();
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 10, y: 5);
      child.parent = parent;
      parent.children.add(child);
      stage.sprites.add(parent);
      final e = Stage.emancipate(child);
      e.tick(stage);
      expect(child.x, 110);
      expect(child.y, 55);
    });

    test('emancipate on root sprite does nothing', () {
      final stage = Stage();
      final sprite = Sprite(x: 10, y: 5);
      stage.sprites.add(sprite);
      final e = Stage.emancipate(sprite);
      e.tick(stage);
      expect(sprite.parent, isNull);
      expect(stage.sprites.length, 1);
    });
  });

  group('Subordinate animation', () {
    test('subordinate moves sprite to be child of parent', () {
      final stage = Stage();
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 110, y: 55);
      stage.sprites.add(parent);
      stage.sprites.add(child);
      final s = Stage.subordinate(child, parent);
      s.tick(stage);
      expect(child.parent, parent);
      expect(parent.children, contains(child));
      expect(stage.sprites, isNot(contains(child)));
    });

    test('subordinate converts to relative coordinates', () {
      final stage = Stage();
      final parent = Sprite(x: 100, y: 50);
      final child = Sprite(x: 110, y: 55);
      stage.sprites.add(parent);
      stage.sprites.add(child);
      final s = Stage.subordinate(child, parent);
      s.tick(stage);
      expect(child.x, 10);
      expect(child.y, 5);
    });
  });

  group('Stage tick', () {
    test('completed animations are removed', () {
      final stage = Stage();
      stage.animate(Stage.delay(0));
      stage.tick();
      expect(stage.animations, isEmpty);
    });

    test('incomplete animations stay', () {
      final stage = Stage();
      stage.animate(Stage.delay(5));
      stage.tick();
      expect(stage.animations.length, 1);
    });

    test('multiple animations tick together', () {
      final stage = Stage();
      stage.animate(Stage.delay(1));
      stage.animate(Stage.delay(3));
      stage.tick();
      expect(stage.animations.length, 2);
      stage.tick();
      expect(stage.animations.length, 1);
    });
  });

  group('Tracking animation', () {
    test('tracking with doTrack false completes immediately', () {
      final stage = Stage();
      stage.doTrack = false;
      final sprite = Sprite(x: 0, y: 0, imageWidth: 10, imageHeight: 10);
      final t = Stage.track(sprite);
      expect(t.tick(stage), true);
    });

    test('tracking moves camera toward sprite', () {
      final stage = Stage();
      stage.doTrack = true;
      stage.camX = 0;
      stage.camY = 0;
      final sprite = Sprite(x: 200, y: 0, imageWidth: 0, imageHeight: 0);
      final t = Stage.track(sprite);
      bool done = false;
      int ticks = 0;
      while (!done && ticks < 100) {
        done = t.tick(stage);
        ticks++;
      }
      expect(stage.camX, 200);
    });
  });
}

class _TestAnimation implements Animation {
  final bool Function() _fn;
  _TestAnimation(this._fn);

  @override
  bool tick(Stage stage) => _fn();
}
