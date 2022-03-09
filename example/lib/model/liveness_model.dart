class liveness_model {
  String status;
  String errorMessage;
  String imagePath;
  bool livenessStatus;
  String livenessScore;
  String close;

  liveness_model(
      {this.status,
        this.errorMessage,
        this.imagePath,
        this.livenessStatus,
        this.livenessScore,this.close});

  liveness_model.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    errorMessage = json['ErrorMessage'];
    imagePath = json['imagePath'];
    livenessStatus = json['livenessStatus'];
    livenessScore = json['livenessScore'];
    close = json['close'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['ErrorMessage'] = this.errorMessage;
    data['imagePath'] = this.imagePath;
    data['livenessStatus'] = this.livenessStatus;
    data['livenessScore'] = this.livenessScore;
    data['close'] = this.close;
    return data;
  }
}