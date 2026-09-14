import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CF6),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class TTS {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.08);
    await _tts.speak(text);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int stars = 0;

  void addStar() {
    setState(() => stars++);
  }

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
              Color(0xFFFFEAF7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Edina's Little World 🌈",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "⭐ $stars",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.88),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "👧",
                        style: TextStyle(fontSize: 75),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Hello, Edina! 💕",
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
                      const SizedBox(height: 15),
                      FilledButton.icon(
                        onPressed: () {
                          TTS.speak("Hello Edina! Let's learn English!");
                        },
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text("Listen 🔊"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                MenuCard(
                  icon: "🎮",
                  title: "Play",
                  subtitle: "Fun English games",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ColorGamePage(onStar: addStar),
                      ),
                    );
                  },
                ),

                MenuCard(
                  icon: "📚",
                  title: "Learn",
                  subtitle: "Words, numbers and more",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LearnPage(onStar: addStar),
                      ),
                    );
                  },
                ),

                MenuCard(
                  icon: "📖",
                  title: "Story",
                  subtitle: "Little English stories",
                  onTap: () {
                    showComingSoon(context, "Stories 📖");
                  },
                ),

                MenuCard(
                  icon: "🎵",
                  title: "Songs",
                  subtitle: "Sing and learn",
                  onTap: () {
                    showComingSoon(context, "Songs 🎵");
                  },
                ),

                MenuCard(
                  icon: "👨‍👩‍👧",
                  title: "Family",
                  subtitle: "Learn together",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FamilyPage(onStar: addStar),
                      ),
                    );
                  },
                ),

                MenuCard(
                  icon: "⭐",
                  title: "My World",
                  subtitle: "Edina's stars",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Edina's Stars ⭐"),
                        content: Text(
                          "You have $stars stars!\n\nGreat job, Edina! 🌟",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Awesome!"),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "🌟 Learn • Play • Smile 🌟",
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
      margin: const EdgeInsets.only(bottom: 13),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 39)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class LearnPage extends StatelessWidget {
  final VoidCallback onStar;

  const LearnPage({
    super.key,
    required this.onStar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Learn! 📚"),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(18),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: [
          LearnCard(
            emoji: "🎨",
            title: "Colors",
            subtitle: "Learn colors",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ColorsPage(onStar: onStar),
                ),
              );
            },
          ),
          LearnCard(
            emoji: "🔢",
            title: "Numbers",
            subtitle: "One to ten",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NumbersPage(onStar: onStar),
                ),
              );
            },
          ),
          LearnCard(
            emoji: "🐶",
            title: "Animals",
            subtitle: "Cute animals",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimalsPage(onStar: onStar),
                ),
              );
            },
          ),
          LearnCard(
            emoji: "👨‍👩‍👧",
            title: "Family",
            subtitle: "Family words",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FamilyPage(onStar: onStar),
                ),
              );
            },
          ),
          LearnCard(
            emoji: "👋",
            title: "Greetings",
            subtitle: "Hello & Bye",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GreetingsPage(onStar: onStar),
                ),
              );
            },
          ),
        ],
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
        borderRadius: BorderRadius.circular(23),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  final String emoji;
  final String word;
  final String meaning;
  final VoidCallback onStar;

  const WordCard({
    super.key,
    required this.emoji,
    required this.word,
    required this.meaning,
    required this.onStar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    meaning,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: 31,
              onPressed: () => TTS.speak(word),
              icon: const Icon(Icons.volume_up_rounded),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () {
                onStar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⭐ Great job, Edina!"),
                    duration: Duration(milliseconds: 700),
                  ),
                );
              },
              icon: const Icon(Icons.star_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorsPage extends StatelessWidget {
  final VoidCallback onStar;

  const ColorsPage({
    super.key,
    required this.onStar,
  });

  final List<Map<String, String>> items = const [
    {"emoji": "🔴", "word": "Red", "meaning": "قرمز"},
    {"emoji": "🔵", "word": "Blue", "meaning": "آبی"},
    {"emoji": "🟢", "word": "Green", "meaning": "سبز"},
    {"emoji": "🟡", "word": "Yellow", "meaning": "زرد"},
    {"emoji": "🟠", "word": "Orange", "meaning": "نارنجی"},
    {"emoji": "🟣", "word": "Purple", "meaning": "بنفش"},
    {"emoji": "🩷", "word": "Pink", "meaning": "صورتی"},
    {"emoji": "🟤", "word": "Brown", "meaning": "قهوه‌ای"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors 🎨"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => WordCard(
                emoji: item["emoji"]!,
                word: item["word"]!,
                meaning: item["meaning"]!,
                onStar: onStar,
              ),
            )
            .toList(),
      ),
    );
  }
}

class NumbersPage extends StatelessWidget {
  final VoidCallback onStar;

  const NumbersPage({
    super.key,
    required this.onStar,
  });

  final List<Map<String, String>> numbers = const [
    {"emoji": "1️⃣", "word": "One", "meaning": "یک"},
    {"emoji": "2️⃣", "word": "Two", "meaning": "دو"},
    {"emoji": "3️⃣", "word": "Three", "meaning": "سه"},
    {"emoji": "4️⃣", "word": "Four", "meaning": "چهار"},
    {"emoji": "5️⃣", "word": "Five", "meaning": "پنج"},
    {"emoji": "6️⃣", "word": "Six", "meaning": "شش"},
    {"emoji": "7️⃣", "word": "Seven", "meaning": "هفت"},
    {"emoji": "8️⃣", "word": "Eight", "meaning": "هشت"},
    {"emoji": "9️⃣", "word": "Nine", "meaning": "نه"},
    {"emoji": "🔟", "word": "Ten", "meaning": "ده"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Numbers 🔢"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: numbers
            .map(
              (item) => WordCard(
                emoji: item["emoji"]!,
                word: item["word"]!,
                meaning: item["meaning"]!,
                onStar: onStar,
              ),
            )
            .toList(),
      ),
    );
  }
}

class AnimalsPage extends StatelessWidget {
  final VoidCallback onStar;

  const AnimalsPage({
    super.key,
    required this.onStar,
  });

  final List<Map<String, String>> animals = const [
    {"emoji": "🐶", "word": "Dog", "meaning": "سگ"},
    {"emoji": "🐱", "word": "Cat", "meaning": "گربه"},
    {"emoji": "🦁", "word": "Lion", "meaning": "شیر"},
    {"emoji": "🐘", "word": "Elephant", "meaning": "فیل"},
    {"emoji": "🐰", "word": "Rabbit", "meaning": "خرگوش"},
    {"emoji": "🐼", "word": "Panda", "meaning": "پاندا"},
    {"emoji": "🐵", "word": "Monkey", "meaning": "میمون"},
    {"emoji": "🦋", "word": "Butterfly", "meaning": "پروانه"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animals 🐾"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: animals
            .map(
              (item) => WordCard(
                emoji: item["emoji"]!,
                word: item["word"]!,
                meaning: item["meaning"]!,
                onStar: onStar,
              ),
            )
            .toList(),
      ),
    );
  }
}

class FamilyPage extends StatelessWidget {
  final VoidCallback onStar;

  const FamilyPage({
    super.key,
    required this.onStar,
  });

  final List<Map<String, String>> family = const [
    {"emoji": "👩", "word": "Mom", "meaning": "مامان"},
    {"emoji": "👨", "word": "Dad", "meaning": "بابا"},
    {"emoji": "👧", "word": "Girl", "meaning": "دختر"},
    {"emoji": "👦", "word": "Boy", "meaning": "پسر"},
    {"emoji": "👶", "word": "Baby", "meaning": "نوزاد"},
    {"emoji": "👨‍👩‍👧", "word": "Family", "meaning": "خانواده"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family 👨‍👩‍👧"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: family
            .map(
              (item) => WordCard(
                emoji: item["emoji"]!,
                word: item["word"]!,
                meaning: item["meaning"]!,
                onStar: onStar,
              ),
            )
            .toList(),
      ),
    );
  }
}

class GreetingsPage extends StatelessWidget {
  final VoidCallback onStar;

  const GreetingsPage({
    super.key,
    required this.onStar,
  });

  final List<Map<String, String>> greetings = const [
    {"emoji": "👋", "word": "Hello", "meaning": "سلام"},
    {"emoji": "🌞", "word": "Good morning", "meaning": "صبح بخیر"},
    {"emoji": "😊", "word": "How are you?", "meaning": "حالت چطوره؟"},
    {"emoji": "❤️", "word": "I am happy", "meaning": "من خوشحالم"},
    {"emoji": "👋", "word": "Goodbye", "meaning": "خداحافظ"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Greetings 👋"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: greetings
            .map(
              (item) => WordCard(
                emoji: item["emoji"]!,
                word: item["word"]!,
                meaning: item["meaning"]!,
                onStar: onStar,
              ),
            )
            .toList(),
      ),
    );
  }
}

class ColorGamePage extends StatefulWidget {
  final VoidCallback onStar;

  const ColorGamePage({
    super.key,
    required this.onStar,
  });

  @override
  State<ColorGamePage> createState() => _ColorGamePageState();
}

class _ColorGamePageState extends State<ColorGamePage> {
  final List<Map<String, dynamic>> colors = [
    {"name": "Red", "emoji": "🔴"},
    {"name": "Blue", "emoji": "🔵"},
    {"name": "Green", "emoji": "🟢"},
    {"name": "Yellow", "emoji": "🟡"},
  ];

  int target = 0;
  int score = 0;

  void choose(int index) {
    if (index == target) {
      setState(() {
        score++;
        target = (target + 1) % colors.length;
      });

      widget.onStar();
      TTS.speak("Great job!");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⭐ Correct! Great job!"),
          duration: Duration(milliseconds: 700),
        ),
      );
    } else {
      TTS.speak("Try again");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Try again 😊"),
          duration: Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetName = colors[target]["name"] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Game 🎮"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Find this color:",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              targetName,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              iconSize: 42,
              onPressed: () => TTS.speak(targetName),
              icon: const Icon(Icons.volume_up_rounded),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: List.generate(
                  colors.length,
                  (index) => InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => choose(index),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          colors[index]["emoji"],
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              "Score: $score ⭐",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showComingSoon(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: const Text(
        "This magical section is coming soon! ✨",
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
