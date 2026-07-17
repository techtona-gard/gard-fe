class HistoryModel {
  final int historyId;
  final String userId;
  final String category; // DETEKSI, KONSULTASI, KUESIONER, SOS
  final DateTime historyDate;
  final String? description;
  final String? severityLevel;
  final String? doctorName;
  final String? doctorTitle;
  final int? gerdqScore;
  final DateTime? createdAt;

  HistoryModel({
    required this.historyId,
    required this.userId,
    required this.category,
    required this.historyDate,
    this.description,
    this.severityLevel,
    this.doctorName,
    this.doctorTitle,
    this.gerdqScore,
    this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      historyId: json['history_id'] is int ? json['history_id'] : int.tryParse(json['history_id'].toString()) ?? 0,
      userId: json['user_id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'DETEKSI',
      historyDate: json['history_date'] != null ? DateTime.parse(json['history_date'].toString()).toLocal() : DateTime.now(),
      description: json['description']?.toString(),
      severityLevel: json['severity_level']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      doctorTitle: json['doctor_title']?.toString(),
      gerdqScore: json['gerdq_score'] != null ? (json['gerdq_score'] is int ? json['gerdq_score'] : int.tryParse(json['gerdq_score'].toString())) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category': category,
      'history_date': historyDate.toUtc().toIso8601String(),
      'description': description,
      'severity_level': severityLevel,
      'doctor_name': doctorName,
      'doctor_title': doctorTitle,
      'gerdq_score': gerdqScore,
    };
  }
}
