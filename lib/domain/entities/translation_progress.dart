class TranslationProgress {
  final int completed;
  final int total;

  const TranslationProgress({required this.completed, required this.total});

  double get fraction => total > 0 ? completed / total : 0.0;
  bool get isComplete => completed >= total;
}
