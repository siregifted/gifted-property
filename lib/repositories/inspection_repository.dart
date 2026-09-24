import '../models/inspection.dart';

class InspectionRepository {
  InspectionRepository._();

  static final InspectionRepository instance = InspectionRepository._();

  final List<Inspection> _inspections = [];

  List<Inspection> getInspections() {
    return List.unmodifiable(_inspections);
  }

  void addInspection(Inspection inspection) {
    _inspections.add(inspection);
  }
}
