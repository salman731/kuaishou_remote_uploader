import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kuaishou_remote_uploader/models/gist_item.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';

class GistService {
  static final String? _token = dotenv.env['GITHUB_TOKEN'];
  static const String _apiUrl = 'https://api.github.com/gists';
  static const String fileName = 'users.txt';
  static const String unfollowCookie = 'unfollow_cookie.txt';

  //Create a new Gist
  static Future<String> createGist(String text,String filename, {String? description}) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'description': description ?? 'Kuaishou Users List',
        'public': false,
        'files': {
          filename: {'content': text},
        },
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['id'];  // Returns Gist ID
    } else {
      throw Exception('Failed to create Gist: ${response.body}');
    }
  }

  // Update an existing Gist
  static Future<void> updateGist(String gistId, String newText,String filename) async {

    final response = await http.patch(
      Uri.parse('$_apiUrl/$gistId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'files': {
          filename: {'content': newText},
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update Gist: ${response.body}');
    }
  }

  // Fetch Gist content
  static Future<String> getGist(String gistId,String filename) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/$gistId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['files'][filename]['content'];
    } else {
      throw Exception('Failed to fetch Gist: ${response.body}');
    }
  }

  // Delete a Gist
  static Future<void> deleteGist(String gistId) async {
    final response = await http.delete(
      Uri.parse('$_apiUrl/$gistId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete Gist: ${response.body}');
    }
  }

  // static Future<bool> doesFileExist() async {
  //   String gistId = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_USERS_GIST_ID);
  //   if(gistId.isEmpty)
  //     {return false;}
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_apiUrl/$gistId'),
  //       headers: {
  //         'Authorization': 'Bearer $_token',
  //         'Accept': 'application/vnd.github+json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return (data['files']?.containsKey(fileName) ?? false);
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  static Future<(bool,String)> doesFileExist(String filename) async {
    final response = await http.get(
      Uri.parse('$_apiUrl?per_page=100'), // Get up to 100 gists
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> gistsJson = jsonDecode(response.body);
      List<GistItem> list = gistsJson.map((json) => GistItem.fromJson(json)).toList();
      GistItem? userItem = list.where((item) => item.files.containsKey(filename)).firstOrNull;
      if(userItem != null)
        {
          return (true,userItem.id);
        }
      else
        {
          return (false,"");
        }
    } else {
      throw Exception('Failed to load gists: ${response.body}');
    }
  }
}