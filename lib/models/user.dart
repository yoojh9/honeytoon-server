class User {
  String uid;
  String displayName;
  String email;
  String provider;
  String thumbnail;
  int honey = 0;
  int rank = -1;
  var works = [];

  User(
      {this.uid,
      this.displayName,
      this.email,
      this.provider,
      this.thumbnail,
      this.honey,
      this.rank,
      this.works});


  User.fromMap(String documentId, Map snapshot) {
    this.uid = documentId;
    if (snapshot['displayName'] != null) {
      this.displayName = snapshot['displayName'];
    }
    if (snapshot['email'] !=null) {
      this.email = snapshot['email'];
    }
    if (snapshot['provider'] != null) {
      this.provider = snapshot['provider'];
    }
    if (snapshot['thumbnail'] != null) {
      this.thumbnail = snapshot['thumbnail'];
    }
  }

  @override
  String toString() {
    return "uid: ${this.uid}, user.displayName: ${this.displayName}";
  }
}
