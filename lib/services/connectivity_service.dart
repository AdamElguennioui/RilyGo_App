// ─────────────────────────────────────────────────────────────────────────────
//  ConnectivityService — offline layer MVP
//
//  • Pas de dépendance externe (connectivity_plus optionnel)
//  • Mock : simule toujours "connecté" en mode dev
//  • Structure prête pour brancher connectivity_plus plus tard
//  • Utilisé par les écrans via ConnectivityBanner
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();

  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // En mode mock : on simule toujours connecté.
  // Pour brancher connectivity_plus :
  //   1. ajouter connectivity_plus: ^6.0.0 dans pubspec.yaml
  //   2. remplacer _mockConnected par un vrai stream
  bool _isConnected = true;

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool get isConnected => _isConnected;

  /// Appeler dans main() si connectivity_plus est branché.
  /// En mock, ne fait rien.
  Future<void> init() async {
    // TODO (backend) :
    // final result = await Connectivity().checkConnectivity();
    // _isConnected = result != ConnectivityResult.none;
    // Connectivity().onConnectivityChanged.listen((result) {
    //   final connected = result != ConnectivityResult.none;
    //   if (connected != _isConnected) {
    //     _isConnected = connected;
    //     _controller.add(_isConnected);
    //   }
    // });
  }

  /// Simule une perte de connexion (pour les tests).
  void simulateOffline() {
    _isConnected = false;
    _controller.add(false);
  }

  void simulateOnline() {
    _isConnected = true;
    _controller.add(true);
  }

  void dispose() {
    _controller.close();
  }
}