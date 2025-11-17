import 'package:flutter/material.dart';

class RegularisationRequest {
  final String id;
  final String userId;
  final String projectId;
  final DateTime date;
  final DateTime requestedDate;
  final DateTime? approvedDate;
  final RegularisationType type;
  final RegularisationStatus status;
  final String reason;
  final String? remarks;
  final String? approvedBy;
  final List<String> supportingDocs;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegularisationRequest({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.date,
    required this.requestedDate,
    this.approvedDate,
    required this.type,
    required this.status,
    required this.reason,
    this.remarks,
    this.approvedBy,
    required this.supportingDocs,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with method
  RegularisationRequest copyWith({
    String? id,
    String? userId,
    String? projectId,
    DateTime? date,
    DateTime? requestedDate,
    DateTime? approvedDate,
    RegularisationType? type,
    RegularisationStatus? status,
    String? reason,
    String? remarks,
    String? approvedBy,
    List<String>? supportingDocs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegularisationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      requestedDate: requestedDate ?? this.requestedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
      approvedBy: approvedBy ?? this.approvedBy,
      supportingDocs: supportingDocs ?? this.supportingDocs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == RegularisationStatus.pending;
  bool get isApproved => status == RegularisationStatus.approved;
  bool get isRejected => status == RegularisationStatus.rejected;
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}

enum RegularisationType { checkIn, checkOut, fullDay, halfDay }

enum RegularisationStatus { pending, approved, rejected, cancelled }

class RegularisationFormData {
  String projectId = '';
  DateTime date = DateTime.now();
  RegularisationType type = RegularisationType.fullDay;
  String reason = '';
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  List<String> supportingDocs = [];

  RegularisationFormData();

  RegularisationFormData.copy(RegularisationFormData other) {
    projectId = other.projectId;
    date = other.date;
    type = other.type;
    reason = other.reason;
    checkInTime = other.checkInTime;
    checkOutTime = other.checkOutTime;
    supportingDocs = List.from(other.supportingDocs);
  }
}
