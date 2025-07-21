import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _usernameController = TextEditingController();

  final List<String> _users = [
    'Kartheek',
    'Akash',
    'Riya',
    'Ajit',
    'Deepankar',
  ];

  void _showLoginBottomSheet(String selectedUser) {
    _usernameController.text = selectedUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final isWide = size.width > 600;
        final cardWidth = isWide ? 400.0 : double.infinity;
        return Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: isWide ? (size.width - cardWidth) / 2 : 0,
              right: isWide ? (size.width - cardWidth) / 2 : 0,
              top: isWide ? 60 : 0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth, minWidth: isWide ? 350 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Your Nickname',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose a nickname to join the chat',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Nickname',
                            labelStyle: const TextStyle(color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.blueGrey[50],
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 32),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_usernameController.text.isNotEmpty) {
                                  Navigator.pop(context); // Close bottom sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(username: _usernameController.text),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                              ).copyWith(
                                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered)) {
                                      return Colors.blueAccent.withOpacity(0.15);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              child: const Text('Enter'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.blueAccent, size: 26),
                        splashRadius: 22,
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final cardWidth = isWide ? 500.0 : double.infinity;
    final horizontalPadding = isWide ? (size.width - cardWidth) / 2 : 24.0;
    final verticalPadding = isWide ? 48.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBox'),
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
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Material(
                            color: Colors.transparent,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showLoginBottomSheet(user),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blueAccent.withOpacity(0.15),
                                      child: Text(
                                        user[0],
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Text(
                                        user,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
    _usernameController.dispose();
    super.dispose();
  }
}