import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../providers/member_services_and_terms_provider.dart';

class MemberFaqScreen extends ConsumerStatefulWidget {
  const MemberFaqScreen({super.key});

  @override
  ConsumerState<MemberFaqScreen> createState() => _MemberFaqScreenState();
}

class _MemberFaqScreenState extends ConsumerState<MemberFaqScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(memberServicesAndTermsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Câu Hỏi Thường Gặp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Không thể tải câu hỏi thường gặp. Vui lòng thử lại.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
          ),
        ),
        data: (terms) {
          final faqs = terms.faq;
          if (faqs.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu câu hỏi thường gặp.',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final isExpanded = _expandedIndex == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? AppTheme.primaryGreen
                        : const Color(0xFFF0F0F0),
                    width: isExpanded ? 1.5 : 1,
                  ),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      faqs[index].question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isExpanded
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isExpanded
                            ? AppTheme.primaryGreen
                            : const Color(0xFF333333),
                      ),
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: isExpanded ? AppTheme.primaryGreen : Colors.grey,
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedIndex = expanded ? index : null;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 20,
                        ),
                        child: Text(
                          faqs[index].answer,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
