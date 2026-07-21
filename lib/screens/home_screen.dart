import 'resume_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/resume_repository.dart';
import '../models/resume_model.dart';
import '../widgets/section_card.dart';
import 'resume_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthRepository>();
    final user = auth.currentUser!;
    final resumeRepo = context.read<ResumeRepository>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E2937)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: ListView(
              children: [
                // Custom App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.tealAccent, Colors.cyan],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "🤖",
                              style: TextStyle(fontSize: 26),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "AI Resume Builder",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await auth.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/auth');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Welcome Section
                SectionCard(
                  title: "Welcome",
                  icon: Icons.waving_hand_rounded,
                  child: Text(
                    "Build beautiful professional resumes with AI assistance.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: 16.5,
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create Resume Button (Fixed with Gradient)
                Container(
                  width: double.infinity,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ResumeFormScreen()),
                        );
                      },
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline,
                                size: 28, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              "Create Resume",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // My Resumes
                const Text(
                  "My Resumes",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                StreamBuilder<List<ResumeModel>>(
                  stream: resumeRepo.watchMyResumes(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                              color: Colors.tealAccent),
                        ),
                      );
                    }

                    final list = snapshot.data ?? [];

                    if (list.isEmpty) {
                      return Card(
                        color: Colors.white.withOpacity(0.08),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 70, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No resumes yet",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Create your first one.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: list.map((r) {
                        return Card(
                          color: Colors.white.withOpacity(0.06),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            title: Text(
                              r.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Text(
                              r.email,
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await resumeRepo.deleteResume(r.id!);
                                  },
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ResumePreviewScreen(resume: r),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
