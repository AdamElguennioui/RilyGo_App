import '../models/mission.dart';

class MissionService {
  final List<Mission> missions = [];

  Mission createMission(String category, String address, DateTime dateTime, String note) {
    final mission = Mission(
      category: category,
      address: address,
      dateTime: dateTime,
      note: note,
    );
    missions.add(mission);
    return mission;
  }

  List<Mission> getMissions() => missions;

  void updateMissionStatus(Mission mission, String status) {
    mission.status = status;
  }
}
