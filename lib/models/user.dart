class SkedUser {
  final String uid;
  final String displayName;
  final String photoURL;

  SkedUser({this.uid, this.displayName, this.photoURL});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'displayName': displayName, 'photoURL': photoURL};
  }

  static SkedUser fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return SkedUser(
        displayName: map['displayName'],
        uid: map['uid'],
        photoURL: map['photoURL']);
  }
}
