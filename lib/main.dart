import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppProgress {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int get stars => _prefs?.getInt('stars') ?? 12;
  static int get xp => _prefs?.getInt('xp') ?? 35;
  static int get streak => _prefs?.getInt('streak') ?? 0;

  static Future<void> setStars(int value) async {
    await _prefs?.setInt('stars', value);
  }

  static Future<void> setXp(int value) async {
    await _prefs?.setInt('xp', value);
  }

  static Future<void> setStreak(int value) async {
    await _prefs?.setInt('streak', value);
  }

  static Future<void> addReward(int amount) async {
    await setStars(stars + amount);
    await setXp(xp + amount * 5);
  }

  static List<String> get learnedWords =>
      _prefs?.getStringList('learned_words') ?? [];

  static Future<void> markWordLearned(String word) async {
    final words = learnedWords.toSet();
    words.add(word);
    await _prefs?.setStringList('learned_words', words.toList());
  }

  // Smart Leitner review system
  static int getWordLevel(String word) {
    return _prefs?.getInt('leitner_$word') ?? 1;
  }

  static Future<void> setWordLevel(String word, int level) async {
    final safeLevel = level.clamp(1, 5);
    await _prefs?.setInt('leitner_$word', safeLevel);
  }

  static Future<void> markWordEasy(String word) async {
    final level = getWordLevel(word);
    await setWordLevel(word, level + 1);
    await markWordLearned(word);
  }

  static Future<void> markWordHard(String word) async {
    await setWordLevel(word, 1);
    await markWordLearned(word);
  }

  static List<String> get reviewWords {
    return learnedWords.where((word) {
      return getWordLevel(word) < 5;
    }).toList();
  }

  static bool isWordLearned(String word) =>
      learnedWords.contains(word);

  static String get lastActiveDate =>
      _prefs?.getString('last_active_date') ?? '';

  static int get dailyProgress =>
      _prefs?.getInt('daily_progress') ?? 0;

  static Future<void> recordDailyActivity() async {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month}-${today.day}';

    final last = lastActiveDate;

    if (last != todayKey) {
      int newStreak = streak;

      if (last.isNotEmpty) {
        final previous = DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(const Duration(days: 1));

        final previousKey =
            '${previous.year}-${previous.month}-${previous.day}';

        if (last == previousKey) {
          newStreak++;
        } else {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      await setStreak(newStreak);
      await _prefs?.setString('last_active_date', todayKey);
      await _prefs?.setInt('daily_progress', 0); await _prefs?.setBool('daily_reward_claimed', false);
    }
  }

  static const int dailyGoal = 3;

  static bool get dailyMissionComplete =>
      dailyProgress >= dailyGoal;

  static Future<void> completeDailyMission() async {
    if (!dailyMissionComplete) return;

    final claimed = _prefs?.getBool('daily_reward_claimed') ?? false;
    if (claimed) return;

    await addReward(5);
    await _prefs?.setBool('daily_reward_claimed', true);
  }

  static Future<void> addDailyProgress() async {
    await _prefs?.setInt(
      'daily_progress',
      dailyProgress + 1,
    );
  }

  static Future<void> saveStoryPosition(
      String storyId, int position) async {
    await _prefs?.setInt('story_$storyId', position);
  }

  static int getStoryPosition(String storyId) {
    return _prefs?.getInt('story_$storyId') ?? 0;
  }

  static Future<void> markLearned(String itemId) async {
    final items = _prefs?.getStringList('learned_items') ?? [];
    if (!items.contains(itemId)) {
      items.add(itemId);
      await _prefs?.setStringList('learned_items', items);
    }
  }

  static bool isLearned(String itemId) {
    final items = _prefs?.getStringList('learned_items') ?? [];
    return items.contains(itemId);
  }
}

Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await AppProgress.init(); await AppProgress.recordDailyActivity(); runApp(const AdinaApp()); }

class Voice {
  static final FlutterTts tts = FlutterTts();

  static Future<void> speak(String text, {bool repeat = false}) async {
    await tts.stop();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(repeat ? 0.32 : 0.42);
    await tts.setPitch(1.08);
    await tts.speak(text);
  }

  static Future<void> stop() async {
    await tts.stop();
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
  int stars = AppProgress.stars;
  int xp = AppProgress.xp;

  Future<void> reward(int amount) async {
    setState(() {
      stars += amount;
      AppProgress.setStars(stars);
      xp += amount * 5;
      AppProgress.setXp(xp);
    });

    await AppProgress.addDailyProgress();
    await AppProgress.completeDailyMission();
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
                      icon: "🎯",
                      title: "Daily Lesson",
                      subtitle: "Today's Mission",
                      onTap: () => open(
                        DailyLessonPage(onReward: reward),
                      ),
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
                      icon: "🗣️",
                      title: "Speaking",
                      subtitle: "Listen & Speak",
                      onTap: () => open(const SpeakingPage()),
                    ),
                    MenuCard(
                      icon: "🧠",
                      title: "Smart Review",
                      subtitle: "Practice Words",
                      onTap: () => open(
                        SmartReviewPage(onReward: reward),
                      ),
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



class DailyLessonPage extends StatelessWidget {
  final Function(int) onReward;

  const DailyLessonPage({
    super.key,
    required this.onReward,
  });

  @override
  Widget build(BuildContext context) {
    final progress = AppProgress.dailyProgress;
    final goal = AppProgress.dailyGoal;
    final percent = (progress / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Daily Lesson"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      "Today's Little Mission 🌈",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Just a few minutes of fun learning!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 12,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$progress / $goal activities",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            DailyLessonCard(
              icon: "📚",
              title: "Learn a Word",
              subtitle: "Learn something new",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearnPage(
                      onReward: onReward,
                    ),
                  ),
                );
              },
            ),

            DailyLessonCard(
              icon: "🧠",
              title: "Smart Review",
              subtitle: "Practice words you know",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SmartReviewPage(
                      onReward: onReward,
                    ),
                  ),
                );
              },
            ),

            DailyLessonCard(
              icon: "🎮",
              title: "Play a Game",
              subtitle: "Learn while having fun",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamesPage(
                      onReward: onReward,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            if (AppProgress.dailyMissionComplete)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "🎉 Great job, Adina!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Today's mission is complete! ⭐",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DailyLessonCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DailyLessonCard({
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 38),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class SmartReviewPage extends StatefulWidget {
  final Function(int) onReward;

  const SmartReviewPage({
    super.key,
    required this.onReward,
  });

  @override
  State<SmartReviewPage> createState() => _SmartReviewPageState();
}

class _SmartReviewPageState extends State<SmartReviewPage> {
  int currentIndex = 0;

  final Map<String, String> meanings = const {
    "One": "یک",
    "Two": "دو",
    "Three": "سه",
    "Four": "چهار",
    "Five": "پنج",
    "Six": "شش",
    "Seven": "هفت",
    "Eight": "هشت",
    "Nine": "نه",
    "Ten": "ده",
    "Eleven": "یازده",
    "Twelve": "دوازده",
    "Thirteen": "سیزده",
    "Fourteen": "چهارده",
    "Fifteen": "پانزده",
    "Sixteen": "شانزده",
    "Seventeen": "هفده",
    "Eighteen": "هجده",
    "Nineteen": "نوزده",
    "Twenty": "بیست",
    "Twenty-one": "بیست و یک",
    "Twenty-two": "بیست و دو",
    "Twenty-three": "بیست و سه",
    "Twenty-four": "بیست و چهار",
    "Twenty-five": "بیست و پنج",
    "Twenty-six": "بیست و شش",
    "Twenty-seven": "بیست و هفت",
    "Twenty-eight": "بیست و هشت",
    "Twenty-nine": "بیست و نه",
    "Thirty": "سی",
    "Thirty-one": "سی و یک",
    "Thirty-two": "سی و دو",
    "Thirty-three": "سی و سه",
    "Thirty-four": "سی و چهار",
    "Thirty-five": "سی و پنج",
    "Thirty-six": "سی و شش",
    "Thirty-seven": "سی و هفت",
    "Thirty-eight": "سی و هشت",
    "Thirty-nine": "سی و نه",
    "Forty": "چهل",
    "Forty-one": "چهل و یک",
    "Forty-two": "چهل و دو",
    "Forty-three": "چهل و سه",
    "Forty-four": "چهل و چهار",
    "Forty-five": "چهل و پنج",
    "Forty-six": "چهل و شش",
    "Forty-seven": "چهل و هفت",
    "Forty-eight": "چهل و هشت",
    "Forty-nine": "چهل و نه",
    "Fifty": "پنجاه",
    "Red": "قرمز",
    "Blue": "آبی",
    "Green": "سبز",
    "Yellow": "زرد",
    "Dog": "سگ",
    "Cat": "گربه",
    "Lion": "شیر",
    "Elephant": "فیل",
    "Horse": "اسب",
    "Bird": "پرنده",
    "Fish": "ماهی",
    "Monkey": "میمون",
    "Mom": "مامان",
    "Dad": "بابا",
    "Baby": "نوزاد",
    "Family": "خانواده",
    "Hello": "سلام",
    "Bye": "خداحافظ",
    "Good morning": "صبح بخیر",
    "Good night": "شب بخیر",
  };

  List<String> get words => AppProgress.reviewWords;

  String get currentWord {
    if (words.isEmpty) return "";
    return words[currentIndex % words.length];
  }

  void nextWord() {
    if (words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % words.length;
    });
  }

  Future<void> answer(bool easy) async {
    if (words.isEmpty) return;

    final word = currentWord;

    if (easy) {
      await AppProgress.markWordEasy(word);
      widget.onReward(1);
    } else {
      await AppProgress.markWordHard(word);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("🧠 Smart Review")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🎉",
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Great job, Adina!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "No words need review right now.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final word = currentWord;
    final meaning = meanings[word] ?? "آفرین ادینا! 🌟";

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Smart Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Word ${currentIndex + 1} of ${words.length}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            Expanded(
              child: Card(
                elevation: 8,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "🧠",
                          style: TextStyle(fontSize: 70),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          meaning,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 20),
                        IconButton(
                          iconSize: 48,
                          onPressed: () => Voice.speak(
                            word,
                            repeat: true,
                          ),
                          icon: const Icon(Icons.volume_up),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Level ${AppProgress.getWordLevel(word)} / 5",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await answer(false);
                      nextWord();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("سخت بود 😕"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await answer(true);
                      nextWord();
                    },
                    icon: const Icon(Icons.star),
                    label: const Text("بلدم ⭐"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class FlashCard extends StatefulWidget {
  final String title;
  final String emoji;
  final String meaning;
  final Function(int) onReward;

  const FlashCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.meaning,
    required this.onReward,
  });

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  bool flipped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🃏 Flash Card")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => flipped = !flipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Card(
                    key: ValueKey(flipped),
                    elevation: 8,
                    child: Container(
                      width: double.infinity,
                      height: 330,
                      padding: const EdgeInsets.all(24),
                      child: flipped
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "I know it! 🌟",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  widget.meaning,
                                  style: const TextStyle(
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                IconButton(
                                  iconSize: 42,
                                  onPressed: () =>
                                      Voice.speak(widget.title),
                                  icon: const Icon(Icons.volume_up),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.emoji,
                                  style: const TextStyle(fontSize: 90),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  "Tap to flip 👆",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  await AppProgress.markWordLearned(widget.title);
                  widget.onReward(1);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Amazing! ⭐ +1"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.star),
                label: const Text("I learned it!"),
              ),
            ],
          ),
        ),
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

  String get meaning {
    const meanings = {
      "One": "یک",
      "Two": "دو",
      "Three": "سه",
      "Four": "چهار",
      "Five": "پنج",
      "Six": "شش",
      "Seven": "هفت",
      "Eight": "هشت",
      "Nine": "نه",
      "Ten": "ده",
      "Eleven": "یازده",
      "Twelve": "دوازده",
      "Thirteen": "سیزده",
      "Fourteen": "چهارده",
      "Fifteen": "پانزده",
      "Sixteen": "شانزده",
      "Seventeen": "هفده",
      "Eighteen": "هجده",
      "Nineteen": "نوزده",
      "Twenty": "بیست",
      "Twenty-one": "بیست و یک",
      "Twenty-two": "بیست و دو",
      "Twenty-three": "بیست و سه",
      "Twenty-four": "بیست و چهار",
      "Twenty-five": "بیست و پنج",
      "Twenty-six": "بیست و شش",
      "Twenty-seven": "بیست و هفت",
      "Twenty-eight": "بیست و هشت",
      "Twenty-nine": "بیست و نه",
      "Thirty": "سی",
      "Thirty-one": "سی و یک",
      "Thirty-two": "سی و دو",
      "Thirty-three": "سی و سه",
      "Thirty-four": "سی و چهار",
      "Thirty-five": "سی و پنج",
      "Thirty-six": "سی و شش",
      "Thirty-seven": "سی و هفت",
      "Thirty-eight": "سی و هشت",
      "Thirty-nine": "سی و نه",
      "Forty": "چهل",
      "Forty-one": "چهل و یک",
      "Forty-two": "چهل و دو",
      "Forty-three": "چهل و سه",
      "Forty-four": "چهل و چهار",
      "Forty-five": "چهل و پنج",
      "Forty-six": "چهل و شش",
      "Forty-seven": "چهل و هفت",
      "Forty-eight": "چهل و هشت",
      "Forty-nine": "چهل و نه",
      "Fifty": "پنجاه",
      "Red": "قرمز",
      "Blue": "آبی",
      "Green": "سبز",
      "Yellow": "زرد",
      "Dog": "سگ",
      "Cat": "گربه",
      "Lion": "شیر",
      "Elephant": "فیل",
      "Mom": "مامان",
      "Dad": "بابا",
      "Baby": "نوزاد",
      "Family": "خانواده",
      "Hello": "سلام",
      "Bye": "خداحافظ",
      "Good morning": "صبح بخیر",
      "Good night": "شب بخیر",
      "How are you?": "حالت چطوره؟",
    };

    return meanings[title] ?? "آفرین ادینا! 🌟";
  }

  @override
  Widget build(BuildContext context) {
    return FlashCard(
      title: title,
      emoji: emoji,
      meaning: meaning,
      onReward: onReward,
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
    "One", "Two", "Three", "Four", "Five",
    "Six", "Seven", "Eight", "Nine", "Ten",
    "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen",
    "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty",
    "Twenty-one", "Twenty-two", "Twenty-three", "Twenty-four", "Twenty-five",
    "Twenty-six", "Twenty-seven", "Twenty-eight", "Twenty-nine", "Thirty",
    "Thirty-one", "Thirty-two", "Thirty-three", "Thirty-four", "Thirty-five",
    "Thirty-six", "Thirty-seven", "Thirty-eight", "Thirty-nine", "Forty",
    "Forty-one", "Forty-two", "Forty-three", "Forty-four", "Forty-five",
    "Forty-six", "Forty-seven", "Forty-eight", "Forty-nine", "Fifty",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔢 Numbers 1–50")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: numbers.length,
        itemBuilder: (_, i) {
          final number = i + 1;

          return WordPageCard(
            title: numbers[i],
            emoji: "$number",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WordPage(
                  title: numbers[i],
                  emoji: "$number",
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

class StoryScene {
  final String image;
  final String english;
  final String persian;

  const StoryScene({
    required this.image,
    required this.english,
    required this.persian,
  });
}

class StoryBook {
  final String id;
  final String title;
  final String persianTitle;
  final List<StoryScene> scenes;

  const StoryBook({
    required this.id,
    required this.title,
    required this.persianTitle,
    required this.scenes,
  });
}

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  static const stories = [
    StoryBook(
      id: "adina_rainbow",
      title: "Adina and the Rainbow",
      persianTitle: "ادینا و رنگین‌کمان",
      scenes: [
        StoryScene(
          image: "🌈",
          english: "Adina looked at the bright sky.",
          persian: "ادینا به آسمان روشن نگاه کرد.",
        ),
        StoryScene(
          image: "👧🌈",
          english: "A beautiful rainbow appeared.",
          persian: "یک رنگین‌کمان زیبا ظاهر شد.",
        ),
        StoryScene(
          image: "👧",
          english: "Hello, Rainbow!",
          persian: "سلام، رنگین‌کمان!",
        ),
        StoryScene(
          image: "🌈✨",
          english: "Hello, Adina! Let's learn together.",
          persian: "سلام ادینا! بیا با هم یاد بگیریم.",
        ),
        StoryScene(
          image: "🔴🔵🟢🟡",
          english: "Red, blue, green and yellow!",
          persian: "قرمز، آبی، سبز و زرد!",
        ),
        StoryScene(
          image: "⭐",
          english: "Learning is a wonderful adventure!",
          persian: "یادگیری یک ماجراجویی فوق‌العاده است!",
        ),
      ],
    ),

    StoryBook(
      id: "wolf_lamb",
      title: "The Wolf and the Lamb",
      persianTitle: "گرگ و بره",
      scenes: [
        StoryScene(
          image: "🐺🌳",
          english: "A young wolf walked near the river.",
          persian: "یک گرگ جوان کنار رودخانه قدم می‌زد.",
        ),
        StoryScene(
          image: "🐑💧",
          english: "A little lamb was drinking water.",
          persian: "یک بره کوچک داشت آب می‌نوشید.",
        ),
        StoryScene(
          image: "🐺",
          english: "The wolf wanted to frighten the lamb.",
          persian: "گرگ می‌خواست بره را بترساند.",
        ),
        StoryScene(
          image: "🐑💡",
          english: "The little lamb stayed calm and spoke kindly.",
          persian: "بره کوچک آرام ماند و با مهربانی صحبت کرد.",
        ),
        StoryScene(
          image: "🤝",
          english: "The wolf stopped and listened.",
          persian: "گرگ ایستاد و گوش داد.",
        ),
        StoryScene(
          image: "🌈🐑🐺",
          english: "Kind words can change a difficult moment.",
          persian: "کلمات مهربان می‌توانند یک لحظه سخت را تغییر دهند.",
        ),
      ],
    ),

    StoryBook(
      id: "pat_mat",
      title: "Pat & Mat",
      persianTitle: "پت و مت",
      scenes: [
        StoryScene(
          image: "🔧👨‍🔧",
          english: "Pat and Mat wanted to fix a little shelf.",
          persian: "پت و مت می‌خواستند یک قفسه کوچک را درست کنند.",
        ),
        StoryScene(
          image: "📏🔨",
          english: "They measured the wood very carefully.",
          persian: "آن‌ها چوب را با دقت اندازه گرفتند.",
        ),
        StoryScene(
          image: "😅🔨",
          english: "Oops! The first piece was too short.",
          persian: "اوه! قطعه اول خیلی کوتاه بود.",
        ),
        StoryScene(
          image: "😂",
          english: "They laughed and tried again.",
          persian: "آن‌ها خندیدند و دوباره تلاش کردند.",
        ),
        StoryScene(
          image: "🪚🔧",
          english: "This time, they worked together.",
          persian: "این بار آن‌ها با هم کار کردند.",
        ),
        StoryScene(
          image: "🏠⭐",
          english: "The little shelf was ready!",
          persian: "قفسه کوچک آماده شد!",
        ),
      ],
    ),

    StoryBook(
      id: "anne_green_gables",
      title: "Anne of Green Gables",
      persianTitle: "آنه شرلی",
      scenes: [
        StoryScene(
          image: "🌿🏡",
          english: "Anne loved her new home in the green countryside.",
          persian: "آنه خانه جدیدش را در طبیعت سرسبز دوست داشت.",
        ),
        StoryScene(
          image: "👧🌸",
          english: "She found beauty in every little flower.",
          persian: "او در هر گل کوچک زیبایی می‌دید.",
        ),
        StoryScene(
          image: "📖✨",
          english: "Anne loved stories and wonderful ideas.",
          persian: "آنه داستان‌ها و ایده‌های شگفت‌انگیز را دوست داشت.",
        ),
        StoryScene(
          image: "🌳☁️",
          english: "She looked at the clouds and imagined new adventures.",
          persian: "او به ابرها نگاه می‌کرد و ماجراهای تازه تصور می‌کرد.",
        ),
        StoryScene(
          image: "👭🌷",
          english: "Anne made a kind new friend.",
          persian: "آنه یک دوست جدید و مهربان پیدا کرد.",
        ),
        StoryScene(
          image: "❤️",
          english: "A happy heart can make any place feel like home.",
          persian: "یک قلب شاد می‌تواند هر جایی را شبیه خانه کند.",
        ),
      ],
    ),

    StoryBook(
      id: "adina_garden",
      title: "Adina and the Little Garden",
      persianTitle: "هایده و باغچه کوچک",
      scenes: [
        StoryScene(
          image: "👧🌱",
          english: "Adina found a tiny garden behind her house.",
          persian: "هایده پشت خانه‌اش یک باغچه کوچک پیدا کرد.",
        ),
        StoryScene(
          image: "🌱💧",
          english: "She gave the little plants some water.",
          persian: "او به گیاهان کوچک کمی آب داد.",
        ),
        StoryScene(
          image: "🌻☀️",
          english: "Every morning, the flowers grew a little more.",
          persian: "هر صبح، گل‌ها کمی بیشتر رشد می‌کردند.",
        ),
        StoryScene(
          image: "🦋🌸",
          english: "One day, a colorful butterfly came to the garden.",
          persian: "یک روز، یک پروانه رنگارنگ به باغچه آمد.",
        ),
        StoryScene(
          image: "😊🌺",
          english: 'Adina smiled and said, "Welcome, little friend!"',
          persian: "هایده لبخند زد و گفت: «خوش آمدی، دوست کوچولو!»",
        ),
        StoryScene(
          image: "🌈🌻",
          english: "Small acts of care can grow into something beautiful.",
          persian: "کارهای کوچکِ مراقبت می‌توانند به چیزی زیبا تبدیل شوند.",
        ),
      ],
    ),

    StoryBook(
      id: "mouse_cat",
      title: "The Mouse and the Cat",
      persianTitle: "موش و گربه",
      scenes: [
        StoryScene(
          image: "🐭🧀",
          english: "A little mouse lived near a warm kitchen.",
          persian: "یک موش کوچک نزدیک یک آشپزخانه گرم زندگی می‌کرد.",
        ),
        StoryScene(
          image: "🐱👀",
          english: "A curious cat lived in the same house.",
          persian: "یک گربه کنجکاو هم در همان خانه زندگی می‌کرد.",
        ),
        StoryScene(
          image: "🐭💨",
          english: "The mouse ran quickly behind a box.",
          persian: "موش سریع پشت یک جعبه دوید.",
        ),
        StoryScene(
          image: "🐱🧀",
          english: "The cat saw the cheese and forgot about the mouse.",
          persian: "گربه پنیر را دید و موش را فراموش کرد.",
        ),
        StoryScene(
          image: "🐭😄",
          english: "The little mouse safely went home.",
          persian: "موش کوچک با خیال راحت به خانه رفت.",
        ),
        StoryScene(
          image: "🏠⭐",
          english: "Sometimes being calm helps us think clearly.",
          persian: "گاهی آرام ماندن به ما کمک می‌کند بهتر فکر کنیم.",
        ),
      ],
    ),

    StoryBook(
      id: "pink_panther",
      title: "The Pink Panther",
      persianTitle: "پلنگ صورتی",
      scenes: [
        StoryScene(
          image: "🩷🐆",
          english: "A quiet pink panther walked through the city.",
          persian: "یک پلنگ صورتی آرام در شهر قدم می‌زد.",
        ),
        StoryScene(
          image: "🎈🩷",
          english: "He saw a little balloon flying away.",
          persian: "او یک بادکنک کوچک را دید که دور می‌شد.",
        ),
        StoryScene(
          image: "🐆💨",
          english: "He followed it down a sunny street.",
          persian: "او در یک خیابان آفتابی آن را دنبال کرد.",
        ),
        StoryScene(
          image: "🎈🌳",
          english: "The balloon stopped in a tree.",
          persian: "بادکنک روی یک درخت متوقف شد.",
        ),
        StoryScene(
          image: "🐆🤲🎈",
          english: "The panther gently helped the balloon come down.",
          persian: "پلنگ با مهربانی کمک کرد بادکنک پایین بیاید.",
        ),
        StoryScene(
          image: "😊🩷",
          english: "Helping someone can make us smile.",
          persian: "کمک کردن به دیگران می‌تواند ما را خوشحال کند.",
        ),
      ],
    ),

    StoryBook(
      id: "little_red",
      title: "Little Red Riding Hood",
      persianTitle: "کلاه قرمزی",
      scenes: [
        StoryScene(
          image: "👧🧺🌲",
          english: "Little Red walked through the forest with a basket.",
          persian: "کلاه قرمزی با یک سبد از جنگل عبور می‌کرد.",
        ),
        StoryScene(
          image: "🌸🦋",
          english: "She stopped to look at beautiful flowers.",
          persian: "او ایستاد تا گل‌های زیبا را تماشا کند.",
        ),
        StoryScene(
          image: "🐺👀",
          english: "A wolf watched her from far away.",
          persian: "یک گرگ از دور او را نگاه می‌کرد.",
        ),
        StoryScene(
          image: "🏡",
          english: "Little Red remembered to stay on the safe path.",
          persian: "کلاه قرمزی یادش ماند که در مسیر امن بماند.",
        ),
        StoryScene(
          image: "👵❤️",
          english: "She reached Grandma's house safely.",
          persian: "او با خیال راحت به خانه مادربزرگ رسید.",
        ),
        StoryScene(
          image: "🌳⭐",
          english: "Listening to good advice keeps us safe.",
          persian: "گوش دادن به توصیه‌های خوب از ما مراقبت می‌کند.",
        ),
      ],
    ),

    StoryBook(
      id: "snow_white",
      title: "Snow White",
      persianTitle: "سفیدبرفی",
      scenes: [
        StoryScene(
          image: "❄️👧",
          english: "Snow White walked into a peaceful forest.",
          persian: "سفیدبرفی وارد یک جنگل آرام شد.",
        ),
        StoryScene(
          image: "🏡🌲",
          english: "She found a tiny house among the trees.",
          persian: "او یک خانه کوچک میان درختان پیدا کرد.",
        ),
        StoryScene(
          image: "🍎",
          english: "She saw a bright red apple on the table.",
          persian: "او یک سیب قرمز زیبا روی میز دید.",
        ),
        StoryScene(
          image: "🛏️✨",
          english: "Snow White rested in the little house.",
          persian: "سفیدبرفی در خانه کوچک استراحت کرد.",
        ),
        StoryScene(
          image: "🌲🐦☀️",
          english: "The forest became bright and peaceful again.",
          persian: "جنگل دوباره روشن و آرام شد.",
        ),
        StoryScene(
          image: "❤️⭐",
          english: "Kindness and friendship make life brighter.",
          persian: "مهربانی و دوستی زندگی را روشن‌تر می‌کنند.",
        ),
      ],
    ),
  ]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📖 Stories"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Text(
                story.scenes.first.image,
                style: const TextStyle(fontSize: 42),
              ),
              title: Text(
                story.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${story.persianTitle}\n${story.scenes.length} scenes",
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryReaderPage(story: story),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class StoryReaderPage extends StatefulWidget {
  final StoryBook story;

  const StoryReaderPage({
    super.key,
    required this.story,
  });

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  int sceneIndex = 0;
  int sentenceIndex = 0;
  bool playing = false;
  bool slowMode = false;

  StoryScene get scene => widget.story.scenes[sceneIndex];

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final saved = AppProgress.getStoryPosition(widget.story.id);

    final savedScene = saved ~/ 100;
    final savedSentence = saved % 100;

    if (savedScene >= 0 &&
        savedScene < widget.story.scenes.length) {
      setState(() {
        sceneIndex = savedScene;
        sentenceIndex = savedSentence;
      });
    }
  }

  Future<void> _savePosition() async {
    await AppProgress.saveStoryPosition(
      widget.story.id,
      (sceneIndex * 100) + sentenceIndex,
    );
  }

  Future<void> _speakCurrent() async {
    await Voice.stop();

    setState(() => playing = true);

    await Voice.speak(
      scene.english,
      repeat: slowMode,
    );

    if (!mounted) return;

    setState(() => playing = false);
  }

  Future<void> _stopStory() async {
    await Voice.stop();

    if (!mounted) return;

    setState(() => playing = false);
    await _savePosition();
  }

  Future<void> _repeatSentence() async {
    await Voice.stop();

    setState(() => playing = true);

    await Voice.speak(
      scene.english,
      repeat: true,
    );

    if (!mounted) return;

    setState(() => playing = false);
  }

  Future<void> _nextSentence() async {
    await Voice.stop();

    if (sentenceIndex < 0) {
      sentenceIndex = 0;
    }

    setState(() {
      playing = false;
    });

    await _savePosition();
  }

  Future<void> _nextScene() async {
    await Voice.stop();

    if (sceneIndex < widget.story.scenes.length - 1) {
      setState(() {
        sceneIndex++;
        sentenceIndex = 0;
        playing = false;
      });

      await _savePosition();
    } else {
      await AppProgress.addReward(2);

      if (mounted) {
        setState(() => playing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Story complete! ⭐ +2"),
          ),
        );
      }
    }
  }

  Future<void> _previousScene() async {
    await Voice.stop();

    if (sceneIndex > 0) {
      setState(() {
        sceneIndex--;
        sentenceIndex = 0;
        playing = false;
      });

      await _savePosition();
    }
  }

  Future<void> _toggleSlowMode() async {
    await Voice.stop();

    setState(() {
      slowMode = !slowMode;
      playing = false;
    });
  }

  @override
  void dispose() {
    Voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.story.scenes.length;
    final progress = (sceneIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          IconButton(
            tooltip: "Slow mode",
            onPressed: _toggleSlowMode,
            icon: Icon(
              slowMode
                  ? Icons.speed
                  : Icons.slow_motion_video,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scene ${sceneIndex + 1} / $total",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  slowMode
                      ? "🐢 Slow"
                      : "⚡ Normal",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        scene.image,
                        style:
                            const TextStyle(fontSize: 86),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        scene.english,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        scene.persian,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 58,
                            tooltip: "Play",
                            onPressed: playing
                                ? _stopStory
                                : _speakCurrent,
                            icon: Icon(
                              playing
                                  ? Icons.stop_circle
                                  : Icons.play_circle_fill,
                            ),
                          ),

                          const SizedBox(width: 18),

                          IconButton(
                            iconSize: 42,
                            tooltip: "Repeat",
                            onPressed: _repeatSentence,
                            icon: const Icon(
                              Icons.replay_circle_filled,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        playing
                            ? "Listening..."
                            : "Tap ▶ to listen",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: sceneIndex > 0
                        ? _previousScene
                        : null,
                    icon:
                        const Icon(Icons.arrow_back),
                    label:
                        const Text("Previous"),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: _nextScene,
                    icon:
                        const Icon(Icons.arrow_forward),
                    label:
                        const Text("Next"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "💾 Your place is saved automatically",
              style: TextStyle(fontSize: 13),
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
    await Voice.speak(text, repeat: true);
  }

  @override
  Widget build(BuildContext context) {
    final songs = [
      {
        "title": "ABC Song",
        "emoji": "🔤",
        "text": "A B C D E F G, H I J K L M N O P, Q R S, T U V, W X Y and Z!"
      },
      {
        "title": "Numbers Song",
        "emoji": "🔢",
        "text": "One two three four five, six seven eight nine ten!"
      },
      {
        "title": "Colors Song",
        "emoji": "🎨",
        "text": "Red, blue, green, yellow, orange, purple, pink!"
      },
      {
        "title": "Animals Song",
        "emoji": "🐶",
        "text": "Dog says woof, cat says meow, bird can fly and cow says moo!"
      },
      {
        "title": "My Family",
        "emoji": "👨‍👩‍👧",
        "text": "Mom and Dad, sister and brother, we love each other!"
      },
      {
        "title": "Hello, My Father",
        "emoji": "👨‍👧",
        "text": "Hello, hello, my father! Hello, hello, my friend! We smile and play together, our happy day begins!"
      },
      {
        "title": "Hello, My Mother",
        "emoji": "👩‍👧",
        "text": "Hello, hello, my mother! Hello, hello, my friend! We smile and play together, our happy day begins!"
      },
      {
        "title": "I Love My Family",
        "emoji": "❤️",
        "text": "I love my family, yes I do! Mom and Dad, I love you! We laugh and play, all day long, together we are happy and strong!"
      },
      {
        "title": "Hello and Goodbye",
        "emoji": "👋",
        "text": "Hello, hello, how are you? Goodbye, goodbye, see you soon!"
      },
      {
        "title": "Good Morning",
        "emoji": "🌞",
        "text": "Good morning, good morning, wake up and smile! Good morning, everyone, let's play for a while!"
      },
      {
        "title": "Good Night",
        "emoji": "🌙",
        "text": "Good night, good night, sleep tight! Sweet dreams and stars tonight!"
      },
      {
        "title": "Clean Up Song",
        "emoji": "🧸",
        "text": "Clean up, clean up, put your toys away! Clean up, clean up, what a happy day!"
      },
      {
        "title": "My Body",
        "emoji": "🧍",
        "text": "Head, shoulders, hands and feet, eyes and ears, move to the beat!"
      },
      {
        "title": "Food Song",
        "emoji": "🍎",
        "text": "Apple, banana, milk and bread, yummy food helps me grow!"
      },
      {
        "title": "Move and Dance",
        "emoji": "💃",
        "text": "Jump, jump, jump! Clap, clap, clap! Turn around and tap, tap, tap!"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Songs"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Text(
                songs[i]["emoji"]!,
                style: const TextStyle(fontSize: 35),
              ),
              title: Text(
                songs[i]["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text(
                "Tap to listen 🎧",
                style: TextStyle(fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_fill),
                iconSize: 40,
                onPressed: () => sing(songs[i]["text"]!),
              ),
            ),
          );
        },
      ),
    );
  }
}


class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  final words = [
    {"word": "Hello", "meaning": "سلام", "emoji": "👋"},
    {"word": "Good morning", "meaning": "صبح بخیر", "emoji": "🌞"},
    {"word": "Mom", "meaning": "مامان", "emoji": "👩"},
    {"word": "Dad", "meaning": "بابا", "emoji": "👨"},
    {"word": "Dog", "meaning": "سگ", "emoji": "🐶"},
    {"word": "Cat", "meaning": "گربه", "emoji": "🐱"},
    {"word": "Red", "meaning": "قرمز", "emoji": "🔴"},
    {"word": "Blue", "meaning": "آبی", "emoji": "🔵"},
    {"word": "Green", "meaning": "سبز", "emoji": "🟢"},
    {"word": "One", "meaning": "یک", "emoji": "1️⃣"},
  ];

  int current = 0;
  bool practiced = false;

  Future<void> listen() async {
    await Voice.speak(words[current]["word"]!);
  }

  void nextWord() {
    setState(() {
      current = (current + 1) % words.length;
      practiced = false;
    });
  }

  Future<void> practice() async {
    setState(() {
      practiced = true;
    });

    await AppProgress.addReward(1);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⭐ Great job! Keep speaking!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = words[current];

    return Scaffold(
      appBar: AppBar(
        title: const Text("🗣️ Speaking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Listen and speak!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Text(
                      item["emoji"]!,
                      style: const TextStyle(fontSize: 70),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      item["word"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["meaning"]!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: listen,
                      icon: const Icon(Icons.volume_up),
                      label: const Text("Listen"),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: practiced ? null : practice,
                icon: const Icon(Icons.mic),
                label: Text(
                  practiced ? "Great! ⭐" : "I can say it!",
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: nextWord,
              child: const Text("Next word →"),
            ),
          ],
        ),
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
            ProgressCard(
              icon: "📚",
              title: "Words Learned",
              value: "${AppProgress.learnedWords.length}",
            ),
            ProgressCard(
              icon: "🔥",
              title: "Learning Streak",
              value: "${AppProgress.streak} days",
            ),
            ProgressCard(
              icon: "🎯",
              title: "Daily Mission",
              value: "${AppProgress.dailyProgress}/${AppProgress.dailyGoal}",
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
