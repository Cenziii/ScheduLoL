import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class GitHubService {
  GitHubService._privateConstructor();

  static final GitHubService _instance = GitHubService._privateConstructor();
  final token = dotenv.env['GITHUB_TOKEN_RELEASE'];
  final baseUrl =
      'https://api.github.com/repos/Cenziii/lol_competitive/releases';

  factory GitHubService() {
    return _instance;
  }

  Future<bool> checkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  Future<List<String>?> getCheckUpdates() async {
    final hasConnection = await checkConnection();
    if (!hasConnection) {
      debugPrint('No network connection');
      return null;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final url = Uri.parse(baseUrl);

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];

        String latestVersion = (data['tag_name'] as String).replaceFirst(
          'v',
          '',
        );
        String apkUrl = '';
        if (data['assets'] != null && data['assets'].isNotEmpty) {
          apkUrl = data['assets'][0]['browser_download_url'];
        }

        if (_isNewerVersion(latestVersion, currentVersion)) {
          return [latestVersion, apkUrl];
        }
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        debugPrint('Response code ${response.body}');
        return null;
      } else {
        debugPrint('Response code ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (_) {
      debugPrint('Check update request timed out');
      return null;
    } on SocketException catch (_) {
      debugPrint('Network error while fetching update');
      return null;
    } on FormatException catch (_) {
      debugPrint('Invalid JSON format in past match response');
      return null;
    } catch (e) {
      debugPrint('Unexpected error in past match response: $e');
      return null;
    }
    return null;
  }

  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }
}
