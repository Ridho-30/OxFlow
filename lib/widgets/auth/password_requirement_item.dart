// lib/widgets/auth/password_requirement_item.dart

import 'package:flutter/material.dart';

/// A single checklist row shown under the new-password field in
/// [ResetPasswordScreen]. Extracted from [_buildChecklistItem] method
/// so it can be a proper [StatelessWidget] (const-eligible when possible).
class PasswordRequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const PasswordRequirementItem({
    super.key,
    required this.label,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? const Color(0xFF00E5A8) : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isMet ? Colors.white : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
