import 'package:uuid/uuid.dart';

enum MeasurementMetric {
  weightKg,
  waistCm,
  bodyFatPercent,
  leanBodyMassKg,
  neckCm,
  shoulderCm,
  chestCm,
  leftBicepCm,
  rightBicepCm,
  thighCm,
  calfCm,
  hipCm,
}

class MeasurementMetrics {
  final double? weightKg;
  final double? waistCm;
  final double? bodyFatPercent;
  final double? leanBodyMassKg;
  final double? neckCm;
  final double? shoulderCm;
  final double? chestCm;
  final double? leftBicepCm;
  final double? rightBicepCm;
  final double? thighCm;
  final double? calfCm;
  final double? hipCm;

  const MeasurementMetrics({
    this.weightKg,
    this.waistCm,
    this.bodyFatPercent,
    this.leanBodyMassKg,
    this.neckCm,
    this.shoulderCm,
    this.chestCm,
    this.leftBicepCm,
    this.rightBicepCm,
    this.thighCm,
    this.calfCm,
    this.hipCm,
  });

  Map<String, dynamic> toJson() => {
        'weightKg': weightKg,
        'waistCm': waistCm,
        'bodyFatPercent': bodyFatPercent,
        'leanBodyMassKg': leanBodyMassKg,
        'neckCm': neckCm,
        'shoulderCm': shoulderCm,
        'chestCm': chestCm,
        'leftBicepCm': leftBicepCm,
        'rightBicepCm': rightBicepCm,
        'thighCm': thighCm,
        'calfCm': calfCm,
        'hipCm': hipCm,
      };

  factory MeasurementMetrics.fromJson(Map<String, dynamic> json) {
    return MeasurementMetrics(
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      leanBodyMassKg: (json['leanBodyMassKg'] as num?)?.toDouble(),
      neckCm: (json['neckCm'] as num?)?.toDouble(),
      shoulderCm: (json['shoulderCm'] as num?)?.toDouble(),
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      leftBicepCm: (json['leftBicepCm'] as num?)?.toDouble(),
      rightBicepCm: (json['rightBicepCm'] as num?)?.toDouble(),
      thighCm: (json['thighCm'] as num?)?.toDouble(),
      calfCm: (json['calfCm'] as num?)?.toDouble(),
      hipCm: (json['hipCm'] as num?)?.toDouble(),
    );
  }

  MeasurementMetrics copyWith({
    double? weightKg,
    double? waistCm,
    double? bodyFatPercent,
    double? leanBodyMassKg,
    double? neckCm,
    double? shoulderCm,
    double? chestCm,
    double? leftBicepCm,
    double? rightBicepCm,
    double? thighCm,
    double? calfCm,
    double? hipCm,
  }) {
    return MeasurementMetrics(
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      leanBodyMassKg: leanBodyMassKg ?? this.leanBodyMassKg,
      neckCm: neckCm ?? this.neckCm,
      shoulderCm: shoulderCm ?? this.shoulderCm,
      chestCm: chestCm ?? this.chestCm,
      leftBicepCm: leftBicepCm ?? this.leftBicepCm,
      rightBicepCm: rightBicepCm ?? this.rightBicepCm,
      thighCm: thighCm ?? this.thighCm,
      calfCm: calfCm ?? this.calfCm,
      hipCm: hipCm ?? this.hipCm,
    );
  }

  /// Helper to get value by enum key
  double? getValue(MeasurementMetric metric) {
    switch (metric) {
      case MeasurementMetric.weightKg:
        return weightKg;
      case MeasurementMetric.waistCm:
        return waistCm;
      case MeasurementMetric.bodyFatPercent:
        return bodyFatPercent;
      case MeasurementMetric.leanBodyMassKg:
        return leanBodyMassKg;
      case MeasurementMetric.neckCm:
        return neckCm;
      case MeasurementMetric.shoulderCm:
        return shoulderCm;
      case MeasurementMetric.chestCm:
        return chestCm;
      case MeasurementMetric.leftBicepCm:
        return leftBicepCm;
      case MeasurementMetric.rightBicepCm:
        return rightBicepCm;
      case MeasurementMetric.thighCm:
        return thighCm;
      case MeasurementMetric.calfCm:
        return calfCm;
      case MeasurementMetric.hipCm:
        return hipCm;
    }
  }
}

class Measurement {
  final String id;
  final DateTime date;
  final MeasurementMetrics metrics;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Measurement({
    String? id,
    required this.date,
    this.metrics = const MeasurementMetrics(),
    this.photos = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'metrics': metrics.toJson(),
        'photos': photos,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      metrics: json['metrics'] != null
          ? MeasurementMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : const MeasurementMetrics(),
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Measurement copyWith({
    DateTime? date,
    MeasurementMetrics? metrics,
    List<String>? photos,
    DateTime? updatedAt,
  }) {
    return Measurement(
      id: id,
      date: date ?? this.date,
      metrics: metrics ?? this.metrics,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
