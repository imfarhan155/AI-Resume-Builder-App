import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../services/pdf_service.dart';
import '../widgets/section_card.dart';
import 'resume_form_screen.dart';

class ResumePreviewScreen extends StatelessWidget {
  final ResumeModel resume;
  const ResumePreviewScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    final pdf = context.read<PDFService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Resume Preview")),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 70,
        ),
        children: [
          SectionCard(
            title: "Personal Information",
            icon: Icons.person_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resume.fullName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(resume.email),
                Text(resume.phone),
                Text(resume.address),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: "Career Objective",
            icon: Icons.track_changes_outlined,
            child: Text(resume.careerObjective),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: "Education",
            icon: Icons.school_outlined,
            child: Text(resume.education),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: "Skills",
            icon: Icons.psychology_alt_outlined,
            child: Text(resume.skills),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: "Experience",
            icon: Icons.business_center_outlined,
            child: Text(resume.experience),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResumeFormScreen(initial: resume),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text("Edit Resume"),
          ),
          const SizedBox(height: 10),

          // Red Background PDF Button
          ElevatedButton.icon(
            onPressed: () => pdf.printResume(resume),
            icon:
                const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            label: const Text("Download PDF",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
