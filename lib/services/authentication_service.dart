import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:sked/models/user.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '48024952145-th5qtds2rei2e9bvv2eclr96h4n9c9jc.apps.googleusercontent.com',
    scopes: <String>['https://www.googleapis.com/auth/calendar'],
  );

  SkedUser _currentUser;
  SkedUser get currentUser => getSkedUser();
  GoogleSignIn get googleSignin => _googleSignIn;

  AuthClient _authClient;

  AuthClient get authClient => _authClient;

  SkedUser getSkedUser() {
    var user = _firebaseAuth.currentUser;
    if (user != null) {
      setSkedUser(user);
      return _currentUser;
    } else {
      return null;
    }
  }

  void setSkedUser(User user) {
    _currentUser = SkedUser(
        displayName: user.displayName, uid: user.uid, photoURL: user.photoURL);
  }

  Future signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential authResult =
        await _firebaseAuth.signInWithCredential(credential);

    User _user = authResult.user;

    assert(!_user.isAnonymous);

    assert(await _user.getIdToken() != null);

    User fbUser = _firebaseAuth.currentUser;

    assert(_user.uid == fbUser.uid);

    _authClient = await googleSignin.authenticatedClient();

    setSkedUser(fbUser);
  }

  Future signInAnonomously() async {
    var authResult = await _firebaseAuth.signInAnonymously();

    User _user = authResult.user;

    print(_user.toString());

    assert(await _user.getIdToken() != null);

    User fbUser = _firebaseAuth.currentUser;

    assert(_user.uid == fbUser.uid);

    setSkedUser(fbUser);
  }

  Future<bool> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _currentUser = null;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    if (user != null) {
      return user != null && _authClient != null;
    } else {
      return false;
    }
  }
}
