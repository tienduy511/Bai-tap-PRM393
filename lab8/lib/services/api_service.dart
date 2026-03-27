import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  final String baseUrl =
      "https://jsonplaceholder.typicode.com/posts";

  /// 🔥 GET
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  /// 🔥 POST (BONUS)
  Future<Post> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "title": title,
        "body": body,
      },
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create post");
    }
  }
}