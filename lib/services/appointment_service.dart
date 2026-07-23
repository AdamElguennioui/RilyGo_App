import '../data/remote/api_client.dart';
import '../models/mission.dart';

/// Talks to the real backend /appointment endpoints.
/// Returns Mission objects so existing UI screens need no changes.
class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  /// CLIENT — fetch their own appointments.
  Future<List<Mission>> getClientAppointments(int userId) async {
    final data = await ApiClient().get('/appointment/all');
    final list = data['data'] as List<dynamic>? ?? (data is List ? data as List : []);
    return list
        .map((e) => Mission.fromAppointmentJson(e as Map<String, dynamic>))
        .where((m) => m.clientId == userId.toString())
        .toList();
  }

  /// SALON/Employee — fetch appointments assigned to them.
  Future<List<Mission>> getAgentAppointments(int employeeId) async {
    final data = await ApiClient().get('/appointment/all');
    final list = data['data'] as List<dynamic>? ?? (data is List ? data as List : []);
    return list
        .map((e) => Mission.fromAppointmentJson(e as Map<String, dynamic>))
        .where((m) => m.agentId == employeeId.toString())
        .toList();
  }

  /// All available (PENDING) appointments.
  Future<List<Mission>> getAvailableAppointments() async {
    final data = await ApiClient().get('/appointment/all');
    final list = data['data'] as List<dynamic>? ?? (data is List ? data as List : []);
    return list
        .map((e) => Mission.fromAppointmentJson(e as Map<String, dynamic>))
        .where((m) => m.status == MissionStatus.created)
        .toList();
  }

  /// Get single appointment detail.
  Future<Mission> getAppointment(int id, int userId) async {
    final data = await ApiClient().get('/appointment/details/$id');
    return Mission.fromAppointmentJson(data);
  }

  /// CLIENT — book a new appointment.
  Future<Mission> bookAppointment({
    required int userId,
    required int salonId,
    required int serviceId,
    required int employeeId,
    required DateTime date,
    String? note,
  }) async {
    final data = await ApiClient().post('/appointment/book', {
      'userId': userId,
      'salonId': salonId,
      'serviceId': serviceId,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return Mission.fromAppointmentJson(data);
  }

  /// SALON — confirm an appointment.
  Future<void> confirmAppointment(int id, int salonUserId) async {
    await ApiClient().patch('/appointment/confirm/$id');
  }

  /// Cancel an appointment (CLIENT or SALON).
  Future<void> cancelAppointment(int id, {String? note}) async {
    await ApiClient().patch('/appointment/cancel/$id', {
      'note': ?note,
    });
  }

  /// SALON — mark appointment completed.
  Future<void> completeAppointment(int id, {String? note}) async {
    await ApiClient().patch('/appointment/complete/$id', {
      'note': ?note,
    });
  }
}
