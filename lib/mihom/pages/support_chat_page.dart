import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import '../theme/mihom_theme.dart';
import '../i18n.dart';
import '../providers/support_chat_provider.dart';
import 'package:fl_clash/common/common.dart';

// ═══════════════════════════════════════════
//  在线客服页面 — 基于工单的聊天界面
// ═══════════════════════════════════════════

class SupportChatPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isDesktop;

  const SupportChatPage({
    super.key,
    required this.theme,
    this.isDesktop = false,
  });

  @override
  ConsumerState<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends ConsumerState<SupportChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();

  MihomTheme get t => widget.theme;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(supportChatProvider.notifier);
      // 如果已有工单数据，只恢复轮询；否则完整初始化
      if (ref.read(supportChatProvider).ticketId != null) {
        notifier.resumePolling();
      } else {
        notifier.init();
      }
    });
  }

  @override
  void dispose() {
    // 关闭聊天窗口时暂停轮询
    ref.read(supportChatProvider.notifier).pausePolling();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    // 保持输入框焦点
    _focusNode.requestFocus();
    await ref.read(supportChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    await ref.read(supportChatProvider.notifier).sendImage(picked.path);
    _scrollToBottom();
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    await ref.read(supportChatProvider.notifier).sendImage(picked.path);
    _scrollToBottom();
  }

  void _showAttachMenu() {
    if (widget.isDesktop) {
      // 桌面端：居中弹窗
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: t.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.isEn ? 'Send Attachment' : '发送附件',
                  style: TextStyle(color: t.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _attachOption(Icons.photo_library_rounded, S.isEn ? 'Album' : '相册', _pickImage),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    } else {
      // 移动端：底部弹窗
      showModalBottomSheet(
        context: context,
        backgroundColor: t.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachOption(Icons.photo_library_rounded, S.isEn ? 'Album' : '相册', _pickImage),
                _attachOption(Icons.camera_alt_rounded, S.isEn ? 'Camera' : '拍照', _takePhoto),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _attachOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: t.buttonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(supportChatProvider);

    // 当消息更新时滚动到底部
    ref.listen(supportChatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      // 错误提示 3 秒后自动消失
      if (next.error != null && prev?.error == null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ref.read(supportChatProvider.notifier).clearError();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: widget.isDesktop
          ? null
          : AppBar(
              backgroundColor: t.scaffoldBg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                S.onlineSupport,
                style: TextStyle(color: t.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                if (chatState.ticketId != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: t.textPrimary),
                    color: t.cardBg,
                    onSelected: (v) {
                      if (v == 'close') _confirmClose();
                      if (v == 'new') ref.read(supportChatProvider.notifier).newSession();
                    },
                    itemBuilder: (ctx) => [
                      if (!chatState.isClosed)
                        PopupMenuItem(
                          value: 'close',
                          child: Row(
                            children: [
                              Icon(Icons.close_rounded, size: 18, color: t.danger),
                              const SizedBox(width: 8),
                              Text(S.isEn ? 'End Session' : '结束会话',
                                style: TextStyle(color: t.danger)),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'new',
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 18, color: t.primary),
                            const SizedBox(width: 8),
                            Text(S.isEn ? 'New Session' : '新建会话',
                              style: TextStyle(color: t.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      body: Column(
        children: [
          // ── 桌面端标题栏 ──
          if (widget.isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: t.cardBg,
                border: Border(bottom: BorderSide(color: t.textHint.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: t.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(S.onlineSupport,
                    style: TextStyle(color: t.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (chatState.ticketId != null && !chatState.isClosed)
                    TextButton.icon(
                      onPressed: _confirmClose,
                      icon: Icon(Icons.close_rounded, size: 16, color: t.danger),
                      label: Text(S.isEn ? 'End' : '结束',
                        style: TextStyle(color: t.danger, fontSize: 13)),
                    ),
                  if (chatState.ticketId != null)
                    TextButton.icon(
                      onPressed: () => ref.read(supportChatProvider.notifier).newSession(),
                      icon: Icon(Icons.add_rounded, size: 16, color: t.primary),
                      label: Text(S.isEn ? 'New' : '新建',
                        style: TextStyle(color: t.primary, fontSize: 13)),
                    ),
                ],
              ),
            ),

          // ── 消息列表 ──
          Expanded(
            child: chatState.isLoading
                ? Center(child: CircularProgressIndicator(color: t.primary))
                : chatState.messages.isEmpty && chatState.ticketId == null
                    ? _buildWelcome()
                    : _buildMessageList(chatState),
          ),

          // ── 已关闭提示 ──
          if (chatState.isClosed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: t.cardBg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: t.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    S.isEn ? 'Session ended' : '会话已结束',
                    style: TextStyle(color: t.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => ref.read(supportChatProvider.notifier).newSession(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      S.isEn ? 'New Session' : '新建会话',
                      style: TextStyle(color: t.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // ── 错误提示 (SnackBar 风格，不占输入焦点) ──
          if (chatState.error != null)
            Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: t.danger.withOpacity(0.08),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: t.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: TextStyle(color: t.danger, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(supportChatProvider.notifier).clearError(),
                      child: Icon(Icons.close_rounded, color: t.danger.withOpacity(0.6), size: 16),
                    ),
                  ],
                ),
              ),
            ),

          // ── 输入栏 ──
          if (!chatState.isClosed) _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: t.buttonGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              S.isEn ? 'How can we help?' : '您好，有什么可以帮您？',
              style: TextStyle(color: t.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              S.isEn
                  ? 'Send a message to start the conversation'
                  : '发送消息开始对话，客服会尽快回复',
              style: TextStyle(color: t.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(SupportChatState chatState) {
    final messages = chatState.messages;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (ctx, index) {
        final msg = messages[index];
        final isMe = msg.isMe;
        return _buildBubble(msg, isMe);
      },
    );
  }

  /// 解析消息: 支持 "[图片] URL" 格式
  Widget _buildBubble(TicketMessageModel msg, bool isMe) {
    final imageMatch = RegExp(r'^\[图片\]\s*(.+)$', multiLine: true).firstMatch(msg.message);
    final hasImage = imageMatch != null;
    final imageUrl = hasImage ? imageMatch.group(1)!.trim() : null;
    // 提取图片之外的文字部分
    final textPart = hasImage
        ? msg.message.replaceFirst(RegExp(r'^\[图片\]\s*.+\n?'), '').trim()
        : msg.message;

    // Resolve relative image URL to absolute
    String? resolvedImageUrl;
    if (imageUrl != null) {
      if (imageUrl.startsWith('http')) {
        resolvedImageUrl = imageUrl;
      } else {
        // 相对 URL → 使用 SDK baseUrl
        final base = XBoardSDK.instance.baseUrl ?? '';
        resolvedImageUrl = '$base$imageUrl';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: t.primary.withOpacity(0.15),
              child: Icon(Icons.support_agent_rounded, size: 18, color: t.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: widget.isDesktop ? 400 : 260),
              decoration: BoxDecoration(
                color: isMe ? t.primary.withOpacity(0.12) : t.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: t.textHint.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resolvedImageUrl != null)
                    GestureDetector(
                      onTap: () => _showFullImage(resolvedImageUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          resolvedImageUrl,
                          width: widget.isDesktop ? 280 : 180,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              width: 180, height: 120,
                              child: Center(child: CircularProgressIndicator(
                                color: t.primary,
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                    : null,
                              )),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 180, height: 80,
                            decoration: BoxDecoration(
                              color: t.textHint.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.broken_image_rounded, color: t.textHint),
                          ),
                        ),
                      ),
                    ),
                  if (resolvedImageUrl != null && textPart.isNotEmpty)
                    const SizedBox(height: 6),
                  if (textPart.isNotEmpty)
                    Text(
                      textPart,
                      style: TextStyle(
                        color: isMe ? t.textPrimary : t.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.createdAt),
                    style: TextStyle(color: t.textHint, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: t.primary.withOpacity(0.15),
              child: Icon(Icons.person_rounded, size: 18, color: t.primary),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            child: Image.network(url),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(SupportChatState chatState) {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 8, top: 8,
        bottom: MediaQuery.of(context).viewPadding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: t.cardBg,
        border: Border(top: BorderSide(color: t.textHint.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // 附件按钮
          IconButton(
            onPressed: chatState.isSending ? null : _showAttachMenu,
            icon: Icon(Icons.add_circle_outline_rounded, color: t.textSecondary, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          // 输入框
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: TextStyle(color: t.textPrimary, fontSize: 15),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: S.isEn ? 'Type a message...' : '输入消息...',
                hintStyle: TextStyle(color: t.textHint, fontSize: 14),
                filled: true,
                fillColor: t.scaffoldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // 发送按钮
          GestureDetector(
            onTap: chatState.isSending ? null : _sendMessage,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: t.buttonGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: chatState.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _confirmClose() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardBg,
        title: Text(S.isEn ? 'End Session?' : '结束会话？',
          style: TextStyle(color: t.textPrimary)),
        content: Text(
          S.isEn
              ? 'The conversation will be closed. You can start a new one later.'
              : '对话将会关闭，之后可以开始新的会话。',
          style: TextStyle(color: t.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel, style: TextStyle(color: t.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(supportChatProvider.notifier).closeSession();
            },
            child: Text(S.confirm, style: TextStyle(color: t.danger)),
          ),
        ],
      ),
    );
  }
}
