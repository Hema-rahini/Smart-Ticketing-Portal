import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ticket_request.freezed.dart';
part 'create_ticket_request.g.dart';

@freezed
abstract class CreateTicketRequest with _$CreateTicketRequest {
  const factory CreateTicketRequest({
    required String title,
    String? description,
    @Default('open') String status,
    @Default('medium') String priority,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'assigned_to') List<String>? assignedTo,
    String? department,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    List<String>? tags,
  }) = _CreateTicketRequest;

  factory CreateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketRequestFromJson(json);
}
