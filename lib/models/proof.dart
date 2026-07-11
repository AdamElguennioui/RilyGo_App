class Proof {
  final String? imagePath;
  final String? comment;

  const Proof({
    this.imagePath,
    this.comment,
  });

  factory Proof.fromJson(Map<String, dynamic> json) {
    return Proof(
      imagePath: json['imagePath'] as String?,
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'comment': comment,
    };
  }

  Proof copyWith({
    String? imagePath,
    String? comment,
  }) {
    return Proof(
      imagePath: imagePath ?? this.imagePath,
      comment: comment ?? this.comment,
    );
  }
}