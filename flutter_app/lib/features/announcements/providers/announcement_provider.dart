import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/dashboard_provider.dart'
    show dioClientProvider;
import '../data/announcement_api.dart';
import '../data/announcement_repository.dart';
import '../models/announcement.dart';

final announcementApiProvider = Provider<AnnouncementApi>((ref) {
  return AnnouncementApi(ref.read(dioClientProvider));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(ref.read(announcementApiProvider));
});

enum AnnouncementState { initial, loading, loaded, empty, error }

class AnnouncementNotifier extends Notifier<AnnouncementState> {
  List<Announcement>? _data;
  String? _errorMessage;

  List<Announcement>? get data => _data;
  String? get errorMessage => _errorMessage;

  @override
  AnnouncementState build() {
    return AnnouncementState.initial;
  }

  Future<void> loadAnnouncements() async {
    state = AnnouncementState.loading;
    try {
      final announcements = await ref
          .read(announcementRepositoryProvider)
          .getAnnouncements();
      _data = announcements;

      if (_data!.isEmpty) {
        state = AnnouncementState.empty;
      } else {
        state = AnnouncementState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      state = AnnouncementState.error;
    }
  }

  Future<void> refreshAnnouncements() async {
    await loadAnnouncements();
  }

  Future<void> retry() async {
    await loadAnnouncements();
  }
}

final announcementProvider =
    NotifierProvider<AnnouncementNotifier, AnnouncementState>(() {
      return AnnouncementNotifier();
    });

final announcementDetailProvider = FutureProvider.family<Announcement, String>((
  ref,
  id,
) async {
  return ref.read(announcementRepositoryProvider).getAnnouncement(id);
});
