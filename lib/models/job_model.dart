import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a contractual job between a Parent and a Babysitter
class JobModel {
  final String jobId;
  final String parentId;
  final String babysitterId;
  final String status; // 'pending', 'accepted', 'rejected', 'in_progress', 'completed', 'cancelled'
  final DateTime startTime;
  final DateTime endTime;
  final double hourlyRateApplied;
  final double totalEstimatedCost;
  final String jobAddress;
  final GeoPoint? jobLocation;
  final String specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.jobId,
    required this.parentId,
    required this.babysitterId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.hourlyRateApplied,
    required this.totalEstimatedCost,
    required this.jobAddress,
    this.jobLocation,
    required this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      jobId: doc.id,
      parentId: data['parentId'] ?? '',
      babysitterId: data['babysitterId'] ?? '',
      status: data['status'] ?? 'pending',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      hourlyRateApplied: (data['hourlyRateApplied'] ?? 0.0).toDouble(),
      totalEstimatedCost: (data['totalEstimatedCost'] ?? 0.0).toDouble(),
      jobAddress: data['jobAddress'] ?? '',
      jobLocation: data['jobLocation'] as GeoPoint?,
      specialInstructions: data['specialInstructions'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'babysitterId': babysitterId,
      'status': status,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'hourlyRateApplied': hourlyRateApplied,
      'totalEstimatedCost': totalEstimatedCost,
      'jobAddress': jobAddress,
      'jobLocation': jobLocation,
      'specialInstructions': specialInstructions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  JobModel copyWith({
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    double? hourlyRateApplied,
    double? totalEstimatedCost,
    String? jobAddress,
    GeoPoint? jobLocation,
    String? specialInstructions,
    DateTime? updatedAt,
  }) {
    return JobModel(
      jobId: jobId,
      parentId: parentId,
      babysitterId: babysitterId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hourlyRateApplied: hourlyRateApplied ?? this.hourlyRateApplied,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      jobAddress: jobAddress ?? this.jobAddress,
      jobLocation: jobLocation ?? this.jobLocation,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
