import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

void main() {
  runApp(const SonicAI());
}

class SonicAI extends StatelessWidget {
  const SonicAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SonicAI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF090A10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
      ),
      home: const RecorderPage(),
    );
  }
}

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Amplitude>? _amplitudeSubscription;

  bool _isRecording = false;
  bool _isPaused = false;

  String? _lastFilePath;
  Duration _duration = Duration.zero;
  Timer? _timer;

  final List<double> _waveform = List.filled(45, 0.08);

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<String> _createRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordings = Directory('${directory.path}/recordings');

    if (!await recordings.exists()) {
      await recordings.create(recursive: true);
    }

    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-');

    return '${recordings.path}/recording_$timestamp.wav';
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        _showMessage('دسترسی میکروفون فعال نیست.');
        return;
      }

      final path = await _createRecordingPath();

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
        autoGain: false,
        echoCancel: true,
        noiseSuppress: true,
      );

      await _recorder.start(config, path: path);

      _duration = Duration.zero;
      _lastFilePath = null;

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_isRecording && !_isPaused) {
          setState(() {
            _duration += const Duration(seconds: 1);
          });
        }
      });

      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amplitude) {
        if (!mounted) return;

        final value = ((amplitude.current + 60) / 60)
            .clamp(0.05, 1.0)
            .toDouble();

        setState(() {
          _waveform.removeAt(0);
          _waveform.add(value);
        });
      });

      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
    } catch (e) {
      _showMessage('خطا در شروع ضبط');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder.pause();

      setState(() {
        _isPaused = true;
      });
    } catch (_) {}
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder.resume();

      setState(() {
        _isPaused = false;
      });
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      _timer?.cancel();
      _amplitudeSubscription?.cancel();

      if (path != null) {
        setState(() {
          _lastFilePath = path;
          _isRecording = false;
          _isPaused = false;
        });

        _showMessage('ضبط با موفقیت ذخیره شد');
      }
    } catch (_) {
      _showMessage('خطا در ذخیره ضبط');
    }
  }

  Future<void> _playRecording() async {
    if (_lastFilePath == null) return;

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(_lastFilePath!));
    } catch (_) {
      _showMessage('خطا در پخش فایل');
    }
  }

  Future<void> _deleteRecording() async {
    if (_lastFilePath == null) return;

    try {
      final file = File(_lastFilePath!);

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _lastFilePath = null;
      });

      _showMessage('فایل حذف شد');
    } catch (_) {
      _showMessage('خطا در حذف فایل');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SonicAI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'Professional Audio Studio',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFF11131D),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: WaveformPainter(
                          values: _waveform,
                          active: _isRecording,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _isRecording
                          ? (_isPaused ? 'PAUSED' : 'RECORDING')
                          : 'READY',
                      style: TextStyle(
                        color: _isRecording
                            ? const Color(0xFFA78BFA)
                            : Colors.white38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (_lastFilePath != null && !_isRecording)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _playRecording,
                      icon: const Icon(Icons.play_arrow_rounded),
                      iconSize: 32,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: _deleteRecording,
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 28,
                    ),
                  ],
                ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording && !_isPaused)
                    IconButton(
                      onPressed: _pauseRecording,
                      icon: const Icon(Icons.pause_rounded),
                      iconSize: 30,
                    ),

                  if (_isRecording && _isPaused)
                    IconButton(
                      onPressed: _resumeRecording,
                      icon: const Icon(Icons.play_arrow_rounded),
                      iconSize: 30,
                    ),

                  const SizedBox(width: 20),

                  GestureDetector(
                    onTap: _isRecording
                        ? _stopRecording
                        : _startRecording,
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B5CF6),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _isRecording ? 30 : 62,
                          height: _isRecording ? 30 : 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(
                              _isRecording ? 8 : 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                _isRecording
                    ? 'برای پایان ضبط لمس کنید'
                    : 'برای شروع ضبط لمس کنید',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> values;
  final bool active;

  WaveformPainter({
    required this.values,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / values.length;

    for (int i = 0; i < values.length; i++) {
      final value = values[i];
      final height = math.max(5, value * size.height * 0.8);

      final x = spacing * i + spacing / 2;
      final center = size.height / 2;

      paint.color = active
          ? Color.lerp(
              const Color(0xFF5B21B6),
              const Color(0xFFA78BFA),
              i / values.length,
            )!
          : Colors.white24;

      canvas.drawLine(
        Offset(x, center - height / 2),
        Offset(x, center + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.active != active;
  }
}
