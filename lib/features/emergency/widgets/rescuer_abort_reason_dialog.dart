import 'package:flutter/material.dart';
import '../../shared/widgets/custom_dialog.dart';

typedef RescuerAbortSubmit = Future<String?> Function(String reason);

/// Shared rescuer abort-reason dialog used across detail/navigation screens.
/// Returns the selected reason text, or null if user cancels.
///
/// [onSubmit] should return null when submit succeeds, otherwise return
/// an error message to keep dialog open and show feedback.
Future<String?> showRescuerAbortReasonDialog(
  BuildContext context, {
  required RescuerAbortSubmit onSubmit,
}) async {
  String? selectedReason;
  final customController = TextEditingController();
  bool showCustom = false;
  bool isSubmitting = false;
  String? submitError;

  const reasons = [
    'Phương tiện gặp sự cố',
    'Có việc khẩn cấp',
    'Không thể tiếp cận địa điểm',
    'Bệnh nhân hủy yêu cầu',
    'Điều kiện thời tiết nguy hiểm',
    'Lý do khác',
  ];

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final maxScrollableHeight =
          MediaQuery.of(dialogContext).size.height * 0.42;

      return StatefulBuilder(
        builder: (context, setState) {
          final contentItems = <Widget>[
            ...reasons.map((reason) {
              final isSelected = selectedReason == reason;
              final isOther = reason == 'Lý do khác';
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedReason = reason;
                    showCustom = isOther;
                    if (!isOther) customController.clear();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF8800).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF8800)
                          : const Color(0xFFE5E5E5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8800)
                                : const Color(0xFFCCCCCC),
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFFFF8800)
                              : Colors.white,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: const Color(0xFF1C100D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (showCustom)
              TextField(
                controller: customController,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do cụ thể...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            if (submitError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  submitError!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDC3545),
                  ),
                ),
              ),
            if (isSubmitting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang xử lý...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
          ];

          return CustomDialog(
            icon: Icons.cancel_outlined,
            iconBackgroundColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFDC3545),
            title: 'Hủy nhiệm vụ?',
            description:
                'Vui lòng chọn lý do hủy chuyến để chúng tôi cải thiện dịch vụ',
            extraContent: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxScrollableHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: contentItems,
                  ),
                ),
              ),
            ],
            actions: [
              DialogAction(
                label: 'Quay lại',
                isOutlined: true,
                onPressed: () {
                  if (isSubmitting) return;
                  Navigator.of(dialogContext).pop();
                },
              ),
              DialogAction(
                label: isSubmitting ? 'Đang gửi...' : 'Xác nhận hủy',
                backgroundColor: const Color(0xFFDC3545),
                onPressed: () async {
                  if (isSubmitting) return;
                  if (selectedReason == null) return;

                  var finalReason = selectedReason!;
                  if (showCustom) {
                    final custom = customController.text.trim();
                    if (custom.isEmpty) return;
                    finalReason = custom;
                  }

                  setState(() {
                    isSubmitting = true;
                    submitError = null;
                  });

                  final errorMessage = await onSubmit(finalReason);
                  if (!context.mounted) return;

                  if (errorMessage == null) {
                    Navigator.of(dialogContext).pop(finalReason);
                    return;
                  }

                  setState(() {
                    isSubmitting = false;
                    submitError = errorMessage;
                  });
                },
              ),
            ],
          );
        },
      );
    },
  );

  customController.dispose();
  return result;
}
