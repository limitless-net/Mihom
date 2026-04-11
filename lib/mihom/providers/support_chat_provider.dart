import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════
//  工单客服 Provider — 基于 Xboard 工单系统
// ═══════════════════════════════════════════

/// 从异常中提取用户友好的消息
String _friendlyError(dynamic e) {
  final s = e.toString();
  // XBoardException(400): 消息内容  →  只保留中文消息
  final match = RegExp(r'XBoardException\(\d+\):\s*(.+)').firstMatch(s);
  if (match != null) return match.group(1)!.trim();
  // ApiException: 消息内容
  final match2 = RegExp(r'ApiException:\s*(.+)').firstMatch(s);
  if (match2 != null) return match2.group(1)!.trim();
  return s;
}

/// 客服会话状态
class SupportChatState {
  final int? ticketId;
  final List<TicketMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool isClosed;
  final String? error;

  const SupportChatState({
    this.ticketId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isClosed = false,
    this.error,
  });

  SupportChatState copyWith({
    int? ticketId,
    List<TicketMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isClosed,
    String? error,
  }) {
    return SupportChatState(
      ticketId: ticketId ?? this.ticketId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isClosed: isClosed ?? this.isClosed,
      error: error,
    );
  }
}

/// 客服聊天 Notifier
class SupportChatNotifier extends StateNotifier<SupportChatState> {
  Timer? _pollTimer;
  static const _ticketIdKey = 'support_ticket_id';
  static const _pollInterval = Duration(seconds: 5);

  SupportChatNotifier() : super(const SupportChatState());

  /// 初始化 — 查找最近开启的客服工单
  Future<void> init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getInt(_ticketIdKey);
      debugPrint('[SupportChat] init: savedId=$savedId');

      if (savedId != null) {
        try {
          final detail = await XBoardSDK.instance.ticket.getTicket(savedId);
          debugPrint('[SupportChat] init: restored ticket $savedId, messages=${detail.messages.length}, status=${detail.status}');
          if (detail.status == 0) {
            state = state.copyWith(
              ticketId: detail.id,
              messages: detail.messages,
              isClosed: false,
              isLoading: false,
            );
            _startPolling();
            return;
          } else {
            // 工单已关闭，清除保存的 ID
            await prefs.remove(_ticketIdKey);
          }
        } catch (e) {
          debugPrint('[SupportChat] init: failed to restore ticket $savedId: $e');
          await prefs.remove(_ticketIdKey);
        }
      }

      // 查找已有的开启中的客服工单
      final tickets = await XBoardSDK.instance.ticket.getTickets(pageSize: 50);
      debugPrint('[SupportChat] init: found ${tickets.length} tickets');
      final openTicket = tickets.cast<TicketModel?>().firstWhere(
        (t) => t!.subject == '在线客服' && t.status == 0,
        orElse: () => null,
      );

      if (openTicket != null) {
        debugPrint('[SupportChat] init: found open ticket id=${openTicket.id}');
        final detail = await XBoardSDK.instance.ticket.getTicket(openTicket.id);
        debugPrint('[SupportChat] init: detail messages=${detail.messages.length}');
        await prefs.setInt(_ticketIdKey, openTicket.id);
        state = state.copyWith(
          ticketId: openTicket.id,
          messages: detail.messages,
          isClosed: false,
          isLoading: false,
        );
        _startPolling();
      } else {
        debugPrint('[SupportChat] init: no open ticket, showing welcome');
        state = state.copyWith(isLoading: false, isClosed: false);
      }
    } catch (e) {
      debugPrint('[SupportChat] init error: $e');
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    }
  }

  /// 发送文本消息
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true, error: null);
    try {
      if (state.ticketId == null) {
        debugPrint('[SupportChat] Creating ticket...');
        await XBoardSDK.instance.ticket.createTicket('在线客服', text.trim(), 2);
        debugPrint('[SupportChat] Ticket created, fetching list...');
        final tickets = await XBoardSDK.instance.ticket.getTickets(pageSize: 5);
        debugPrint('[SupportChat] Got ${tickets.length} tickets');
        final newTicket = tickets.cast<TicketModel?>().firstWhere(
          (t) => t!.subject == '在线客服' && t.status == 0,
          orElse: () => null,
        );
        if (newTicket != null) {
          debugPrint('[SupportChat] Found ticket id=${newTicket.id}');
          final detail = await XBoardSDK.instance.ticket.getTicket(newTicket.id);
          debugPrint('[SupportChat] Detail: messages=${detail.messages.length}');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_ticketIdKey, newTicket.id);
          state = state.copyWith(
            ticketId: newTicket.id,
            messages: detail.messages,
            isSending: false,
          );
          _startPolling();
        } else {
          debugPrint('[SupportChat] No matching ticket found!');
          state = state.copyWith(isSending: false);
        }
      } else {
        debugPrint('[SupportChat] Replying to ticket ${state.ticketId}...');
        await XBoardSDK.instance.ticket.replyTicket(state.ticketId!, text.trim());
        await _refresh();
        state = state.copyWith(isSending: false);
      }
    } catch (e) {
      debugPrint('[SupportChat] sendMessage error: $e');
      // 回复失败后也要刷新消息（后端可能已有新回复）
      await _refresh();
      state = state.copyWith(isSending: false, error: _friendlyError(e));
    }
  }

  /// 发送图片
  Future<void> sendImage(String filePath) async {
    state = state.copyWith(isSending: true, error: null);
    try {
      final imageUrl = await XBoardSDK.instance.ticket.uploadImage(filePath);
      final message = '[图片] $imageUrl';

      if (state.ticketId == null) {
        await XBoardSDK.instance.ticket.createTicket('在线客服', message, 2);
        final tickets = await XBoardSDK.instance.ticket.getTickets(pageSize: 5);
        final newTicket = tickets.cast<TicketModel?>().firstWhere(
          (t) => t!.subject == '在线客服' && t.status == 0,
          orElse: () => null,
        );
        if (newTicket != null) {
          final detail = await XBoardSDK.instance.ticket.getTicket(newTicket.id);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_ticketIdKey, newTicket.id);
          state = state.copyWith(
            ticketId: newTicket.id,
            messages: detail.messages,
            isSending: false,
          );
          _startPolling();
        }
      } else {
        await XBoardSDK.instance.ticket.replyTicket(state.ticketId!, message);
        await _refresh();
        state = state.copyWith(isSending: false);
      }
    } catch (e) {
      await _refresh();
      state = state.copyWith(isSending: false, error: _friendlyError(e));
    }
  }

  /// 关闭工单 (结束会话)
  Future<void> closeSession() async {
    if (state.ticketId == null) return;
    try {
      await XBoardSDK.instance.ticket.closeTicket(state.ticketId!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ticketIdKey);
      _stopPolling();
      state = state.copyWith(isClosed: true);
    } catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    }
  }

  /// 开始新会话 (关闭后)
  Future<void> newSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ticketIdKey);
    _stopPolling();
    state = const SupportChatState();
  }

  /// 手动刷新
  Future<void> refresh() async {
    state = state.copyWith(error: null);
    await _refresh();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 内部刷新
  Future<void> _refresh() async {
    if (state.ticketId == null) return;
    try {
      final detail = await XBoardSDK.instance.ticket.getTicket(state.ticketId!);
      debugPrint('[SupportChat] _refresh: ticketId=${state.ticketId}, messages=${detail.messages.length}, status=${detail.status}');
      state = state.copyWith(
        messages: detail.messages,
        isClosed: detail.status == 1,
      );
      if (detail.status == 1) {
        _stopPolling();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_ticketIdKey);
      }
    } catch (e) {
      debugPrint('[SupportChat] _refresh error: $e');
    }
  }

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// 暂停轮询（页面关闭时调用）
  void pausePolling() {
    debugPrint('[SupportChat] pausePolling: 聊天窗口关闭，暂停轮询');
    _stopPolling();
  }

  /// 恢复轮询（页面重新打开时调用，仅当工单未关闭时恢复）
  void resumePolling() {
    if (state.ticketId != null && !state.isClosed) {
      debugPrint('[SupportChat] resumePolling: 聊天窗口打开，恢复轮询 ticketId=${state.ticketId}');
      _startPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}

/// Provider
final supportChatProvider =
    StateNotifierProvider<SupportChatNotifier, SupportChatState>(
  (ref) => SupportChatNotifier(),
);
