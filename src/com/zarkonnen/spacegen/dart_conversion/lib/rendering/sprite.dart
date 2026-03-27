class Sprite {
  int x;
  int y;
  String? imagePath;
  int imageWidth;
  int imageHeight;
  List<Sprite> children = [];
  Sprite? parent;
  bool highlight = false;
  bool flash = false;

  Sprite({
    this.imagePath,
    this.x = 0,
    this.y = 0,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  int globalX() {
    if (parent == null) return x;
    return parent!.globalX() + x;
  }

  int globalY() {
    if (parent == null) return y;
    return parent!.globalY() + y;
  }
}
