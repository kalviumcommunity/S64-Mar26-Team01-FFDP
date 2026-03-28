import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/realtime_service.dart';
import '../../services/auth_service.dart';
import 'realtime_chat_screen.dart';

/// Real-time chat list screen that shows all conversations for a user.
/// This screen demonstrates:
/// - Using StreamBuilder for real-time chat list updates
/// - Proper loading, error, and empty states
/// - Navigation to individual chat screens
class RealtimeChatListScreen extends StatelessWidget {
  const RealtimeChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final realtimeService = RealtimeService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: const Center(
          child: Text('Please sign in to view your messages'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: realtimeService.getUserChatsStream(currentUser.uid),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading chats',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Force rebuild
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with someone!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          // Success state - render chat list
          final chats = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _ChatListItem(
                  chat: chat,
                  currentUserId: currentUser.uid,
                  onTap: () {
                    // Navigate to chat screen
                    final otherUserId = (chat['participants'] as List)
                        .firstWhere((id) => id != currentUser.uid);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeChatScreen(
                          chatId: chat['chatId'] as String,
                          otherUserName: otherUserId.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start a new conversation from the community tab'),
            ),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

/// Individual chat list item widget
class _ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String currentUserId;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participants = chat['participants'] as List? ?? [];
    final otherUserId = participants.isNotEmpty
        ? participants.firstWhere(
            (id) => id != currentUserId,
            orElse: () => 'unknown',
          )
        : 'unknown';

    final lastMessage = chat['lastMessage'] as String? ?? 'No messages yet';
    final lastMessageTime = (chat['lastMessageTime'] as Timestamp?)?.toDate();
    final hasUnread = chat['unreadCount'] != null && chat['unreadCount'] > 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          otherUserId.toString().isNotEmpty
              ? otherUserId.toString()[0].toUpperCase()
              : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        otherUserId.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread ? Colors.black87 : Colors.grey[600],
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: hasUnread
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chat['unreadCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
