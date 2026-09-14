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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CF6),
        ),
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
  int stars = 0;
  int xp = 0;

  int get level => (xp ~/ 50) + 1;

  void reward([int amount = 1]) {
    setState(() {
      stars += amount;
      xp += amount * 10;
    });
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
              Color(0xFFE7F7FF),
              Color(0xFFFFEAF7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Adina's Little World 🌈",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _stat("⭐", stars),
                  ],
                ),

                const SizedBox(height: 18),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        const Text(
                          "👧✨",
                          style: TextStyle(fontSize: 72),
                        ),
                        const Text(
                          "Hello, Adina! 💕",
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Let's play and learn English!",
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () =>
                              Voice.speak("Hello Adina! Let's learn English!"),
                          icon: const Icon(Icons.volume_up),
                          label: const Text("Listen"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _progressCard(),

                const SizedBox(height: 15),

                _menu(
                  "🎮",
                  "Play",
                  "Fun English games",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamesPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "📚",
                  "Learn",
                  "Learn English",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearnPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "🔤",
                  "Alphabet",
                  "A to Z",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlphabetPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "✍️",
                  "Spelling",
                  "Build English words",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SpellingPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "📖",
                  "Story",
                  "Little English stories",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "🎵",
                  "Songs",
                  "Sing and learn",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongsPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "👨‍👩‍👧",
                  "Family",
                  "Learn together",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FamilyPage(onReward: reward),
                    ),
                  ),
                ),

                _menu(
                  "🏆",
                  "My Progress",
                  "Level $level • $xp XP",
                  () => _progressDialog(),
                ),

                const SizedBox(height: 12),

                const Text(
                  "🌟 Learn • Play • Smile 🌟",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String icon, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$icon $value",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _progressCard() {
    final progress = (xp % 50) / 50;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Level $level ⭐",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text("$xp XP"),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: Text(
          emoji,
          style: const TextStyle(fontSize: 38),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  void _progressDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adina's Progress 🏆"),
        content: Text(
          "Level: $level\n"
          "XP: $xp\n"
          "Stars: $stars ⭐\n\n"
          "Amazing job, Adina! 🌈",
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
  }
}

class LearnPage extends StatelessWidget {
  final Function([int]) onReward;

  const LearnPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    final items = [
      ["🎨", "Colors", ColorsPage(onReward: onReward)],
      ["🔢", "Numbers", NumbersPage(onReward: onReward)],
      ["🐾", "Animals", AnimalsPage(onReward: onReward)],
      ["👨‍👩‍👧", "Family", FamilyPage(onReward: onReward)],
      ["👋", "Greetings", GreetingsPage(onReward: onReward)],
    ];

    return _gridPage(context, "Learn 📚", items);
  }
}

Widget _gridPage(
  BuildContext context,
  String title,
  List<List<dynamic>> items,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
    ),
    body: GridView.builder(
      padding: const EdgeInsets.all(18),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(23),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => items[i][2]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  items[i][0],
                  style: const TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 8),
                Text(
                  items[i][1],
                  style: const TextStyle(
                    fontSize: 19,
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

class WordPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> words;
  final Function([int]) onReward;

  const WordPage({
    super.key,
    required this.title,
    required this.words,
    required this.onReward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        itemBuilder: (_, i) {
          final w = words[i];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(
                    w["emoji"]!,
                    style: const TextStyle(fontSize: 45),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w["word"]!,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(w["meaning"]!),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 30,
                    ),
                    onPressed: () => Voice.speak(w["word"]!),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.repeat,
                      size: 30,
                    ),
                    onPressed: () => Voice.speak(
                      w["word"]!,
                      repeat: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.star,
                      size: 30,
                    ),
                    onPressed: () {
                      onReward();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("⭐ Great job, Adina!"),
                        ),
                      );
                    },
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

class ColorsPage extends StatelessWidget {
  final Function([int]) onReward;

  const ColorsPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return WordPage(
      title: "Colors 🎨",
      onReward: onReward,
      words: const [
        {"emoji": "🔴", "word": "Red", "meaning": "قرمز"},
        {"emoji": "🔵", "word": "Blue", "meaning": "آبی"},
        {"emoji": "🟢", "word": "Green", "meaning": "سبز"},
        {"emoji": "🟡", "word": "Yellow", "meaning": "زرد"},
        {"emoji": "🟠", "word": "Orange", "meaning": "نارنجی"},
        {"emoji": "🟣", "word": "Purple", "meaning": "بنفش"},
        {"emoji": "🩷", "word": "Pink", "meaning": "صورتی"},
        {"emoji": "🟤", "word": "Brown", "meaning": "قهوه‌ای"},
      ],
    );
  }
}

class NumbersPage extends StatelessWidget {
  final Function([int]) onReward;

  const NumbersPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return WordPage(
      title: "Numbers 🔢",
      onReward: onReward,
      words: const [
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
      ],
    );
  }
}

class AnimalsPage extends StatelessWidget {
  final Function([int]) onReward;

  const AnimalsPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return WordPage(
      title: "Animals 🐾",
      onReward: onReward,
      words: const [
        {"emoji": "🐶", "word": "Dog", "meaning": "سگ"},
        {"emoji": "🐱", "word": "Cat", "meaning": "گربه"},
        {"emoji": "🦁", "word": "Lion", "meaning": "شیر"},
        {"emoji": "🐘", "word": "Elephant", "meaning": "فیل"},
        {"emoji": "🐰", "word": "Rabbit", "meaning": "خرگوش"},
        {"emoji": "🐼", "word": "Panda", "meaning": "پاندا"},
        {"emoji": "🐵", "word": "Monkey", "meaning": "میمون"},
        {"emoji": "🦋", "word": "Butterfly", "meaning": "پروانه"},
      ],
    );
  }
}

class FamilyPage extends StatelessWidget {
  final Function([int]) onReward;

  const FamilyPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return WordPage(
      title: "Family 👨‍👩‍👧",
      onReward: onReward,
      words: const [
        {"emoji": "👩", "word": "Mom", "meaning": "مامان"},
        {"emoji": "👨", "word": "Dad", "meaning": "بابا"},
        {"emoji": "👧", "word": "Girl", "meaning": "دختر"},
        {"emoji": "👦", "word": "Boy", "meaning": "پسر"},
        {"emoji": "👶", "word": "Baby", "meaning": "نوزاد"},
        {"emoji": "❤️", "word": "Family", "meaning": "خانواده"},
      ],
    );
  }
}

class GreetingsPage extends StatelessWidget {
  final Function([int]) onReward;

  const GreetingsPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return WordPage(
      title: "Greetings 👋",
      onReward: onReward,
      words: const [
        {"emoji": "👋", "word": "Hello", "meaning": "سلام"},
        {"emoji": "🌞", "word": "Good morning", "meaning": "صبح بخیر"},
        {"emoji": "😊", "word": "How are you?", "meaning": "حالت چطوره؟"},
        {"emoji": "❤️", "word": "I am happy", "meaning": "من خوشحالم"},
        {"emoji": "👋", "word": "Goodbye", "meaning": "خداحافظ"},
      ],
    );
  }
}

class AlphabetPage extends StatelessWidget {
  final Function([int]) onReward;

  const AlphabetPage({super.key, required this.onReward});

  static const letters = [
    ["A", "Apple", "🍎"],
    ["B", "Ball", "⚽"],
    ["C", "Cat", "🐱"],
    ["D", "Dog", "🐶"],
    ["E", "Elephant", "🐘"],
    ["F", "Fish", "🐟"],
    ["G", "Grapes", "🍇"],
    ["H", "Hat", "🎩"],
    ["I", "Ice cream", "🍦"],
    ["J", "Juice", "🧃"],
    ["K", "Kite", "🪁"],
    ["L", "Lion", "🦁"],
    ["M", "Moon", "🌙"],
    ["N", "Nose", "👃"],
    ["O", "Orange", "🍊"],
    ["P", "Panda", "🐼"],
    ["Q", "Queen", "👑"],
    ["R", "Rabbit", "🐰"],
    ["S", "Sun", "☀️"],
    ["T", "Tiger", "🐯"],
    ["U", "Umbrella", "☂️"],
    ["V", "Van", "🚐"],
    ["W", "Water", "💧"],
    ["X", "Xylophone", "🎵"],
    ["Y", "Yellow", "💛"],
    ["Z", "Zebra", "🦓"],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alphabet 🔤"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: letters.length,
        itemBuilder: (_, i) {
          final l = letters[i];

          return Card(
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Voice.speak("${l[0]}. ${l[1]}");
                onReward();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l[2],
                    style: const TextStyle(fontSize: 38),
                  ),
                  Text(
                    "${l[0]} / ${l[0].toLowerCase()}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l[1],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Icon(Icons.volume_up),
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
  final Function([int]) onReward;

  const SpellingPage({super.key, required this.onReward});

  @override
  State<SpellingPage> createState() => _SpellingPageState();
}

class _SpellingPageState extends State<SpellingPage> {
  final words = [
    ["CAT", "🐱"],
    ["DOG", "🐶"],
    ["SUN", "☀️"],
    ["PEN", "🖊️"],
    ["BUS", "🚌"],
    ["CUP", "🥤"],
  ];

  int index = 0;
  String answer = "";

  void addLetter(String letter) {
    if (answer.length < words[index][0].length) {
      setState(() => answer += letter);

      if (answer == words[index][0]) {
        widget.onReward(2);
        Voice.speak("Great job! ${words[index][0]}");

        Future.delayed(
          const Duration(milliseconds: 900),
          () {
            if (!mounted) return;
            setState(() {
              index = (index + 1) % words.length;
              answer = "";
            });
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = words[index][0];
    final letters = word.split('');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spelling ✍️"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Spell this word!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              words[index][1],
              style: const TextStyle(fontSize: 70),
            ),
            IconButton(
              iconSize: 40,
              onPressed: () => Voice.speak(word),
              icon: const Icon(Icons.volume_up),
            ),
            const SizedBox(height: 12),
            Text(
              answer.isEmpty ? "?" : answer,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: letters
                  .map(
                    (l) => ElevatedButton(
                      onPressed: () => addLetter(l),
                      child: Text(
                        l,
                        style: const TextStyle(fontSize: 23),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 25),
            Text(
              "Letters: ${letters.join("  ")}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class GamesPage extends StatelessWidget {
  final Function([int]) onReward;

  const GamesPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games 🎮"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _game(
              context,
              "🎨",
              "Color Game",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ColorGame(onReward: onReward),
                ),
              ),
            ),
            _game(
              context,
              "🔤",
              "Letter Game",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LetterGame(onReward: onReward),
                ),
              ),
            ),
            _game(
              context,
              "✍️",
              "Spelling",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpellingPage(onReward: onReward),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _game(
    BuildContext context,
    String emoji,
    String title,
    VoidCallback tap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Text(
          emoji,
          style: const TextStyle(fontSize: 42),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.play_arrow),
        onTap: tap,
      ),
    );
  }
}

class ColorGame extends StatefulWidget {
  final Function([int]) onReward;

  const ColorGame({super.key, required this.onReward});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  final colors = [
    ["Red", "🔴"],
    ["Blue", "🔵"],
    ["Green", "🟢"],
    ["Yellow", "🟡"],
  ];

  int target = 0;
  int score = 0;

  void choose(int i) {
    if (i == target) {
      widget.onReward();
      setState(() {
        score++;
        target = (target + 1) % colors.length;
      });
      Voice.speak("Great job!");
    } else {
      Voice.speak("Try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Color Game 🎨")),
      body: Column(
        children: [
          const SizedBox(height: 25),
          const Text(
            "Find this color:",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            colors[target][0],
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Voice.speak(colors[target][0]),
            icon: const Icon(Icons.volume_up),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: List.generate(
                colors.length,
                (i) => Card(
                  child: InkWell(
                    onTap: () => choose(i),
                    child: Center(
                      child: Text(
                        colors[i][1],
                        style: const TextStyle(fontSize: 75),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LetterGame extends StatefulWidget {
  final Function([int]) onReward;

  const LetterGame({super.key, required this.onReward});

  @override
  State<LetterGame> createState() => _LetterGameState();
}

class _LetterGameState extends State<LetterGame> {
  final options = ["A", "B", "C", "D"];
  String target = "A";

  void choose(String letter) {
    if (letter == target) {
      widget.onReward();
      Voice.speak("Correct! Great job!");
      setState(() {
        target = options[(options.indexOf(target) + 1) % options.length];
      });
    } else {
      Voice.speak("Try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Letter Game 🔤")),
      body: Column(
        children: [
          const SizedBox(height: 35),
          const Text(
            "Find the letter",
            style: TextStyle(fontSize: 23),
          ),
          Text(
            target,
            style: const TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            iconSize: 40,
            onPressed: () => Voice.speak(target),
            icon: const Icon(Icons.volume_up),
          ),
          const SizedBox(height: 25),
          ...options.map(
            (letter) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 5,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => choose(letter),
                  child: Text(
                    letter,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryPage extends StatelessWidget {
  final Function([int]) onReward;

  const StoryPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Story World 📖")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Text(
                  "🌈 Adina and the Rainbow",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Adina sees a beautiful rainbow. "
                  "She says: Hello, rainbow! "
                  "The rainbow has red, blue, green and yellow colors. "
                  "Adina smiles and says: I love English!",
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Voice.speak(
                      "Adina sees a beautiful rainbow. "
                      "She says hello rainbow. "
                      "The rainbow has red, blue, green and yellow colors. "
                      "Adina smiles and says I love English!",
                    );
                    onReward();
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Listen to Story"),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Voice.speak(
                    "Adina sees a beautiful rainbow.",
                    repeat: true,
                  ),
                  icon: const Icon(Icons.repeat),
                  label: const Text("Repeat slowly"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SongsPage extends StatelessWidget {
  final Function([int]) onReward;

  const SongsPage({super.key, required this.onReward});

  @override
  Widget build(BuildContext context) {
    final songs = [
      [
        "🔤",
        "ABC Song",
        "A B C D E F G, H I J K L M N O P"
      ],
      [
        "🔢",
        "Numbers Song",
        "One two three four five, six seven eight nine ten"
      ],
      [
        "🎨",
        "Colors Song",
        "Red blue green yellow, colors are so beautiful"
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Songs 🎵")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Text(
                songs[i][0],
                style: const TextStyle(fontSize: 40),
              ),
              title: Text(
                songs[i][1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 40,
                ),
                onPressed: () {
                  Voice.speak(songs[i][2]);
                  onReward();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
