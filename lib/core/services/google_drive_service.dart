import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Google Drive Service
class GoogleDriveService {

  /// 🔥 Your target folder ID
  static const String folderId =
      "1cMEymw_YfPGIYjBvjxnRC2b9vt9_QPP4";

  /// Google Sign In with Drive scope
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  /// =========================
  /// 🔐 Get Drive API
  /// =========================
  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      /// Sign in silently first (better UX)
      GoogleSignInAccount? account =
          await _googleSignIn.signInSilently();

      account ??= await _googleSignIn.signIn();

      if (account == null) {
        print("❌ Google Sign-In cancelled");
        return null;
      }

      final authHeaders = await account.authHeaders;

      final client = GoogleAuthClient(authHeaders);

      return drive.DriveApi(client);

    } catch (e) {
      print("🔥 Drive API Error: $e");
      return null;
    }
  }

  /// =========================
  /// 🚀 Upload File
  /// =========================
  Future<String?> uploadFile(File file) async {
    try {
      final api = await _getDriveApi();

      if (api == null) {
        print("❌ Drive API is null");
        return null;
      }

      /// File metadata with folder
      final driveFile = drive.File()
        ..name = file.path.split('/').last
        ..parents = [folderId]; // ✅ UPLOAD TO YOUR FOLDER

      /// File media
      final media = drive.Media(
        file.openRead(),
        file.lengthSync(),
      );

      /// Upload file
      final result = await api.files.create(
        driveFile,
        uploadMedia: media,
      );

      final fileId = result.id;

      if (fileId == null) {
        print("❌ Upload failed: No file ID");
        return null;
      }

      /// Make file PUBLIC
      await api.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        fileId,
      );

      print("✅ Upload success. File ID: $fileId");

      return fileId;

    } catch (e, stack) {
  print("🔥 DRIVE FULL ERROR: $e");
  print("🔥 STACK: $stack");
  rethrow;
}
  }

  /// =========================
  /// 🔗 Download URL
  /// =========================
  String getDownloadUrl(String fileId) {
    return "https://drive.google.com/uc?id=$fileId";
  }

  /// =========================
  /// 🔗 Preview URL
  /// =========================
  String getPreviewUrl(String fileId) {
    return "https://drive.google.com/file/d/$fileId/view";
  }
}

/// =========================
/// 🔐 Auth Client
/// =========================
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}