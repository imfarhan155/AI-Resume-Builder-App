import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {
  final String? id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String careerObjective;
  final String education;
  final String skills;
  final String experience;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResumeModel({
    this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.careerObjective,
    required this.education,
    required this.skills,
    required this.experience,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'careerObjective': careerObjective,
      'education': education,
      'skills': skills,
      'experience': experience,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ResumeModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResumeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      careerObjective: data['careerObjective'] ?? '',
      education: data['education'] ?? '',
      skills: data['skills'] ?? '',
      experience: data['experience'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
