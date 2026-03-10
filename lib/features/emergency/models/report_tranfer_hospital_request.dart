class ReportTranferHospitalRequest {
  final int hospitalId;
  final double distanceToHospitalKm;
  final String? note;

  ReportTranferHospitalRequest({
    required this.hospitalId,
    required this.distanceToHospitalKm,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'distanceToHospitalKm': distanceToHospitalKm,
      'note': note,
    };
  }
}
