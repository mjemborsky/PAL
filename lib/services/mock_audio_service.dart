import 'dart:async';
import 'dart:math';

class MockAudioService {
  StreamController<List<double>>? _audioController;
  Timer? _timer;
  final Random _random = Random();

  /// Stream of simulated 128-sample PCM audio buffers
  Stream<List<double>> get audioStream {
    _audioController ??= StreamController<List<double>>.broadcast(
      onListen: _startGenerating,
      onCancel: _stopGenerating,
    );
    return _audioController!.stream;
  }

  void _startGenerating() {
    // Generates a mock PCM frame roughly every 16ms (~60 FPS)
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final List<double> pcmBuffer = List.generate(128, (index) {
        // Generate a smooth sine wave mixed with light random noise
        final double sine =
            sin(index * 0.1 + DateTime.now().millisecondsSinceEpoch * 0.005);
        final double noise = (_random.nextDouble() - 0.5) * 0.2;
        return (sine + noise).clamp(-1.0, 1.0);
      });

      _audioController?.add(pcmBuffer);
    });
  }

  void _stopGenerating() {
    _timer?.cancel();
    _audioController?.close();
    _audioController = null;
  }
}
