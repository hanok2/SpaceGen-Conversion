enum Cataclysm {
  nova(
    'nova',
    'The star of \$name goes nova, scraping the planet clean of all life!',
  ),
  volcanicEruptions(
    'series of volcanic eruptions',
    'Massive volcanic eruptions on \$name eradicate all life on the planet!',
  ),
  axialShift(
    'shift in the planet\'s orbital axis',
    'A shift in the orbital axis of \$name spells doom for all life on the planet!',
  ),
  meteoriteImpact(
    'massive asteroid impact',
    'All life on \$name is killed off by a massive asteroid impact!',
  ),
  nanofungalBloom(
    'nanofungal bloom',
    'A nanofungal bloom consumes all other life on \$name before itself dying from a lack of nutrients!',
  ),
  psionicShockwave(
    'psionic shockwave',
    'A psionic shockwave of unknown origin passes through \$name, instantly stopping all life!',
  );

  final String name;
  final String desc;
  
  const Cataclysm(this.name, this.desc);
}
