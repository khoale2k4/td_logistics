import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/contact/chat_box.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';

class ChatListScreen extends StatefulWidget {
  final Function(String, String) sendMessage;
  const ChatListScreen({super.key, required this.sendMessage});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    print("CHat Init");
    context.read<GetChatsBloc>().add(const GetChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          context.tr("chat.chatList"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<GetChatsBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderFeeCalculating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetChatsSuccess) {
            if (state.chats.isEmpty) {
              return _buildEmptyChatList();
            }
            return Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      return _buildChatCard(chat.toJson());
                    },
                  ),
                ),
              ],
            );
          } else if (state is GetChatsFailure) {
            return Center(
              child: Text(
                'Lỗi khi tải danh sách trò chuyện: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return Center(child: Text(context.tr('chat.loading')));
        },
      ),
    );
  }

  Widget _buildEmptyChatList() {
    return Center(
      child: Text(
        context.tr('chat.noChat'),
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30, // Tăng bán kính của avatar
          backgroundColor: Colors.blueGrey,
          child: Text(
            (chat['fullname'] ?? "Null")[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24, // Tăng kích thước chữ
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${chat['fullname']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // Tăng kích thước chữ
          ),
        ),
        subtitle: chat['lastMessage'] != null
            ? Text(
                chat['lastMessage'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16, // Tăng kích thước chữ
                ),
              )
            : Container(),
        trailing: Text(
          _formatTimestamp(DateTime.parse(chat['lastMessageTime'] ?? "...")),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14, // Tăng kích thước chữ
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                theirName: chat['fullname'] ?? "No Name",
                theirPhone: chat['phone'] ?? "No Phone",
                receiverId: chat['id'] ?? "No id",
                sendMessage: widget.sendMessage,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return context.tr("chat.now");
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${context.tr("chat.minuteBefore")}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${context.tr("chat.hourBefore")}';
    } else {
      return '${difference.inDays} ${context.tr("chat.dayBefore")}';
    }
  }
}
