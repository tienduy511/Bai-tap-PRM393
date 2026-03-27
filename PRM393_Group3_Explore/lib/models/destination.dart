class Destination {
  final int? id;
  final String title;
  final String location;
  final String category;
  final String description;
  final String imageUrl;
  final String tag;
  final String content;
  final String extraImageUrl;
  final String mediaBlocks;
  final bool isVisited;
  final bool isSaved;
  final DateTime createdAt;

  Destination({
    this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.tag,
    this.content = '',
    this.extraImageUrl = '',
    this.mediaBlocks = '[]',
    this.isVisited = false,
    this.isSaved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'tag': tag,
      'content': content,
      'extra_image_url': extraImageUrl,
      'media_blocks': mediaBlocks,
      'is_visited': isVisited ? 1 : 0,
      'is_saved': isSaved ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      category: map['category'],
      description: map['description'],
      imageUrl: map['image_url'],
      tag: map['tag'],
      content: map['content'] ?? '',
      extraImageUrl: map['extra_image_url'] ?? '',
      mediaBlocks: map['media_blocks'] ?? '[]',
      isVisited: (map['is_visited'] ?? 0) == 1,
      isSaved: (map['is_saved'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Destination copyWith({
    int? id,
    String? title,
    String? location,
    String? category,
    String? description,
    String? imageUrl,
    String? tag,
    String? content,
    String? extraImageUrl,
    String? mediaBlocks,
    bool? isVisited,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return Destination(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tag: tag ?? this.tag,
      content: content ?? this.content,
      extraImageUrl: extraImageUrl ?? this.extraImageUrl,
      mediaBlocks: mediaBlocks ?? this.mediaBlocks,
      isVisited: isVisited ?? this.isVisited,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const List<String> kCategories = [
  'Unique Food Cities',
  'Otherworldly Landscapes',
  'Influencer-Free',
  'Magical Journeys',
  'Once-in-a-Lifetime',
  "Don't Worry!",
];

const List<String> kTags = [
  'Food', 'Nature', 'Adventure', 'Culture',
  'Hidden Gem', 'Bucket List', 'Off the Beaten Path',
];

const Map<String, Map<String, String>> kCategoryHero = {
  'Overview': {
    'imageUrl': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800',
    'tagline': "Culture Trip's best of the best",
    'subtitle': 'The 100 places to visit in 2026.',
  },
  'Unique Food Cities': {
    'imageUrl': 'https://images.unsplash.com/photo-1547981609-4b6bfe67ca0b?w=800',
    'tagline': 'Unique Food Cities',
    'subtitle': '10 places to get the tastebuds tingling.',
  },
  'Otherworldly Landscapes': {
    'imageUrl': 'https://images.unsplash.com/photo-1580349837564-80b8d0d1513f?w=800',
    'tagline': 'Otherworldly Landscapes',
    'subtitle': "10 of Mother Nature's most bonkers creations.",
  },
  'Influencer-Free': {
    'imageUrl': 'https://images.unsplash.com/photo-1520769669658-f07657f5a307?w=800',
    'tagline': 'Influencer-Free',
    'subtitle': '10 far-flung places to escape the TikTokers.',
  },
  'Magical Journeys': {
    'imageUrl': 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    'tagline': 'Magical Journeys',
    'subtitle': '10 trips where the road is the destination.',
  },
  'Once-in-a-Lifetime': {
    'imageUrl': 'https://images.unsplash.com/photo-1551918120-9739cb430c6d?w=800',
    'tagline': 'Once-in-a-Lifetime',
    'subtitle': '10 experiences you will never forget.',
  },
  "Don't Worry!": {
    'imageUrl': 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=800',
    'tagline': "Don't Worry!",
    'subtitle': '10 places that are safer than you think.',
  },
};