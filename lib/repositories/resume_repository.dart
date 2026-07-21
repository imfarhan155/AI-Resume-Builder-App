import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/resume_model.dart';

class ResumeRepository {
  final CollectionReference<Map<String, dynamic>> _resumes =
      FirebaseFirestore.instance.collection('resumes');

  Future<String> saveResume(ResumeModel resume) async {
    final doc = await _resumes.add(resume.toMap());
    return doc.id;
  }

  Future<void> updateResume(String id, ResumeModel resume) {
    return _resumes.doc(id).update(resume.toMap());
  }

  // ================= DELETE RESUME =================
  Future<void> deleteResume(String id) async {
    await _resumes.doc(id).delete();
  }

  Stream<List<ResumeModel>> watchMyResumes(String userId) {
    return _resumes
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(ResumeModel.fromDoc).toList());
  }
}
