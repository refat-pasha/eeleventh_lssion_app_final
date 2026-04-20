class AssignmentSubmissionModel {
  final String id;
  final String assignmentId;
  final String userId;
  final String courseId;

  final String answer;
  final String? fileUrl;

  final int? marks;
  final String feedback;
  final String status;

  final DateTime submittedAt;
  final DateTime? gradedAt;

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.userId,
    required this.courseId,
    required this.answer,
    this.fileUrl,
    this.marks,
    required this.feedback,
    required this.status,
    required this.submittedAt,
    this.gradedAt,
  });

  factory AssignmentSubmissionModel.fromMap(
      Map<String, dynamic> map, String id) {
    return AssignmentSubmissionModel(
      id: id,
      assignmentId: map['assignmentId'] ?? "",
      userId: map['userId'] ?? "",
      courseId: map['courseId'] ?? "",
      answer: map['answer'] ?? "",
      fileUrl: map['fileUrl'],

      marks: map['marks'],
      feedback: map['feedback'] ?? "",
      status: map['status'] ?? "submitted",

      submittedAt: map['submittedAt'] != null
          ? map['submittedAt'].toDate()
          : DateTime.now(),

      gradedAt: map['gradedAt'] != null
          ? map['gradedAt'].toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "assignmentId": assignmentId,
      "userId": userId,
      "courseId": courseId,
      "answer": answer,
      "fileUrl": fileUrl,
      "marks": marks,
      "feedback": feedback,
      "status": status,
      "submittedAt": submittedAt,
      "gradedAt": gradedAt,
    };
  }
}