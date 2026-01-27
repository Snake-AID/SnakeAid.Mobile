import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'messages_screen.dart';

/// Message Detail Screen - Individual conversation
class MessageDetailScreen extends StatefulWidget {
  final MessageThread thread;

  const MessageDetailScreen({
    super.key,
    required this.thread,
  });

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Sample messages for demonstration
    setState(() {
      _messages.addAll([
        Message(
          id: '1',
          text: 'Xin chào! Tôi có thể giúp gì cho bạn?',
          isSentByMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          senderName: widget.thread.userName,
          senderAvatar: widget.thread.userAvatar,
        ),
        Message(
          id: '2',
          text: 'Em bị rắn cắn, không biết rắn gì. Em có thể gửi ảnh được không ạ?',
          isSentByMe: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        ),
        Message(
          id: '3',
          text: 'Được, bạn gửi ảnh rõ nét phần đầu và thân rắn nhé',
          isSentByMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          senderName: widget.thread.userName,
          senderAvatar: widget.thread.userAvatar,
        ),
        Message(
          id: '4',
          text: '[Hình ảnh]',
          isSentByMe: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          hasImage: true,
        ),
        Message(
          id: '5',
          text: 'Đây là rắn lục đuôi đỏ, không độc. Vết cắn chỉ cần rửa sạch và sát trùng',
          isSentByMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          senderName: widget.thread.userName,
          senderAvatar: widget.thread.userAvatar,
        ),
        Message(
          id: '6',
          text: 'Cảm ơn bác sĩ rất nhiều ạ!',
          isSentByMe: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 35)),
        ),
        Message(
          id: '7',
          text: 'Bạn cần uống thuốc theo đơn và nghỉ ngơi nhé',
          isSentByMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          senderName: widget.thread.userName,
          senderAvatar: widget.thread.userAvatar,
        ),
      ]);
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _messageController.text.trim(),
          isSentByMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // Auto scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.thread.isExpert
                      ? const Color(0xFF228B22)
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.thread.userAvatar,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.thread.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.thread.isExpert) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: Color(0xFF228B22),
                        ),
                      ],
                    ],
                  ),
                  const Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF228B22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF228B22)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gọi điện thoại')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showAvatar = !message.isSentByMe &&
                    (index == _messages.length - 1 ||
                        _messages[index + 1].isSentByMe);

                return MessageBubble(
                  message: message,
                  showAvatar: showAvatar,
                );
              },
            ),
          ),

          // Message Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF228B22),
                      ),
                      onPressed: () {
                        _showAttachmentOptions(context);
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF228B22),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search, color: Color(0xFF228B22)),
              title: const Text('Tìm kiếm trong cuộc trò chuyện'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tìm kiếm tin nhắn')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
              title: const Text('Tắt thông báo'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã tắt thông báo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Chặn người dùng'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chặn người dùng')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Đính kèm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Thư viện',
                  color: const Color(0xFF228B22),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chọn từ thư viện')),
                    );
                  },
                ),
                _AttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mở camera')),
                    );
                  },
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Tài liệu',
                  color: const Color(0xFFFFA726),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chọn tài liệu')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Message Bubble - Reusable widget
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isSentByMe) ...[
            if (showAvatar)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF228B22),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    message.senderAvatar ?? '?',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? const Color(0xFF228B22)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isSentByMe ? 16 : 4),
                      bottomRight: Radius.circular(message.isSentByMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: message.hasImage
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 200,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (message.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                message.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: message.isSentByMe
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: message.isSentByMe
                                ? Colors.white
                                : const Color(0xFF333333),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          if (message.isSentByMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

// Attachment Option - Reusable widget
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

// Message Model - Reusable
class Message {
  final String id;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? senderName;
  final String? senderAvatar;
  final bool hasImage;

  Message({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.senderName,
    this.senderAvatar,
    this.hasImage = false,
  });
}
