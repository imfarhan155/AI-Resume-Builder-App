import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/resume_repository.dart';
import '../services/ai_service.dart';
import '../utils/validators.dart';
import '../widgets/section_card.dart';
import '../widgets/custom_text_field.dart';
import 'resume_preview_screen.dart';

class ResumeFormScreen extends StatefulWidget {
  final ResumeModel? initial;
  const ResumeFormScreen({super.key, this.initial});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _aiLoading = false;

  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _education;
  late final TextEditingController _objective;
  late final TextEditingController _skills;
  late final TextEditingController _experience;
  late final TextEditingController _summary;

  // Generated Content
  String? _generatedObjective;
  String? _generatedSkills;
  String? _generatedExperience;
  String? _generatedSummary;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _fullName = TextEditingController(text: i?.fullName ?? '');
    _email = TextEditingController(text: i?.email ?? '');
    _phone = TextEditingController(text: i?.phone ?? '');
    _address = TextEditingController(text: i?.address ?? '');
    _education = TextEditingController(text: i?.education ?? '');
    _objective = TextEditingController(text: i?.careerObjective ?? '');
    _skills = TextEditingController(text: i?.skills ?? '');
    _experience = TextEditingController(text: i?.experience ?? '');
    _summary = TextEditingController();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _education.dispose();
    _objective.dispose();
    _skills.dispose();
    _experience.dispose();
    _summary.dispose();
    super.dispose();
  }

  // ==================== AI FUNCTIONS ====================

  Future<void> _generateAll() async {
    setState(() => _aiLoading = true);
    final ai = context.read<AIService>();

    try {
      final results = await Future.wait([
        ai.suggestCareerObjective(
            fullName: _fullName.text.trim(), roleHint: "Software Engineer"),
        ai.suggestSkills(roleHint: "Software Development"),
        ai.improveExperience(experience: _experience.text.trim()),
        ai.suggestSummary(experience: _experience.text.trim()),
      ]);

      setState(() {
        _generatedObjective = results[0];
        _generatedSkills = results[1];
        _generatedExperience = results[2];
        _generatedSummary = results[3];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("AI Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _generateObjective() async => _generateField(
        () => context.read<AIService>().suggestCareerObjective(
            fullName: _fullName.text.trim(), roleHint: "Software Engineer"),
        (val) => _generatedObjective = val,
      );

  Future<void> _generateSkills() async => _generateField(
        () => context
            .read<AIService>()
            .suggestSkills(roleHint: "Software Development"),
        (val) => _generatedSkills = val,
      );

  Future<void> _generateExperience() async => _generateField(
        () => context
            .read<AIService>()
            .improveExperience(experience: _experience.text.trim()),
        (val) => _generatedExperience = val,
      );

  Future<void> _generateSummary() async => _generateField(
        () => context
            .read<AIService>()
            .suggestSummary(experience: _experience.text.trim()),
        (val) => _generatedSummary = val,
      );

  Future<void> _generateField(
      Future<String> Function() producer, Function(String) setter) async {
    setState(() => _aiLoading = true);
    try {
      final result = await producer();
      setState(() => setter(result));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  void _useGenerated(String? text, TextEditingController controller) {
    if (text == null) return;
    controller.text = text;
    setState(() {
      if (controller == _objective) _generatedObjective = null;
      if (controller == _skills) _generatedSkills = null;
      if (controller == _experience) _generatedExperience = null;
      if (controller == _summary) _generatedSummary = null;
    });
  }

  // ==================== STRONG SAVE ====================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required fields"),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Extra Safety Check
    if (_fullName.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        _education.text.trim().isEmpty ||
        _objective.text.trim().isEmpty ||
        _skills.text.trim().isEmpty ||
        _experience.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required fields"),
            backgroundColor: Colors.red),
      );
      return;
    }

    final user = context.read<AuthRepository>().currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final model = ResumeModel(
        id: widget.initial?.id,
        userId: user.uid,
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        education: _education.text.trim(),
        careerObjective: _objective.text.trim(),
        skills: _skills.text.trim(),
        experience: _experience.text.trim(),
        createdAt: widget.initial?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = context.read<ResumeRepository>();

      if (widget.initial?.id == null) {
        await repo.saveResume(model);
      } else {
        await repo.updateResume(widget.initial!.id!, model);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Resume saved successfully!"),
            backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResumePreviewScreen(resume: model)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Card(
          color: const Color(0xFF1E293B),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  "Create Resume",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E2937)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 40,
            ),
            children: [
              SectionCard(
                title: "Personal Information",
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _buildWhiteTextField(
                        "Full Name",
                        _fullName,
                        (v) =>
                            v!.trim().isEmpty ? "Full Name is required" : null,
                        Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _buildWhiteTextField("Email", _email, Validators.email,
                        Icons.email_outlined, TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _buildWhiteTextField(
                        "Phone Number",
                        _phone,
                        (v) => v!.trim().isEmpty
                            ? "Phone number is required"
                            : null,
                        Icons.phone_outlined,
                        TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildWhiteTextField(
                        "Address",
                        _address,
                        (v) => v!.trim().isEmpty ? "Address is required" : null,
                        Icons.home_outlined,
                        null,
                        2),
                    const SizedBox(height: 12),
                    _buildWhiteTextField(
                        "Education",
                        _education,
                        (v) =>
                            v!.trim().isEmpty ? "Education is required" : null,
                        Icons.school_outlined,
                        null,
                        3),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: "Professional Details",
                icon: Icons.work_outline,
                child: Column(
                  children: [
                    _buildAIField("Career Objective", _objective,
                        _generatedObjective, _generateObjective),
                    const SizedBox(height: 20),
                    _buildAIField(
                        "Skills", _skills, _generatedSkills, _generateSkills),
                    const SizedBox(height: 20),
                    _buildAIField("Experience", _experience,
                        _generatedExperience, _generateExperience,
                        maxLines: 6),
                    const SizedBox(height: 20),
                    _buildAIField("Professional Summary", _summary,
                        _generatedSummary, _generateSummary,
                        maxLines: 5),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _aiLoading ? null : _generateAll,
                icon: const Icon(Icons.auto_awesome, size: 28),
                label: const Text("✨ Generate All Sections with AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFF0EA5E9)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(_saving ? "Saving..." : "Save Resume",
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIField(
    String label,
    TextEditingController controller,
    String? generatedText,
    VoidCallback onGenerate, {
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        _buildWhiteTextField(
            label, controller, null, Icons.edit_note_outlined, null, maxLines),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _aiLoading ? null : onGenerate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text("Generate"),
            ),
            if (generatedText != null)
              ElevatedButton.icon(
                onPressed: () => _useGenerated(generatedText, controller),
                icon: const Icon(Icons.check),
                label: const Text("Use"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
        if (generatedText != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(generatedText,
                  style: const TextStyle(color: Colors.black87, height: 1.5)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWhiteTextField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator,
    IconData prefixIcon, [
    TextInputType? keyboardType,
    int maxLines = 1,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: CustomTextField(
        label: label,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        prefixIcon: prefixIcon,
        maxLines: maxLines,
      ),
    );
  }
}
