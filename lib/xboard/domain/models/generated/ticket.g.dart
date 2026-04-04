// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainTicket _$DomainTicketFromJson(Map<String, dynamic> json) =>
    _DomainTicket(
      id: (json['id'] as num).toInt(),
      subject: json['subject'] as String,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DomainTicketToJson(_DomainTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'priority': instance.priority,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.pending: 'pending',
  TicketStatus.replied: 'replied',
  TicketStatus.closed: 'closed',
};

_TicketMessage _$TicketMessageFromJson(Map<String, dynamic> json) =>
    _TicketMessage(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String,
      isFromUser: json['isFromUser'] as bool? ?? true,
      isRead: json['isRead'] as bool? ?? false,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TicketMessageToJson(_TicketMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isFromUser': instance.isFromUser,
      'isRead': instance.isRead,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };
