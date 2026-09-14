import 'package:flutter/material.dart';

void main() {
  runApp(const EdinaLittleWorld());
}

class EdinaLittleWorld extends StatelessWidget {
  const EdinaLittleWorld({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Edina's Little World",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F7FF),
              Color(0xFFFFF4FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello, Edina! 🌈",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Let's play and learn English!",
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: const [
                      MenuCard(
                        icon: "🎮",
                        title: "Play",
                        subtitle: "Let's play!",
                      ),
                      MenuCard(
                        icon: "📚",
                        title: "Learn",
                        subtitle: "New words",
                      ),
                      MenuCard(
                        icon: "📖",
                        title: "Story",
                        subtitle: "Story time",
                      ),
                      MenuCard(
                        icon: "🎵",
                        title: "Songs",
                        subtitle: "Sing with me",
                      ),
                      MenuCard(
                        icon: "👨‍👩‍👧",
                        title: "Family",
                        subtitle: "Play together",
                      ),
                      MenuCard(
                        icon: "⭐",
                        title: "My World",
                        subtitle: "My stars",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 42),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
