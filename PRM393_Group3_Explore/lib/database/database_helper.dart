import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/destination.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'culture_trip.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE destinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL,
        tag TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        extra_image_url TEXT NOT NULL DEFAULT '',
        media_blocks TEXT NOT NULL DEFAULT '[]',
        is_visited INTEGER NOT NULL DEFAULT 0,
        is_saved INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE destinations ADD COLUMN content TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE destinations ADD COLUMN extra_image_url TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE destinations ADD COLUMN media_blocks TEXT NOT NULL DEFAULT '[]'");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE destinations ADD COLUMN is_visited INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE destinations ADD COLUMN is_saved INTEGER NOT NULL DEFAULT 0");
    }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = [
      {
        'title': "Xi'an", 'location': 'China', 'category': 'Unique Food Cities',
        'description': "Xi'an marks the end of the Silk Road and the convergence of several different cultures. The Muslim Quarter is the place to go for culinary exploration, where streets are filled with the scent of grilled cumin lamb, biang biang noodles, and lamb paomo noodle broth.",
        'image_url': 'https://images.unsplash.com/photo-1547981609-4b6bfe67ca0b?w=800', 'tag': 'Food',
        'content': "Xi'an is one of the oldest cities in China and served as the capital of 13 dynasties. Today, it is best known as the home of the Terracotta Army — thousands of life-sized clay soldiers buried with Emperor Qin Shi Huang over 2,000 years ago.\n\nBeyond its archaeological wonders, Xi'an is a food lover's paradise. The city's Muslim Quarter is a maze of narrow alleys filled with the aromas of cumin-spiced meats, sesame flatbreads, and steaming bowls of broth. Biang biang noodles — named for the slapping sound made when the dough hits the counter — are thick, chewy, and utterly satisfying.\n\nThe city walls, built during the Ming Dynasty, are among the best-preserved in China. You can rent a bike and cycle the entire 14-kilometer perimeter at sunset for views that stretch across the ancient capital.",
        'extra_image_url': 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800","caption":"The iconic Muslim Quarter at dusk."},{"url":"https://images.unsplash.com/photo-1547981609-4b6bfe67ca0b?w=800","caption":"Biang biang noodles — thick, hand-pulled, and tossed in chili oil."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
      {
        'title': 'Salar de Uyuni', 'location': 'Bolivia', 'category': 'Otherworldly Landscapes',
        'description': "The world's largest salt flat stretches over 10,000 square kilometers. During the rainy season, a thin layer of water transforms it into the world's largest natural mirror, perfectly reflecting the sky above.",
        'image_url': 'https://images.unsplash.com/photo-1580349837564-80b8d0d1513f?w=800', 'tag': 'Nature',
        'content': "Salar de Uyuni lies at an altitude of 3,656 meters in the Potosí Department of southwest Bolivia. Formed as a result of prehistoric lakes evaporating, the flats are covered by a few meters of salt crust with an extraordinarily flat surface.\n\nThe salt flat is so large and so perfectly level that it is used to calibrate the altimeters of satellites. During the dry season, geometric salt polygons tessellate across the white surface as far as the eye can see. The effect is hypnotic and disorienting.\n\nNearby, the colorful Laguna Colorada glows red from algae and mineral sediments, and flocks of flamingos wade through its shallows.",
        'extra_image_url': 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800","caption":"The mirror effect during rainy season."},{"url":"https://images.unsplash.com/photo-1580349837564-80b8d0d1513f?w=800","caption":"Endless salt hexagons stretch to the horizon."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
      {
        'title': 'Faroe Islands', 'location': 'Denmark', 'category': 'Influencer-Free',
        'description': "Forget hidden gems and best-kept secrets. The Faroe Islands are raw, dramatic, and utterly authentic. Eighteen volcanic islands rise steeply from the North Atlantic, with turf-roofed villages clinging to cliff edges above churning seas.",
        'image_url': 'https://images.unsplash.com/photo-1520769669658-f07657f5a307?w=800', 'tag': 'Hidden Gem',
        'content': "The Faroe Islands sit halfway between Norway and Iceland, battered by North Atlantic winds and draped in an almost perpetual mist. They are not for the faint-hearted traveler, but for those who seek something genuinely untamed, they are extraordinary.\n\nThe 18 islands are connected by a network of undersea tunnels, ferries, and mountain roads that offer some of the most dramatic driving in Europe. Villages like Gásadalur, perched above a waterfall that plunges directly into the sea, feel like they belong in a fairy tale.\n\nBirdlife is spectacular — puffins nest in the cliffs in their thousands from April to August.",
        'extra_image_url': 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800","caption":"Gásadalur — a waterfall drops straight into the Atlantic."},{"url":"https://images.unsplash.com/photo-1520769669658-f07657f5a307?w=800","caption":"Turf-roofed houses blend into the cliffs."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
      {
        'title': 'Ha Giang Loop', 'location': 'Vietnam', 'category': 'Magical Journeys',
        'description': "Sometimes the journey is more important than the destination. The Ha Giang Loop winds through Vietnam's northernmost province, past towering limestone karsts, terraced rice fields, and remote villages of the Hmong people.",
        'image_url': 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800', 'tag': 'Adventure',
        'content': "The Ha Giang Loop is a roughly 350-kilometer circuit through Vietnam's northernmost province, bordering China. It is widely considered the most spectacular motorbike route in Southeast Asia.\n\nThe road climbs to the Dong Van Karst Plateau Geopark — a UNESCO-recognized landscape of ancient limestone mountains, deep river valleys, and terraced fields carved into near-vertical slopes.\n\nThe famous Ma Pi Leng Pass offers a view down into the Nho Que River gorge that has stopped many travelers in their tracks.",
        'extra_image_url': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800","caption":"The Nho Que River snakes through the gorge below Ma Pi Leng Pass."},{"url":"https://images.unsplash.com/photo-1528127269322-539801943592?w=800","caption":"Terraced rice fields of Hoang Su Phi."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
      {
        'title': 'Papua New Guinea', 'location': 'Oceania', 'category': 'Once-in-a-Lifetime',
        'description': "Home to some of the most extraordinary biodiversity on the planet, Papua New Guinea is a land where ancient traditions survive intact.",
        'image_url': 'https://images.unsplash.com/photo-1551918120-9739cb430c6d?w=800', 'tag': 'Bucket List',
        'content': "Papua New Guinea occupies the eastern half of the island of New Guinea. It is one of the world's most culturally diverse countries, with over 800 distinct languages spoken.\n\nThe highlands are home to tribal communities whose annual sing-sing gatherings bring together thousands of people in elaborate traditional dress.\n\nFor naturalists, PNG is extraordinary. The rainforests harbour more species of birds-of-paradise than anywhere on Earth.",
        'extra_image_url': 'https://images.unsplash.com/photo-1540202404-a2f29016b523?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1540202404-a2f29016b523?w=800","caption":"The Mount Hagen Sing-Sing — thousands in ancestral regalia."},{"url":"https://images.unsplash.com/photo-1551918120-9739cb430c6d?w=800","caption":"Coral gardens of Milne Bay."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
      {
        'title': 'Varanasi', 'location': 'India', 'category': "Don't Worry!",
        'description': "Varanasi is one of the oldest continuously inhabited cities on Earth. The ghats along the Ganges come alive at dawn with pilgrims, priests, and the ritual burning of the dead in a spectacle unlike anywhere else.",
        'image_url': 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=800', 'tag': 'Culture',
        'content': "Varanasi — also known as Benares or Kashi — is perhaps the holiest city in Hinduism. The 84 ghats that line the western bank of the Ganges are the city's beating heart.\n\nEach morning, pilgrims descend the stone steps to bathe in the sacred river at sunrise. The Dashashwamedh Ghat hosts the evening Ganga Aarti ceremony every night.\n\nThe Manikarnika Ghat is the city's main cremation ground, where bodies are burned 24 hours a day. Death in Varanasi is not hidden away; it is an open, communal, sacred event.",
        'extra_image_url': 'https://images.unsplash.com/photo-1506461883276-594a12b11cf3?w=800',
        'media_blocks': '[{"url":"https://images.unsplash.com/photo-1506461883276-594a12b11cf3?w=800","caption":"Dawn on the Ganges — pilgrims descend as the sun rises."},{"url":"https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=800","caption":"The Ganga Aarti ceremony lights up Dashashwamedh Ghat."}]',
        'is_visited': 0, 'is_saved': 0, 'created_at': now,
      },
    ];
    for (final seed in seeds) {
      await db.insert('destinations', seed);
    }
  }

  Future<int> insertDestination(Destination destination) async {
    final db = await database;
    return await db.insert('destinations', destination.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Destination>> getAllDestinations() async {
    final db = await database;
    final maps = await db.query('destinations', orderBy: 'created_at DESC');
    return maps.map((m) => Destination.fromMap(m)).toList();
  }

  Future<List<Destination>> getByCategory(String category) async {
    final db = await database;
    final maps = await db.query('destinations',
        where: 'category = ?', whereArgs: [category], orderBy: 'created_at DESC');
    return maps.map((m) => Destination.fromMap(m)).toList();
  }

  Future<List<Destination>> getSavedDestinations() async {
    final db = await database;
    final maps = await db.query('destinations',
        where: 'is_saved = 1', orderBy: 'created_at DESC');
    return maps.map((m) => Destination.fromMap(m)).toList();
  }

  Future<List<Destination>> getVisitedDestinations() async {
    final db = await database;
    final maps = await db.query('destinations',
        where: 'is_visited = 1', orderBy: 'created_at DESC');
    return maps.map((m) => Destination.fromMap(m)).toList();
  }

  Future<Destination?> getDestination(int id) async {
    final db = await database;
    final maps = await db.query('destinations',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Destination.fromMap(maps.first);
  }

  Future<int> updateDestination(Destination destination) async {
    final db = await database;
    return await db.update('destinations', destination.toMap(),
        where: 'id = ?', whereArgs: [destination.id]);
  }

  Future<int> toggleVisited(int id, bool value) async {
    final db = await database;
    return await db.update('destinations', {'is_visited': value ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleSaved(int id, bool value) async {
    final db = await database;
    return await db.update('destinations', {'is_saved': value ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDestination(int id) async {
    final db = await database;
    return await db.delete('destinations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Destination>> searchDestinations(String query) async {
    final db = await database;
    final maps = await db.query('destinations',
        where: 'title LIKE ? OR location LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'created_at DESC');
    return maps.map((m) => Destination.fromMap(m)).toList();
  }

  Future<Map<String, int>> getCategoryStats() async {
    final db = await database;
    final result = <String, int>{};
    for (final cat in kCategories) {
      final total = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM destinations WHERE category = ?', [cat])) ?? 0;
      final visited = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM destinations WHERE category = ? AND is_visited = 1', [cat])) ?? 0;
      result['${cat}_total'] = total;
      result['${cat}_visited'] = visited;
    }
    return result;
  }
}