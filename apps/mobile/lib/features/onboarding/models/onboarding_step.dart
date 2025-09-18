import 'package:flutter/material.dart';

/// Model for onboarding step data
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final Widget? customWidget;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    this.customWidget,
  });
}

/// Default onboarding steps for the app
class DefaultOnboardingSteps {
  static const List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Welcome to Receipt Organizer',
      description: 'Your smart companion for managing receipts and expenses. Let\'s get you started!',
      icon: Icons.receipt_long,
      color: Color(0xFF10B981),
    ),
    OnboardingStep(
      title: 'Capture with Ease',
      description: 'Take photos of receipts or upload from your gallery. Our AI instantly extracts key information.',
      icon: Icons.camera_alt,
      color: Color(0xFF3B82F6),
    ),
    OnboardingStep(
      title: 'Smart Organization',
      description: 'Automatically categorize receipts, add notes, and search through your entire collection instantly.',
      icon: Icons.auto_awesome,
      color: Color(0xFF8B5CF6),
    ),
    OnboardingStep(
      title: 'Export Anywhere',
      description: 'Generate reports, export to CSV for accounting, or share with your team - all in seconds.',
      icon: Icons.file_download,
      color: Color(0xFFF59E0B),
    ),
    OnboardingStep(
      title: 'Secure & Private',
      description: 'Your data stays on your device with optional cloud backup. You\'re always in control.',
      icon: Icons.lock,
      color: Color(0xFF10B981),
    ),
  ];
}