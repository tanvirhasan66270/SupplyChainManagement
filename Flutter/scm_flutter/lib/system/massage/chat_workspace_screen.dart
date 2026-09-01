import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/system/massage/message_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class ChatWorkspaceScreen extends ConsumerWidget {
  const ChatWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DynamicScmTopNavBar(
        showBackButton: true,
        title: 'Chat Workspace',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const _WideChatLayout();
          } else {
            return const _NarrowChatLayout();
          }
        },
      ),
    );
  }
}

class _WideChatLayout extends ConsumerWidget {
  const _WideChatLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = ref.watch(selectedContactProvider);

    return Row(
      children: [
        const SizedBox(
          width: 340,
          child: _ChatSidebar(),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: selectedContact == null
              ? const _ChatPlaceholder()
              : _ChatDetail(key: ValueKey(selectedContact.contactId), contact: selectedContact),
        ),
      ],
    );
  }
}

class _NarrowChatLayout extends ConsumerWidget {
  const _NarrowChatLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = ref.watch(selectedContactProvider);

    if (selectedContact != null) {
      return _ChatDetail(
        key: ValueKey(selectedContact.contactId),
        contact: selectedContact,
        onBack: () => ref.read(selectedContactProvider.notifier).state = null,
      );
    }
    return const _ChatSidebar();
  }
}

class _ChatSidebar extends ConsumerStatefulWidget {
  const _ChatSidebar();

  @override
  ConsumerState<_ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<_ChatSidebar> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ').trim();
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cleaned.substring(0, cleaned.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getRoleAvatarBg(String role) {
    final r = role.toUpperCase();
    if (r.contains('CUSTOMER')) return const Color(0xFFE0F2FE);
    if (r.contains('LOGISTICS')) return const Color(0xFFF3E8FF);
    if (r.contains('SALES')) return const Color(0xFFDCFCE7);
    if (r.contains('PROCUREMENT')) return const Color(0xFFFEF3C7);
    if (r.contains('MANAGER') || r.contains('ADMIN')) return const Color(0xFFFEE2E2);
    return const Color(0xFFDBEAFE);
  }

  Color _getRoleAvatarText(String role) {
    final r = role.toUpperCase();
    if (r.contains('CUSTOMER')) return const Color(0xFF0284C7);
    if (r.contains('LOGISTICS')) return const Color(0xFF7E22CE);
    if (r.contains('SALES')) return const Color(0xFF15803D);
    if (r.contains('PROCUREMENT')) return const Color(0xFFD97706);
    if (r.contains('MANAGER') || r.contains('ADMIN')) return const Color(0xFFDC2626);
    return const Color(0xFF1D4ED8);
  }

  Color _getRoleBadgeBg(String role) {
    final r = role.toUpperCase();
    if (r.contains('CUSTOMER')) return const Color(0xFFECFEFF);
    if (r.contains('LOGISTICS')) return const Color(0xFFFAF5FF);
    if (r.contains('SALES')) return const Color(0xFFF0FDF4);
    if (r.contains('PROCUREMENT')) return const Color(0xFFFFFBEB);
    if (r.contains('MANAGER') || r.contains('ADMIN')) return const Color(0xFFFEF2F2);
    return const Color(0xFFEFF6FF);
  }

  Color _getRoleBadgeBorder(String role) {
    final r = role.toUpperCase();
    if (r.contains('CUSTOMER')) return const Color(0xFFA5F3FC);
    if (r.contains('LOGISTICS')) return const Color(0xFFE9D5FF);
    if (r.contains('SALES')) return const Color(0xFF86EFAC);
    if (r.contains('PROCUREMENT')) return const Color(0xFFFDE68A);
    if (r.contains('MANAGER') || r.contains('ADMIN')) return const Color(0xFFFECACA);
    return const Color(0xFFBFDBFE);
  }

  Color _getRoleBadgeText(String role) {
    final r = role.toUpperCase();
    if (r.contains('CUSTOMER')) return const Color(0xFF0891B2);
    if (r.contains('LOGISTICS')) return const Color(0xFF9333EA);
    if (r.contains('SALES')) return const Color(0xFF16A34A);
    if (r.contains('PROCUREMENT')) return const Color(0xFFB45309);
    if (r.contains('MANAGER') || r.contains('ADMIN')) return const Color(0xFFB91C1C);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final chatlistAsync = ref.watch(chatlistProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        // Role Connected Header Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.forum_outlined, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Connected Contacts (${currentUser?.name ?? "User"})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: AppTheme.secondary),
                tooltip: 'Refresh Contacts',
                onPressed: () => ref.invalidate(chatlistProvider),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search contacts by name or role...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),

        // Contacts List
        Expanded(
          child: chatlistAsync.when(
            data: (contacts) {
              final filtered = contacts.where((c) {
                if (_searchQuery.isEmpty) return true;
                return c.contactName.toLowerCase().contains(_searchQuery) ||
                    c.role.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty ? 'No contacts available for your role' : 'No contacts found matching "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(chatlistProvider.future),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1, indent: 72, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final isSelected = ref.watch(selectedContactProvider)?.contactId == contact.contactId;

                    return ListTile(
                      onTap: () {
                        ref.read(selectedContactProvider.notifier).state = contact;
                      },
                      selected: isSelected,
                      selectedTileColor: AppTheme.primary.withValues(alpha: 0.08),
                      leading: CircleAvatar(
                        backgroundColor: _getRoleAvatarBg(contact.role),
                        radius: 20,
                        child: Text(
                          _getInitials(contact.contactName),
                          style: TextStyle(color: _getRoleAvatarText(contact.role), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      title: Text(
                        contact.contactName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleBadgeBg(contact.role),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _getRoleBadgeBorder(contact.role)),
                              ),
                              child: Text(
                                contact.role.toUpperCase(),
                                style: TextStyle(color: _getRoleBadgeText(contact.role), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (contact.unreadCount > 0) ...[
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                contact.unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(apiErrorMessage(e), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.red)))),
          ),
        ),
      ],
    );
  }
}

class _ChatDetail extends ConsumerStatefulWidget {
  const _ChatDetail({super.key, required this.contact, this.onBack});
  final ChatContactModel contact;
  final VoidCallback? onBack;

  @override
  ConsumerState<_ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends ConsumerState<_ChatDetail> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  String _selectedPriority = MessagePriority.medium;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // 3-Second Real-Time Auto Polling for new messages matching Angular MassageComponent logic
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        ref.invalidate(chatHistoryProvider(widget.contact.contactId));
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = ref.read(currentUserProvider);
    final textToSend = text;
    _msgController.clear(); // Immediate UI clear for snappy experience

    setState(() => _isSending = true);
    final currentContext = context;

    try {
      final repo = ref.read(messageRepositoryProvider);
      await repo.sendMessage(
        MessageRequestModel(
          recipientId: widget.contact.contactId,
          subject: 'Chat Message',
          body: textToSend,
          priority: _selectedPriority,
        ),
        userId: currentUser?.userId.toString(),
      );

      ref.invalidate(chatHistoryProvider(widget.contact.contactId));
      ref.invalidate(chatlistProvider);
      _scrollToBottom();
    } catch (e) {
      _msgController.text = textToSend; // Restore text on error
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _markUnreadAsRead(List<MessageResponseModel> messages) {
    final currentUser = ref.read(currentUserProvider);
    final repo = ref.read(messageRepositoryProvider);
    for (final m in messages) {
      if (m.senderId == widget.contact.contactId && m.status == MessageStatus.unread) {
        repo.markAsRead(m.id, userId: currentUser?.userId.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(chatHistoryProvider(widget.contact.contactId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: widget.onBack,
              )
            : null,
        titleSpacing: widget.onBack != null ? 0 : 16,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    widget.contact.contactName.isNotEmpty
                        ? widget.contact.contactName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.contactName,
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.contact.role.toUpperCase()} • Active Connection',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.secondary),
            tooltip: 'Refresh History',
            onPressed: () => ref.invalidate(chatHistoryProvider(widget.contact.contactId)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: historyAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 54, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'No message history yet',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Send a message below to start the conversation.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                _markUnreadAsRead(messages);
                _scrollToBottom();

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(chatHistoryProvider(widget.contact.contactId).future),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId != widget.contact.contactId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (msg.priority == MessagePriority.high) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: isMe ? 0.3 : 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'HIGH PRIORITY',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.red,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              Text(
                                msg.body,
                                style: TextStyle(
                                  color: isMe ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 13.5,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatMsgTime(msg.createdAt),
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.grey,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      msg.status == MessageStatus.read ? Icons.done_all : Icons.done,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(apiErrorMessage(e), style: const TextStyle(fontSize: 12, color: Colors.red))),
            ),
          ),

          // Message Input Field & Priority Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                // Priority Selector Popup
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.flag_rounded,
                    size: 20,
                    color: _selectedPriority == MessagePriority.high
                        ? Colors.red
                        : (_selectedPriority == MessagePriority.medium ? AppTheme.warning : Colors.grey),
                  ),
                  tooltip: 'Message Priority',
                  onSelected: (p) => setState(() => _selectedPriority = p),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: MessagePriority.low, child: Text('Low Priority', style: TextStyle(fontSize: 12))),
                    const PopupMenuItem(value: MessagePriority.medium, child: Text('Medium Priority', style: TextStyle(fontSize: 12))),
                    const PopupMenuItem(value: MessagePriority.high, child: Text('High Priority', style: TextStyle(fontSize: 12, color: Colors.red))),
                  ],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _isSending ? Colors.grey : const Color(0xFF2563EB),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _isSending ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMsgTime(String rawTime) {
    if (rawTime.isEmpty) return '';
    try {
      if (rawTime.contains('T')) {
        final dt = DateTime.parse(rawTime);
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
      }
      return rawTime;
    } catch (_) {
      return rawTime;
    }
  }
}

class _ChatPlaceholder extends ConsumerWidget {
  const _ChatPlaceholder();

  String _getEmptyStatePlaceholder(String role) {
    final r = role.toUpperCase();
    if (r.contains('SUPPLIER')) {
      return 'Choose a Procurement or Manager from the chat list sidebar to pull credentials and retrieve message records.';
    } else if (r.contains('CUSTOMER')) {
      return 'Choose a Sales Officer from the chat list sidebar to pull credentials and retrieve message records.';
    } else if (r.contains('DRIVER')) {
      return 'Choose a Driver, Logistics Officer, Sales Officer, or Customer from the sidebar to chat.';
    } else {
      return 'Choose a contact from the chat list sidebar to pull credentials and retrieve message records.';
    }
  }

  String _getEmptyStateSubtext(String role) {
    final r = role.toUpperCase();
    if (r.contains('SUPPLIER')) {
      return 'Only connected Procurement and Manager roles are linked in this portal.';
    } else if (r.contains('CUSTOMER')) {
      return 'Only connected Sales Officer roles are linked in this portal.';
    } else if (r.contains('DRIVER')) {
      return 'Drivers can only communicate with Logistics, Sales, Customers, and other Drivers.';
    } else {
      return 'Only connected contact roles are linked in this portal.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userRole = currentUser?.role ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primary, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a Conversation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.dark),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStatePlaceholder(userRole),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _getEmptyStateSubtext(userRole),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
