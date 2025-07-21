import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({super.key, required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final IO.Socket _socket = IO.io('http://172.16.0.2:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  String _typingUser = '';
  bool _isTyping = false;

  // Helper to get initials for avatar
  String _getInitials(String username) {
    return username.isNotEmpty
        ? username.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
  }

  // Helper to get current time as string
  String _getTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socket.connect();
    _socket.emit('add user', widget.username);
    _socket.on('login', (data) {
      setState(() {
        _messages.add({
          'message': 'Welcome to the chat!',
          'username': 'System',
          'isSystem': true,
          'time': _getTime(),
        });
      });
    });
    _socket.on('user joined', (data) {
      setState(() {
        _messages.add({
          'message': '${data['username']} joined',
          'username': 'System',
          'isSystem': true,
          'time': _getTime(),
        });
      });
    });
    _socket.on('user left', (data) {
      setState(() {
        _messages.add({
          'message': '${data['username']} left',
          'username': 'System',
          'isSystem': true,
          'time': _getTime(),
        });
      });
    });
    _socket.on('new message', (data) {
      setState(() {
        _messages.add({
          'message': data['message'],
          'username': data['username'],
          'isSystem': false,
          'time': _getTime(),
        });
      });
    });
    _socket.on('typing', (data) {
      setState(() {
        _typingUser = data['username'];
      });
    });
    _socket.on('stop typing', (data) {
      setState(() {
        _typingUser = '';
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socket.emit('new message', _messageController.text);
      _messageController.clear();
      _socket.emit('stop typing');
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _handleTyping(String value) {
    if (value.isNotEmpty && !_isTyping) {
      _socket.emit('typing');
      setState(() {
        _isTyping = true;
      });
    } else if (value.isEmpty && _isTyping) {
      _socket.emit('stop typing');
      setState(() {
        _isTyping = false;
      });
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    if (message['isSystem'] == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message['message'],
              style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isMe ? 40 : 8,
          right: isMe ? 8 : 40,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueGrey[200],
                child: Text(_getInitials(message['username'])),
              ),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blueAccent : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.blueAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['time'] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 8),
            if (isMe)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueAccent,
                child: Text(_getInitials(message['username']), style: const TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blueGrey[200],
            child: Text(_getInitials(_typingUser)),
          ),
          const SizedBox(width: 8),
          const _AnimatedTypingDots(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;
    final chatWidth = isWide ? 600.0 : double.infinity;
    final horizontalPadding = isWide ? (size.width - chatWidth) / 2 : 0.0;
    final verticalPadding = isWide ? 32.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.username}'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: chatWidth),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: false,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message['username'] == widget.username && !message['isSystem'];
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
                    ),
                    if (_typingUser.isNotEmpty) _buildTypingIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type a message...',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: _handleTyping,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: _sendMessage,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.send, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }
}

// Animated typing dots widget
class _AnimatedTypingDots extends StatefulWidget {
  const _AnimatedTypingDots();
  @override
  State<_AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<_AnimatedTypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _animation = Tween<double>(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int dots = (_animation.value).floor() + 1;
        return Row(
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: i < dots ? 1 : 0.3,
                child: const Text(".", style: TextStyle(fontSize: 28, color: Colors.blueAccent)),
              ),
            );
          }),
        );
      },
    );
  }
}