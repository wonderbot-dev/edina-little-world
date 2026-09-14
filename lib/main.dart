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
        fontFamily: 'Arial',
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
              Color(0xFFFFF5FC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Hello, Edina! 🌈",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's play and learn English! ✨",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),

                MenuCard(
                  icon: "🎮",
                  title: "Play",
                  subtitle: "Fun learning games",
                  onTap: () {},
                ),

                MenuCard(
                  icon: "📚",
                  title: "Learn",
                  subtitle: "Words and new things",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearnPage(),
                      ),
                    );
                  },
                ),

                MenuCard(
                  icon: "📖",
                  title: "Story",
                  subtitle: "Little English stories",
                  onTap: () {},
                ),

                MenuCard(
                  icon: "🎵",
                  title: "Songs",
                  subtitle: "Sing and learn",
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
                  subtitle: "Edina's stars and badges",
                  onTap: () {},
                ),

                const SizedBox(height: 20),
                const Text(
                  "🌟 Keep learning, Edina! 🌟",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 38),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Learn! 📚"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            LearnCard(
              emoji: "🎨",
              title: "Colors",
              subtitle: "Red, Blue...",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ColorsPage(),
                  ),
                );
              },
            ),
            LearnCard(
              emoji: "🔢",
              title: "Numbers",
              subtitle: "1 to 10",
              onTap: () {},
            ),
            LearnCard(
              emoji: "🐶",
              title: "Animals",
              subtitle: "Dog, Cat...",
              onTap: () {},
            ),
            LearnCard(
              emoji: "👨‍👩‍👧",
              title: "Family",
              subtitle: "Mom, Dad...",
              onTap: () {},
            ),
            LearnCard(
              emoji: "👋",
              title: "Greetings",
              subtitle: "Hello!",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class LearnCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const LearnCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  final List<Map<String, String>> colors = const [
    {"name": "Red", "emoji": "🔴"},
    {"name": "Blue", "emoji": "🔵"},
    {"name": "Green", "emoji": "🟢"},
    {"name": "Yellow", "emoji": "🟡"},
    {"name": "Orange", "emoji": "🟠"},
    {"name": "Purple", "emoji": "🟣"},
    {"name": "Pink", "emoji": "🩷"},
    {"name": "Brown", "emoji": "🟤"},
  ];

  void showColor(BuildContext context, String name, String emoji) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Great job, Edina! ⭐",
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Great! ⭐"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors 🎨"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: colors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final color = colors[index];

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                showColor(
                  context,
                  color["name"]!,
                  color["emoji"]!,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    color["emoji"]!,
                    style: const TextStyle(fontSize: 55),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    color["name"]!,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
