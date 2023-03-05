import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'src/auth_result.dart';
import 'src/provider_args.dart';
import 'src/util.dart';

class SpotifySignInArgs extends ProviderArgs {
  SpotifySignInArgs({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.scopes = const [],
    this.showDialog = false,
  });

  static const _accessTokenPath = '/api/token';

  static const responseType = 'code';
  static const grantType = 'authorization_code';

  final String clientId;
  final String clientSecret;
  final List<SpotifyScope> scopes;
  final bool showDialog;

  @override
  final String redirectUri;

  @override
  final host = 'accounts.spotify.com';

  @override
  final path = '/authorize';

  var _state = '';

  @override
  Map<String, String> buildQueryParameters() {
    _state = generateNonce();

    return {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': responseType,
      'state': _state,
      'scope': scopes.map((s) => s.value).join(' '),
      'show_dialog': showDialog.toString(),
    };
  }

  @override
  Future<AuthResult?> authorizeFromCallback(String callbackUrl) async {
    final parsed = Uri.parse(callbackUrl);
    final code = parsed.queryParameters['code'] as String;
    final state = parsed.queryParameters['state'] as String;

    if (_state == state) {
      final res = await _post(
        path: _accessTokenPath,
        body: {
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'grant_type': grantType,
          'code': code,
        },
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization":
              "Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}",
        },
      );

      if (res == null) {
        throw Exception("Couldn't authorize");
      }

      final decodedRes = json.decode(res);

      return AuthResult(
        accessToken: decodedRes['access_token'],
      );
    } else {
      throw Exception(
        "Couldn't authorize, the state received by Spotify "
        "doesn't match state used to authorize.",
      );
    }
  }

  Future<String?> _post({
    required String path,
    required Map<String, String> body,
    required Map<String, String> headers,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: host,
      path: path,
    );

    try {
      final res = await http.post(
        uri,
        body: body,
        headers: headers,
      );

      if (res.statusCode == 200) {
        return res.body;
      } else {
        throw Exception('HttpCode: ${res.statusCode}, Body: ${res.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

enum SpotifyScope {
  ugcImageUpload('ugc-image-upload'),
  userReadPlaybackState('user-read-playback-state'),
  userModifyPlaybackState('user-modify-playback-state'),
  userReadCurrentlyPlaying('user-read-currently-playing'),
  appRemoteControl('app-remote-control'),
  streaming('streaming'),
  playlistReadPrivate('playlist-read-private'),
  playlistReadCollaborative('playlist-read-collaborative'),
  playlistModifyPrivate('playlist-modify-private'),
  playlistModifyPublic('playlist-modify-public'),
  userFollowModify('user-follow-modify'),
  userFollowRead('user-follow-read'),
  userReadPlaybackPosition('user-read-playback-position'),
  userTopRead('user-top-read'),
  userReadRecentlyPlayed('user-read-recently-played'),
  userLibraryModify('user-library-modify'),
  userLibraryRead('user-library-read'),
  userReadEmail('user-read-email'),
  userReadPrivate('user-read-private');

  const SpotifyScope(this.value);

  final String value;
}
