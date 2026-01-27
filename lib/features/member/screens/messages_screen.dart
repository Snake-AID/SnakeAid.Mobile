import 'package:flutter/material.dart';
import 'message_detail_screen.dart';

/// Messages Screen - List of conversations
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';

  final List<MessageThread> _conversations = [
    MessageThread(
      id: '1',
      userName: 'Bác sĩ Nguyễn Văn A',
      userAvatar: '👨‍⚕️',
      lastMessage: 'Bạn cần uống thuốc theo đơn và nghỉ ngơi nhé',
      timestamp: '10:30',
      unreadCount: 2,
      isExpert: true,
      status: MessageStatus.active,
    ),
    MessageThread(
      id: '2',
      userName: 'Chuyên gia Trần Thị B',
      userAvatar: '👩‍⚕️',
      lastMessage: 'Rắn này là rắn lục đuôi đỏ, không độc',
      timestamp: 'Hôm qua',
      unreadCount: 0,
      isExpert: true,
      status: MessageStatus.active,
    ),
    MessageThread(
      id: '3',
      userName: 'Trung tâm hỗ trợ',
      userAvatar: '🏥',
      lastMessage: 'Cảm ơn bạn đã sử dụng dịch vụ',
      timestamp: '2 ngày trước',
      unreadCount: 0,
      isExpert: false,
      status: MessageStatus.archived,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MessageThread> get _filteredConversations {
    switch (_selectedFilter) {
      case 'Chưa đọc':
        return _conversations.where((msg) => msg.unreadCount > 0).toList();
      case 'Chuyên gia':
        return _conversations.where((msg) => msg.isExpert).toList();
      default:
        return _conversations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with SafeArea
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Tin nhắn',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF228B22),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tạo cuộc trò chuyện mới')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm tin nhắn...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF888888),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tất cả'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Chưa đọc'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Chuyên gia'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Message List
          Expanded(
            child: _filteredConversations.isEmpty
                ? _buildEmptyState()
                : Container(
                    color: const Color(0xFFF5F5F5),
                    child: ListView.builder(
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        return MessageThreadCard(
                          thread: _filteredConversations[index],
                          onTap: () => _openMessageDetail(_filteredConversations[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF228B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF228B22) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin nhắn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu cuộc trò chuyện với chuyên gia',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _openMessageDetail(MessageThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageDetailScreen(thread: thread),
      ),
    );
  }
}

// Message Thread Card - Reusable widget
class MessageThreadCard extends StatelessWidget {
  final MessageThread thread;
  final VoidCallback onTap;

  const MessageThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: thread.isExpert
                          ? const Color(0xFF228B22)
                          : const Color(0xFFE0E0E0),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      thread.userAvatar,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                if (thread.isExpert)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          thread.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        thread.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: thread.unreadCount > 0
                              ? const Color(0xFF228B22)
                              : Colors.grey[600],
                          fontWeight: thread.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: thread.unreadCount > 0
                                ? const Color(0xFF333333)
                                : Colors.grey[600],
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (thread.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF228B22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            thread.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Message Thread Model - Reusable
class MessageThread {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isExpert;
  final MessageStatus status;

  MessageThread({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isExpert,
    required this.status,
  });
}

enum MessageStatus {
  active,
  archived,
}
