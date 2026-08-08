import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

@freezed
abstract class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String title,
    String? description,
    @Default('open') String status,
    @Default('medium') String priority,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'assigned_to') List<String>? assignedTo,
    String? department,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    List<String>? tags,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}
