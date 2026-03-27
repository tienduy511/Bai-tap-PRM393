import 'package:flutter/material.dart';
import '../models/post.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      elevation: 3,

      child: ListTile(
        leading: CircleAvatar(
          child: Text(post.id.toString()),
        ),

        title: Text(
          post.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          post.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}