enum SpecialLifeform {
  ultravores(
    'Ultravores',
    'The ultimate apex predator, the Ultravore is capable of stalking and killing even the most intelligent and well-armed prey.',
  ),
  pharmaceuticals(
    'Pharmaceuticals',
    'Plants that contain interesting chemical compounds with medical applications.',
  ),
  shapeShifter(
    'Shape-shifters',
    'A predatory creature able to mimic any other, even a sentient one.',
  ),
  brainParasite(
    'Brain parasites',
    'A parasitical creature able to interface with the brain of its host, enslaving it.',
  ),
  vastHerds(
    'Vast grazing herds',
    'Untold millions of large grazing animals that provide an abundant source of food and other resources.',
  ),
  flyingCreatures(
    'Beautiful flying creatures',
    'Fluttering fliers that display a dazzling array of colours.',
  ),
  oceanGiants(
    'Ocean giants',
    'Huge sea creatures growing to more than a kilometre of length.',
  ),
  livingIslands(
    'Living islands',
    'Composed of the shells of millions of small crustaceans, each of these floating islands hosts its own unique ecosystem.',
  ),
  gasBags(
    'Gas bags',
    'Held aloft by sacs of hydrogen, these delicate creatures float about everywhere.',
  ),
  radiovores(
    'Radiovores',
    'These small worm-like creatures derive their energy directly from exposed deposits of radioactive materials.',
  );

  final String name;
  final String desc;
  
  const SpecialLifeform(this.name, this.desc);
}
