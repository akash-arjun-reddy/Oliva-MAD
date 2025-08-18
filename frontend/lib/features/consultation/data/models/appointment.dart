class Appointment {
  final String id;
  final String doctorName;
  final String treatmentType;
  final String consultationType;
  final String dateTime;
  final String status;
  final String? meetingLink;
  final String? meetingId;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.treatmentType,
    required this.consultationType,
    required this.dateTime,
    required this.status,
    this.meetingLink,
    this.meetingId,
  });

  bool get hasMeetingLink => meetingLink != null && meetingLink!.isNotEmpty;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      treatmentType: json['treatmentType'] ?? '',
      consultationType: json['consultationType'] ?? '',
      dateTime: json['dateTime'] ?? '',
      status: json['status'] ?? '',
      meetingLink: json['meetingLink'],
      meetingId: json['meetingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'treatmentType': treatmentType,
      'consultationType': consultationType,
      'dateTime': dateTime,
      'status': status,
      'meetingLink': meetingLink,
      'meetingId': meetingId,
    };
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctorName: $doctorName, treatmentType: $treatmentType, consultationType: $consultationType, dateTime: $dateTime, status: $status, meetingLink: $meetingLink)';
  }
}
