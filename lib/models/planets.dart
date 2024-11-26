class Planet {
  final String name;
  final String imagePath;
  final String command; // Command for fetching data from Horizons API

  Planet({
    required this.name,
    required this.command,
    required this.imagePath,
  });

  static final List<Planet> planets = [
    Planet(
      name: "Mercury", command: "199", imagePath: 'assets/mercury.png'),
    Planet(
      name: "Venus", command: "299", imagePath: 'assets/venus.png'),
    Planet(
      name: "Mars", command: "499", imagePath: 'assets/mars.png'),
    Planet(
      name: "Jupiter", command: "599", imagePath: 'assets/jupiter.png'),
    Planet(
      name: "Saturn", command: "699", imagePath: 'assets/saturn.png'),
    Planet(
      name: "Uranus", command: "799", imagePath: 'assets/uranus.png'),
    Planet(
      name: "Neptune", command: "899",imagePath: 'assets/neptune.png'),
    Planet(
      name: "Sun", command: "10", imagePath: 'assets/sun.png'),
    Planet(
      name: "Moon", command: "301", imagePath: 'assets/moon.png'),
  ];
}

