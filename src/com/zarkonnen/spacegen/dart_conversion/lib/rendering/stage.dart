import 'dart:math';

import 'sprite.dart';

abstract class Animation {
  bool tick(Stage stage);
}

class Stage {
  bool doTrack = true;
  List<Sprite> sprites = [];
  List<Animation> animations = [];

  int camX = 0;
  int camY = 0;

  void animate(Animation a) => animations.add(a);
  void animateAll(List<Animation> as) => animations.addAll(as);

  bool tick() {
    animations.removeWhere((a) => a.tick(this));
    return animations.isEmpty;
  }

  static Animation delay(int wait, [Animation? a]) => Delay(wait, a);
  static Animation defaultDelay() => Delay(10, null);
  static Animation bigDelay() => Delay(40, null);

  static Animation tracking(Sprite s, [Animation? a]) => Tracking(s, a);
  static Animation track(Sprite s) => Tracking(s, null);

  static Animation seq(List<Animation> sequence) => Seq(sequence);

  static Animation sim(List<Animation> simultaneous) => Sim(simultaneous);

  static Animation move(Sprite s, int tx, int ty, [int time = 0]) =>
      Move(s, tx, ty, time);

  static Animation remove(Sprite s) => Remove(s);

  static Animation add(Sprite s, [Sprite? parent]) => Add(s, parent);

  static Animation change(Sprite s, String newImagePath) =>
      Change(s, newImagePath);

  static Animation emancipate(Sprite s) => Emancipate(s);

  static Animation subordinate(Sprite s, Sprite parent) =>
      Subordinate(s, parent);
}

class Delay implements Animation {
  Animation? a;
  int wait;

  Delay(this.wait, this.a);

  @override
  bool tick(Stage stage) {
    if (wait > 0) {
      wait--;
      return false;
    }
    return a == null ? true : a!.tick(stage);
  }
}

class Tracking implements Animation {
  Sprite s;
  Animation? a;
  int _tick = 0;
  int time = 0;
  int sx = 0;
  int sy = 0;
  bool lock = false;

  Tracking(this.s, this.a);

  @override
  bool tick(Stage stage) {
    if (!stage.doTrack) {
      return a == null ? true : a!.tick(stage);
    }
    int tx = s.globalX() + s.imageWidth ~/ 2;
    int ty = s.globalY() + s.imageHeight ~/ 2;
    if (_tick == 0) {
      sx = stage.camX;
      sy = stage.camY;
      time = (sqrt(((sx - tx) * (sx - tx) + (sy - ty) * (sy - ty)).toDouble()) / 120).toInt() + 3;
    }
    if (!lock) {
      stage.camX = sx + (tx - sx) * _tick ~/ time;
      stage.camY = sy + (ty - sy) * _tick ~/ time;
      _tick++;
      lock = _tick > time;
      return false;
    } else {
      stage.camX = tx;
      stage.camY = ty;
      return a == null ? true : a!.tick(stage);
    }
  }
}

class Seq implements Animation {
  List<Animation> sequence;
  int index = 0;

  Seq(this.sequence);

  @override
  bool tick(Stage stage) {
    if (index >= sequence.length) return true;
    if (sequence[index].tick(stage)) {
      index++;
    }
    return index == sequence.length;
  }
}

class Sim implements Animation {
  List<Animation?> simultaneous;

  Sim(List<Animation> anims) : simultaneous = List<Animation?>.from(anims);

  @override
  bool tick(Stage stage) {
    bool live = false;
    for (int i = 0; i < simultaneous.length; i++) {
      if (simultaneous[i] != null) {
        if (simultaneous[i]!.tick(stage)) {
          simultaneous[i] = null;
        } else {
          live = true;
        }
      }
    }
    return !live;
  }
}

class Move implements Animation {
  Sprite s;
  int sx = 0;
  int sy = 0;
  int tx;
  int ty;
  int time;
  int _tick = 0;

  Move(this.s, this.tx, this.ty, [this.time = 0]);

  @override
  bool tick(Stage stage) {
    if (_tick == 0) {
      sx = s.x;
      sy = s.y;
      if (time == 0) {
        time = (sqrt(((sx - tx) * (sx - tx) + (sy - ty) * (sy - ty)).toDouble()) / 60).toInt() + 2;
      }
    }
    if (_tick >= time) {
      s.x = tx;
      s.y = ty;
      s.highlight = false;
      return true;
    }
    s.highlight = true;
    s.x = sx + (tx - sx) * _tick ~/ time;
    s.y = sy + (ty - sy) * _tick ~/ time;
    _tick++;
    return false;
  }
}

class Remove implements Animation {
  Sprite s;
  int _tick = 0;

  Remove(this.s);

  @override
  bool tick(Stage stage) {
    s.flash = true;
    if (_tick++ > 5) {
      if (s.parent == null) {
        stage.sprites.remove(s);
      } else {
        s.parent!.children.remove(s);
      }
      return true;
    }
    return false;
  }
}

class Add implements Animation {
  Sprite s;
  Sprite? parent;
  int _tick = 0;

  Add(this.s, [this.parent]);

  @override
  bool tick(Stage stage) {
    s.flash = true;
    if (_tick++ == 0) {
      if (parent == null) {
        stage.sprites.add(s);
      } else {
        parent!.children.add(s);
      }
      s.parent = parent;
    }
    if (_tick > 5) {
      s.flash = false;
      return true;
    }
    return false;
  }
}

class Change implements Animation {
  Sprite s;
  String newImagePath;
  int _tick = 0;

  Change(this.s, this.newImagePath);

  @override
  bool tick(Stage stage) {
    s.flash = true;
    if (_tick++ > 2) {
      s.imagePath = newImagePath;
    }
    if (_tick > 5) {
      s.flash = false;
      return true;
    }
    return false;
  }
}

class Emancipate implements Animation {
  Sprite s;

  Emancipate(this.s);

  @override
  bool tick(Stage stage) {
    if (s.parent != null) {
      s.x = s.globalX();
      s.y = s.globalY();
      s.parent!.children.remove(s);
      s.parent = null;
      stage.sprites.add(s);
    }
    return true;
  }
}

class Subordinate implements Animation {
  Sprite s;
  Sprite parent;

  Subordinate(this.s, this.parent);

  @override
  bool tick(Stage stage) {
    if (s.parent != null) {
      s.x = s.globalX();
      s.y = s.globalY();
      s.parent!.children.remove(s);
      s.parent = null;
    }
    stage.sprites.remove(s);
    s.parent = parent;
    parent.children.add(s);
    s.x -= parent.globalX();
    s.y -= parent.globalY();
    return true;
  }
}
