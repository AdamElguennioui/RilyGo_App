// ─────────────────────────────────────────────────────────────────────────────
//  ProofUploadService — upload preuve MVP ultra stable
//
//  États : idle → compressing → uploading → done | error
//  Retry : max 3 tentatives avec backoff exponentiel
//  Structure prête pour vrai backend (multipart/form-data)
//
//  TODO backend :
//    - remplacer _mockUpload() par un appel http.MultipartRequest
//    - remplacer _mockCompress() par flutter_image_compress
//    - imagePath → URL retournée par le serveur
// ─────────────────────────────────────────────────────────────────────────────

enum ProofUploadStatus { idle, compressing, uploading, done, error }

class ProofUploadResult {
  final String imagePath; // URL ou path local
  final ProofUploadStatus status;
  final String? errorMessage;

  const ProofUploadResult({
    required this.imagePath,
    required this.status,
    this.errorMessage,
  });
}

class ProofUploadService {
  static const int _maxRetries = 3;
  static const String _mockPath = 'assets/proof_placeholder.jpg';

  // Callback d'état (pour mettre à jour l'UI depuis le service)
  void Function(ProofUploadStatus)? onStatusChanged;

  ProofUploadStatus _status = ProofUploadStatus.idle;
  ProofUploadStatus get status => _status;

  void _emit(ProofUploadStatus s) {
    _status = s;
    onStatusChanged?.call(s);
  }

  /// Lance l'upload avec retry automatique.
  /// [localPath] : chemin local du fichier (depuis image_picker)
  /// Retourne [ProofUploadResult] avec l'URL finale ou une erreur.
  Future<ProofUploadResult> upload({
    required String localPath,
    int attempt = 1,
  }) async {
    try {
      // Étape 1 : compression (mock — remplacer par flutter_image_compress)
      _emit(ProofUploadStatus.compressing);
      final compressedPath = await _mockCompress(localPath);

      // Étape 2 : upload (mock — remplacer par HTTP multipart)
      _emit(ProofUploadStatus.uploading);
      final uploadedPath = await _mockUpload(compressedPath);

      _emit(ProofUploadStatus.done);
      return ProofUploadResult(
        imagePath: uploadedPath,
        status: ProofUploadStatus.done,
      );
    } catch (e) {
      if (attempt < _maxRetries) {
        // Backoff exponentiel : 1s, 2s, 4s
        final delay = Duration(seconds: 1 << (attempt - 1));
        await Future.delayed(delay);
        return upload(localPath: localPath, attempt: attempt + 1);
      }

      _emit(ProofUploadStatus.error);
      return ProofUploadResult(
        imagePath: '',
        status: ProofUploadStatus.error,
        errorMessage: _friendlyError(e),
      );
    }
  }

  void reset() => _emit(ProofUploadStatus.idle);

  // ─── Mocks (à remplacer) ─────────────────────────────────────────────────

  Future<String> _mockCompress(String path) async {
    // TODO : final result = await FlutterImageCompress.compressAndGetFile(...)
    await Future.delayed(const Duration(milliseconds: 400));
    return path; // retourne le même path en mock
  }

  Future<String> _mockUpload(String compressedPath) async {
    // TODO : envoyer multipart/form-data vers l'API
    // final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/proof'));
    // request.files.add(await http.MultipartFile.fromPath('file', compressedPath));
    // final response = await request.send();
    // return jsonDecode(await response.stream.bytesToString())['url'];
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockPath;
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('connection')) {
      return 'Pas de connexion. Vérifie ton réseau et réessaie.';
    }
    if (msg.contains('timeout')) {
      return 'Connexion trop lente. Réessaie dans un moment.';
    }
    if (msg.contains('413') || msg.contains('too large')) {
      return 'Fichier trop volumineux.';
    }
    return 'Upload échoué. Réessaie.';
  }
}