import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/phone_data_models.dart';

class MockPlaybackService extends ChangeNotifier {
  final List<TrackInfo> _playlist = [
    TrackInfo(
      id: '1',
      title: 'Resonance',
      artist: 'HOME',
      album: 'Odyssey',
      duration: const Duration(minutes: 3, seconds: 32),
      albumArtUrl: 'https://picsum.photos/id/1015/600/600',
      genre: 'Synthwave',
    ),
    TrackInfo(
      id: '2',
      title: 'Areal Break',
      artist: 'KAYTRANADA',
      album: 'TIMELESS',
      duration: const Duration(minutes: 2, seconds: 50),
      albumArtUrl: 'https://picsum.photos/id/1025/600/600',
      genre: 'Electronic',
    ),
    TrackInfo(
      id: '3',
      title: 'Midnight City',
      artist: 'M83',
      album: 'Hurry Up, We\'re Dreaming',
      duration: const Duration(minutes: 4, seconds: 3),
      albumArtUrl: 'https://picsum.photos/id/1039/600/600',
      genre: 'Indie Electronic',
    ),
    TrackInfo(
      id: '4',
      title: 'A Tear in the Space-Time Continuum',
      artist: 'The Comet Is Coming',
      album: 'Trust In The Lifeforce',
      duration: const Duration(minutes: 3, seconds: 15),
      albumArtUrl: 'https://picsum.photos/id/1043/600/600',
      genre: 'Nu Jazz',
    ),
    TrackInfo(
      id: '5',
      title: 'Veridis Quo',
      artist: 'Daft Punk',
      album: 'Discovery',
      duration: const Duration(minutes: 5, seconds: 45),
      albumArtUrl: 'https://picsum.photos/id/1050/600/600',
      genre: 'French Touch',
    ),
    TrackInfo(
      id: '6',
      title: 'Subwoofer Lullaby',
      artist: 'C418',
      album: 'Minecraft - Volume Alpha',
      duration: const Duration(minutes: 3, seconds: 28),
      albumArtUrl: 'https://picsum.photos/id/1062/600/600',
      genre: 'Ambient',
    ),
    TrackInfo(
      id: '7',
      title: 'Starship Trooper',
      artist: 'Yes',
      album: 'The Yes Album',
      duration: const Duration(minutes: 9, seconds: 28),
      albumArtUrl: 'https://picsum.photos/id/1069/600/600',
      genre: 'Progressive Rock',
    ),
    TrackInfo(
      id: '8',
      title: 'Dayvan Cowboy',
      artist: 'Boards of Canada',
      album: 'The Campfire Headphase',
      duration: const Duration(minutes: 5, seconds: 00),
      albumArtUrl: 'https://picsum.photos/id/1084/600/600',
      genre: 'IDM / Ambient',
    ),
  ];

  int _currentIndex = 0;
  bool _isPlaying = true;
  Duration _currentPosition = Duration.zero;
  Timer? _ticker;

  TrackInfo get currentTrack => _playlist[_currentIndex];
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  List<TrackInfo> get playlist => List.unmodifiable(_playlist);

  MockPlaybackService() {
    _startTicker();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    notifyListeners();
  }

  void nextTrack() {
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  void previousTrack() {
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  void seek(Duration position) {
    _currentPosition = position;
    notifyListeners();
  }

  void selectTrack(int index) {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      notifyListeners();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentPosition < currentTrack.duration) {
        _currentPosition += const Duration(seconds: 1);
      } else {
        nextTrack();
      }
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
