import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_ticket_request.freezed.dart';
part 'update_ticket_request.g.dart';

@freezed
abstract class UpdateTicketRequest with _$UpdateTicketRequest {
  const factory UpdateTicketRequest({
    String? title,
    String? description,
    String? status,
    String? priority,
    @JsonKey(name: 'assigned_to') List<String>? assignedTo,
    String? department,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    List<String>? tags,
  }) = _UpdateTicketRequest;

  factory UpdateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTicketRequestFromJson(json);
}
