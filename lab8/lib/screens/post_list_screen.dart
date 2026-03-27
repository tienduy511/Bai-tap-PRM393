import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_item.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() =>
      _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> futurePosts;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futurePosts = apiService.fetchPosts();
  }

  void retry() {
    setState(() {
      futurePosts = apiService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Posts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: retry,
          )
        ],
      ),

      body: FutureBuilder<List<Post>>(
        future: futurePosts,

        builder: (context, snapshot) {
          /// 🔄 LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text("Something went wrong 😢"),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: retry,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          /// ✅ DATA
          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,

            itemBuilder: (context, index) {
              return PostItem(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}