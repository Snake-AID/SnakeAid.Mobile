import 'package:flutter/material.dart';

/// Custom Dialog Widget - Reusable professional dialog for the app
class CustomDialog extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String description;
  final List<Widget>? extraContent;
  final List<DialogAction> actions;

  const CustomDialog({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.description,
    this.extraContent,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Extra Content (optional)
            if (extraContent != null) ...[
              const SizedBox(height: 16),
              ...extraContent!,
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActions(actions),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(List<DialogAction> actions) {
    if (actions.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _buildButton(actions[0]),
      );
    } else if (actions.length == 2) {
      return Row(
        children: [
          Expanded(
            flex: actions[0].flex ?? 1,
            child: _buildButton(actions[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: actions[1].flex ?? 1,
            child: _buildButton(actions[1]),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions.map((action) {
          final isLast = action == actions.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: _buildButton(action),
          );
        }).toList(),
      );
    }
  }

  Widget _buildButton(DialogAction action) {
    if (action.isOutlined) {
      return OutlinedButton(
        onPressed: action.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: action.textColor ?? const Color(0xFF666666),
          side: BorderSide(
            color: action.borderColor ?? const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: action.icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: action.isBold ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                action.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: action.isBold ? FontWeight.bold : FontWeight.w600,
                ),
              ),
      );
    } else {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: action.backgroundColor ?? const Color(0xFF228B22),
          foregroundColor: action.textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: action.icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: action.isBold ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                action.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: action.isBold ? FontWeight.bold : FontWeight.w600,
                ),
              ),
      );
    }
  }
}

/// Dialog Action Model
class DialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isBold;
  final int? flex;

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isBold = true,
    this.flex,
  });
}
