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
                    children: [
                      MenuCard(
                        icon: "🎮",
                        title: "Play",
                        subtitle: "Let's play!",
                        onTap: () {},
                      ),
                      MenuCard(
                        icon: "📚",
                        title: "Learn",
                        subtitle: "New words",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ColorsPage(),
                            ),
                          );
                        },
                      ),
                      MenuCard(
                        icon: "📖",
                        title: "Story",
                        subtitle: "Story time",
                        onTap: () {},
                      ),
                      MenuCard(
                        icon: "🎵",
                        title: "Songs",
                        subtitle: "Sing with me",
                        onTap: () {},
                      ),
                      MenuCard(
                        icon: "👨‍👩‍👧",
                        title: "Family",
                        subtitle: "Play together",
                        onTap: () {},
                      ),
                      MenuCard(
                        icon: "⭐",
                        title: "My World",
                        subtitle: "My stars",
                        onTap: () {},
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
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 42)),
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

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [
      ("Red", "🔴", Colors.red),
      ("Blue", "🔵", Colors.blue),
      ("Green", "🟢", Colors.green),
      ("Yellow", "🟡", Colors.amber),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors 🎨"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: colors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = colors[index];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(item.$2),
                      content: Text(
                        item.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Great! ⭐"),
                        ),
                      ],
                    ),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(fontSize: 55),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
