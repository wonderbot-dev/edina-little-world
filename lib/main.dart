import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const AdinaApp());

class Voice {
  static final FlutterTts tts = FlutterTts();

  static Future<void> speak(String text, {bool repeat = false}) async {
    await tts.stop();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(repeat ? 0.32 : 0.42);
    await tts.setPitch(1.08);
    await tts.speak(text);
  }
}

class AdinaApp extends StatelessWidget {
  const AdinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Adina's Little World",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int stars = 12;
  int xp = 35;

  void reward(int amount) {
    setState(() {
      stars += amount;
      xp += amount * 5;
    });
  }

  void open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = (xp ~/ 50) + 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE7F6),
              Color(0xFFFFF8E1),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Adina's\nLittle World 🌈",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      radius: 38,
                      backgroundImage:
                          const AssetImage('assets/images/adina.jpg'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Adina profile card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundImage:
                            AssetImage('assets/images/adina.jpg'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hello, Adina! 💕",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text("Level $level • $xp XP"),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (xp % 50) / 50,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text("⭐", style: TextStyle(fontSize: 25)),
                          Text(
                            "$stars",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                  children: [
                    MenuCard(
                      icon: "🎮",
                      title: "Play",
                      subtitle: "Fun Games",
                      onTap: () => open(GamesPage(onReward: reward)),
                    ),
                    MenuCard(
                      icon: "📚",
                      title: "Learn",
                      subtitle: "New Words",
                      onTap: () => open(LearnPage(onReward: reward)),
                    ),
                    MenuCard(
                      icon: "🔤",
                      title: "Alphabet",
                      subtitle: "A to Z",
                      onTap: () => open(AlphabetPage(onReward: reward)),
                    ),
                    MenuCard(
                      icon: "✍️",
                      title: "Spelling",
                      subtitle: "Build Words",
                      onTap: () => open(SpellingPage(onReward: reward)),
                    ),
                    MenuCard(
                      icon: "📖",
                      title: "Story",
                      subtitle: "Adina's Story",
                      onTap: () => open(const StoryPage()),
                    ),
                    MenuCard(
                      icon: "🎵",
                      title: "Songs",
                      subtitle: "Sing & Learn",
                      onTap: () => open(const SongsPage()),
                    ),
                    MenuCard(
                      icon: "👨‍👩‍👧",
                      title: "Family",
                      subtitle: "Play Together",
                      onTap: () => open(FamilyPage(onReward: reward)),
                    ),
                    MenuCard(
                      icon: "⭐",
                      title: "My Progress",
                      subtitle: "My Little World",
                      onTap: () => open(
                        ProgressPage(stars: stars, xp: xp),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "🌟 Today's Adventure",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Play, listen, repeat and discover something new!",
                        textAlign: TextAlign.center,
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
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class LearnPage extends StatelessWidget {
  final Function(int) onReward;

  const LearnPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📚 Let's Learn!")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearnTile(
            icon: "🎨",
            title: "Colors",
            subtitle: "Red, Blue, Green...",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ColorsPage(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "🔢",
            title: "Numbers",
            subtitle: "One to Ten",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NumbersPage(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "🐶",
            title: "Animals",
            subtitle: "Dog, Cat, Lion...",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimalsPage(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "👨‍👩‍👧",
            title: "Family",
            subtitle: "Mom, Dad, Baby...",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FamilyPage(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "👋",
            title: "Greetings",
            subtitle: "Hello, Bye, Good morning...",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GreetingsPage(onReward: onReward),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LearnTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const LearnTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Text(icon, style: const TextStyle(fontSize: 38)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class WordPage extends StatelessWidget {
  final String title;
  final String emoji;
  final Function(int) onReward;

  const WordPage({
    super.key,
    required this.title,
    required this.emoji,
    required this.onReward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 100)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () => Voice.speak(title),
              icon: const Icon(Icons.volume_up),
              label: const Text("Listen"),
            ),
            ElevatedButton.icon(
              onPressed: () => Voice.speak(title, repeat: true),
              icon: const Icon(Icons.repeat),
              label: const Text("Repeat Slowly"),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: () {
                onReward(1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Great job! ⭐ +1")),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text("I learned it!"),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorsPage extends StatelessWidget {
  final Function(int) onReward;

  const ColorsPage({super.key, required this.onReward});

  final List<Map<String, dynamic>> colors = const [
    {"name": "Red", "emoji": "🔴"},
    {"name": "Blue", "emoji": "🔵"},
    {"name": "Green", "emoji": "🟢"},
    {"name": "Yellow", "emoji": "🟡"},
    {"name": "Orange", "emoji": "🟠"},
    {"name": "Purple", "emoji": "🟣"},
    {"name": "Pink", "emoji": "🩷"},
    {"name": "Brown", "emoji": "🟤"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎨 Colors")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: colors.length,
        itemBuilder: (_, i) {
          final item = colors[i];
          return WordPageCard(
            title: item["name"],
            emoji: item["emoji"],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordPage(
                  title: item["name"],
                  emoji: item["emoji"],
                  onReward: onReward,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NumbersPage extends StatelessWidget {
  final Function(int) onReward;

  const NumbersPage({super.key, required this.onReward});

  final List<String> numbers = const [
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔢 Numbers")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: numbers.length,
        itemBuilder: (_, i) {
          return WordPageCard(
            title: numbers[i],
            emoji: "${i + 1}️⃣",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordPage(
                  title: numbers[i],
                  emoji: "${i + 1}️⃣",
                  onReward: onReward,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimalsPage extends StatelessWidget {
  final Function(int) onReward;

  const AnimalsPage({super.key, required this.onReward});

  final List<Map<String, String>> animals = const [
    {"name": "Dog", "emoji": "🐶"},
    {"name": "Cat", "emoji": "🐱"},
    {"name": "Lion", "emoji": "🦁"},
    {"name": "Elephant", "emoji": "🐘"},
    {"name": "Monkey", "emoji": "🐵"},
    {"name": "Rabbit", "emoji": "🐰"},
    {"name": "Bear", "emoji": "🐻"},
    {"name": "Bird", "emoji": "🐦"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🐾 Animals")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: animals.length,
        itemBuilder: (_, i) {
          return WordPageCard(
            title: animals[i]["name"]!,
            emoji: animals[i]["emoji"]!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordPage(
                  title: animals[i]["name"]!,
                  emoji: animals[i]["emoji"]!,
                  onReward: onReward,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FamilyPage extends StatelessWidget {
  final Function(int) onReward;

  const FamilyPage({super.key, required this.onReward});

  final List<Map<String, String>> family = const [
    {"name": "Mom", "emoji": "👩"},
    {"name": "Dad", "emoji": "👨"},
    {"name": "Baby", "emoji": "👶"},
    {"name": "Sister", "emoji": "👧"},
    {"name": "Brother", "emoji": "👦"},
    {"name": "Family", "emoji": "👨‍👩‍👧"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👨‍👩‍👧 Family")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: family.length,
        itemBuilder: (_, i) {
          return WordPageCard(
            title: family[i]["name"]!,
            emoji: family[i]["emoji"]!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordPage(
                  title: family[i]["name"]!,
                  emoji: family[i]["emoji"]!,
                  onReward: onReward,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GreetingsPage extends StatelessWidget {
  final Function(int) onReward;

  const GreetingsPage({super.key, required this.onReward});

  final List<String> greetings = const [
    "Hello",
    "Bye",
    "Good morning",
    "Good night",
    "How are you?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👋 Greetings")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: greetings.length,
        itemBuilder: (_, i) {
          return Card(
            child: ListTile(
              leading: const Text("👋", style: TextStyle(fontSize: 32)),
              title: Text(
                greetings[i],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => Voice.speak(greetings[i]),
              ),
              onTap: () => Voice.speak(greetings[i]),
            ),
          );
        },
      ),
    );
  }
}

class WordPageCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const WordPageCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 55)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlphabetPage extends StatelessWidget {
  final Function(int) onReward;

  const AlphabetPage({super.key, required this.onReward});

  final List<Map<String, String>> letters = const [
    {"l": "A", "w": "Apple", "e": "🍎"},
    {"l": "B", "w": "Ball", "e": "⚽"},
    {"l": "C", "w": "Cat", "e": "🐱"},
    {"l": "D", "w": "Dog", "e": "🐶"},
    {"l": "E", "w": "Elephant", "e": "🐘"},
    {"l": "F", "w": "Fish", "e": "🐟"},
    {"l": "G", "w": "Grapes", "e": "🍇"},
    {"l": "H", "w": "House", "e": "🏠"},
    {"l": "I", "w": "Ice cream", "e": "🍦"},
    {"l": "J", "w": "Juice", "e": "🧃"},
    {"l": "K", "w": "Kite", "e": "🪁"},
    {"l": "L", "w": "Lion", "e": "🦁"},
    {"l": "M", "w": "Moon", "e": "🌙"},
    {"l": "N", "w": "Nose", "e": "👃"},
    {"l": "O", "w": "Orange", "e": "🍊"},
    {"l": "P", "w": "Panda", "e": "🐼"},
    {"l": "Q", "w": "Queen", "e": "👑"},
    {"l": "R", "w": "Rabbit", "e": "🐰"},
    {"l": "S", "w": "Sun", "e": "☀️"},
    {"l": "T", "w": "Tree", "e": "🌳"},
    {"l": "U", "w": "Umbrella", "e": "☂️"},
    {"l": "V", "w": "Violin", "e": "🎻"},
    {"l": "W", "w": "Water", "e": "💧"},
    {"l": "X", "w": "Xylophone", "e": "🎵"},
    {"l": "Y", "w": "Yellow", "e": "💛"},
    {"l": "Z", "w": "Zebra", "e": "🦓"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔤 Alphabet A-Z")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: letters.length,
        itemBuilder: (_, i) {
          final x = letters[i];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Voice.speak(x["l"]!);
              await Future.delayed(const Duration(milliseconds: 400));
              await Voice.speak("${x["l"]} for ${x["w"]}");
              onReward(1);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    x["l"]!,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    x["e"]!,
                    style: const TextStyle(fontSize: 30),
                  ),
                  Text(x["w"]!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SpellingPage extends StatefulWidget {
  final Function(int) onReward;

  const SpellingPage({super.key, required this.onReward});

  @override
  State<SpellingPage> createState() => _SpellingPageState();
}

class _SpellingPageState extends State<SpellingPage> {
  final words = const ["CAT", "DOG", "SUN", "PEN", "BUS", "CUP"];
  int index = 0;
  String answer = "";

  void choose(String letter) {
    if (answer.length >= words[index].length) return;

    setState(() => answer += letter);

    if (answer.length == words[index].length) {
      if (answer == words[index]) {
        widget.onReward(2);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Amazing! 🎉 +2 Stars")),
          );
          setState(() {
            index = (index + 1) % words.length;
            answer = "";
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => answer = "");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = words[index];
    final letters = word.split("")..shuffle();

    return Scaffold(
      appBar: AppBar(title: const Text("✍️ Spelling")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Build the word!",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              word == "CAT"
                  ? "🐱"
                  : word == "DOG"
                      ? "🐶"
                      : word == "SUN"
                          ? "☀️"
                          : word == "PEN"
                              ? "🖊️"
                              : word == "BUS"
                                  ? "🚌"
                                  : "🥤",
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 15),
            Text(
              answer.isEmpty ? "_ _ _" : answer,
              style: const TextStyle(
                fontSize: 40,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: letters.map((letter) {
                return ElevatedButton(
                  onPressed: () => choose(letter),
                  child: Text(
                    letter,
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => Voice.speak(word),
              icon: const Icon(Icons.volume_up),
              label: const Text("Listen"),
            ),
          ],
        ),
      ),
    );
  }
}

class GamesPage extends StatelessWidget {
  final Function(int) onReward;

  const GamesPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎮 Play")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearnTile(
            icon: "🎨",
            title: "Color Game",
            subtitle: "Find the right color",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ColorGame(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "🔤",
            title: "Letter Game",
            subtitle: "Find the letter",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LetterGame(onReward: onReward),
              ),
            ),
          ),
          LearnTile(
            icon: "✍️",
            title: "Spelling",
            subtitle: "Build simple words",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpellingPage(onReward: onReward),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorGame extends StatefulWidget {
  final Function(int) onReward;

  const ColorGame({super.key, required this.onReward});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  String target = "RED";
  final options = const ["RED", "BLUE", "GREEN", "YELLOW"];

  void pick(String value) {
    if (value == target) {
      widget.onReward(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfect! 🌟")),
      );
      setState(() {
        target = options[(options.indexOf(target) + 1) % options.length];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Try again! 😊")),
      );
    }
  }

  Color getColor(String value) {
    switch (value) {
      case "RED":
        return Colors.red;
      case "BLUE":
        return Colors.blue;
      case "GREEN":
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎨 Color Game")),
      body: Column(
        children: [
          const SizedBox(height: 35),
          const Text(
            "Find:",
            style: TextStyle(fontSize: 25),
          ),
          Text(
            target,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: getColor(target),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: options.map((x) {
              return InkWell(
                onTap: () => pick(x),
                child: Container(
                  width: 130,
                  height: 100,
                  decoration: BoxDecoration(
                    color: getColor(x),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class LetterGame extends StatefulWidget {
  final Function(int) onReward;

  const LetterGame({super.key, required this.onReward});

  @override
  State<LetterGame> createState() => _LetterGameState();
}

class _LetterGameState extends State<LetterGame> {
  final letters = ["A", "B", "C", "D"];
  String target = "A";

  void pick(String x) {
    if (x == target) {
      widget.onReward(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Great letter! ⭐")),
      );
      setState(() {
        target = letters[(letters.indexOf(target) + 1) % letters.length];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔤 Letter Game")),
      body: Column(
        children: [
          const SizedBox(height: 35),
          const Text("Find this letter"),
          const SizedBox(height: 10),
          Text(
            target,
            style: const TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            children: letters.map((x) {
              return ElevatedButton(
                onPressed: () => pick(x),
                child: Text(
                  x,
                  style: const TextStyle(fontSize: 30),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  final String story = """
Once upon a time, Adina found a beautiful rainbow. 🌈

She looked at the sky and said:
"Hello, Rainbow!"

The rainbow answered:
"Hello, Adina! Let's learn English together!"

They learned colors:
Red, Blue, Green and Yellow. 🎨

Then they counted:
One, Two, Three, Four, Five! 🔢

Adina smiled and said:
"I love learning!"

And the rainbow replied:
"Learning is an adventure!" ⭐
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📖 Adina's Story")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage('assets/images/adina.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Adina and the Rainbow 🌈",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              story,
              style: const TextStyle(
                fontSize: 20,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Voice.speak(story),
              icon: const Icon(Icons.volume_up),
              label: const Text("Listen"),
            ),
            OutlinedButton.icon(
              onPressed: () => Voice.speak(story, repeat: true),
              icon: const Icon(Icons.repeat),
              label: const Text("Repeat Slowly"),
            ),
          ],
        ),
      ),
    );
  }
}

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  Future<void> sing(String text) async {
    await Voice.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final songs = [
      {
        "title": "ABC Song",
        "text": "A B C D E F G, H I J K L M N O P, Q R S, T U V, W X Y and Z!"
      },
      {
        "title": "Numbers Song",
        "text": "One two three four five, six seven eight nine ten!"
      },
      {
        "title": "Colors Song",
        "text": "Red, blue, green, yellow, orange, purple, pink!"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("🎵 Songs")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Text(
                "🎵",
                style: TextStyle(fontSize: 35),
              ),
              title: Text(
                songs[i]["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_fill),
                iconSize: 35,
                onPressed: () => sing(songs[i]["text"]!),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProgressPage extends StatelessWidget {
  final int stars;
  final int xp;

  const ProgressPage({
    super.key,
    required this.stars,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final level = (xp ~/ 50) + 1;

    return Scaffold(
      appBar: AppBar(title: const Text("⭐ My Progress")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/adina.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Adina's Progress",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            ProgressCard(
              icon: "⭐",
              title: "Stars",
              value: "$stars",
            ),
            ProgressCard(
              icon: "✨",
              title: "XP",
              value: "$xp",
            ),
            ProgressCard(
              icon: "🏆",
              title: "Level",
              value: "$level",
            ),
            const SizedBox(height: 20),
            const Text(
              "Keep playing and learning! 🌈",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const ProgressCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
