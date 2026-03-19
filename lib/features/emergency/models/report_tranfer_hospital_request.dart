class ReportTranferHospitalRequest {
  final int hospitalId;
  final String? notes;

  ReportTranferHospitalRequest({required this.hospitalId, this.notes});

  Map<String, dynamic> toJson() {
    return {'hospitalId': hospitalId, if (notes != null) 'notes': notes};
  }
}
