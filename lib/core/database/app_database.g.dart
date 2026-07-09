// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MangasTable extends Mangas with TableInfo<$MangasTable, MangaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdateMeta = const VerificationMeta(
    'lastUpdate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
    'last_update',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerFlagsMeta = const VerificationMeta(
    'viewerFlags',
  );
  @override
  late final GeneratedColumn<int> viewerFlags = GeneratedColumn<int>(
    'viewer_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chapterFlagsMeta = const VerificationMeta(
    'chapterFlags',
  );
  @override
  late final GeneratedColumn<int> chapterFlags = GeneratedColumn<int>(
    'chapter_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    url,
    title,
    artist,
    author,
    description,
    genre,
    status,
    thumbnailUrl,
    favorite,
    dateAdded,
    lastUpdate,
    viewerFlags,
    chapterFlags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mangas';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('last_update')) {
      context.handle(
        _lastUpdateMeta,
        lastUpdate.isAcceptableOrUnknown(data['last_update']!, _lastUpdateMeta),
      );
    }
    if (data.containsKey('viewer_flags')) {
      context.handle(
        _viewerFlagsMeta,
        viewerFlags.isAcceptableOrUnknown(
          data['viewer_flags']!,
          _viewerFlagsMeta,
        ),
      );
    }
    if (data.containsKey('chapter_flags')) {
      context.handle(
        _chapterFlagsMeta,
        chapterFlags.isAcceptableOrUnknown(
          data['chapter_flags']!,
          _chapterFlagsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      ),
      lastUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update'],
      ),
      viewerFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viewer_flags'],
      )!,
      chapterFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_flags'],
      )!,
    );
  }

  @override
  $MangasTable createAlias(String alias) {
    return $MangasTable(attachedDatabase, alias);
  }
}

class MangaData extends DataClass implements Insertable<MangaData> {
  final int id;
  final int source;
  final String url;
  final String title;
  final String? artist;
  final String? author;
  final String? description;
  final String? genre;
  final int status;
  final String? thumbnailUrl;
  final bool favorite;
  final DateTime? dateAdded;
  final DateTime? lastUpdate;
  final int viewerFlags;
  final int chapterFlags;
  const MangaData({
    required this.id,
    required this.source,
    required this.url,
    required this.title,
    this.artist,
    this.author,
    this.description,
    this.genre,
    required this.status,
    this.thumbnailUrl,
    required this.favorite,
    this.dateAdded,
    this.lastUpdate,
    required this.viewerFlags,
    required this.chapterFlags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<int>(source);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || dateAdded != null) {
      map['date_added'] = Variable<DateTime>(dateAdded);
    }
    if (!nullToAbsent || lastUpdate != null) {
      map['last_update'] = Variable<DateTime>(lastUpdate);
    }
    map['viewer_flags'] = Variable<int>(viewerFlags);
    map['chapter_flags'] = Variable<int>(chapterFlags);
    return map;
  }

  MangasCompanion toCompanion(bool nullToAbsent) {
    return MangasCompanion(
      id: Value(id),
      source: Value(source),
      url: Value(url),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      status: Value(status),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      favorite: Value(favorite),
      dateAdded: dateAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAdded),
      lastUpdate: lastUpdate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdate),
      viewerFlags: Value(viewerFlags),
      chapterFlags: Value(chapterFlags),
    );
  }

  factory MangaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaData(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<int>(json['source']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      genre: serializer.fromJson<String?>(json['genre']),
      status: serializer.fromJson<int>(json['status']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      dateAdded: serializer.fromJson<DateTime?>(json['dateAdded']),
      lastUpdate: serializer.fromJson<DateTime?>(json['lastUpdate']),
      viewerFlags: serializer.fromJson<int>(json['viewerFlags']),
      chapterFlags: serializer.fromJson<int>(json['chapterFlags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<int>(source),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'genre': serializer.toJson<String?>(genre),
      'status': serializer.toJson<int>(status),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'favorite': serializer.toJson<bool>(favorite),
      'dateAdded': serializer.toJson<DateTime?>(dateAdded),
      'lastUpdate': serializer.toJson<DateTime?>(lastUpdate),
      'viewerFlags': serializer.toJson<int>(viewerFlags),
      'chapterFlags': serializer.toJson<int>(chapterFlags),
    };
  }

  MangaData copyWith({
    int? id,
    int? source,
    String? url,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    int? status,
    Value<String?> thumbnailUrl = const Value.absent(),
    bool? favorite,
    Value<DateTime?> dateAdded = const Value.absent(),
    Value<DateTime?> lastUpdate = const Value.absent(),
    int? viewerFlags,
    int? chapterFlags,
  }) => MangaData(
    id: id ?? this.id,
    source: source ?? this.source,
    url: url ?? this.url,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    author: author.present ? author.value : this.author,
    description: description.present ? description.value : this.description,
    genre: genre.present ? genre.value : this.genre,
    status: status ?? this.status,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    favorite: favorite ?? this.favorite,
    dateAdded: dateAdded.present ? dateAdded.value : this.dateAdded,
    lastUpdate: lastUpdate.present ? lastUpdate.value : this.lastUpdate,
    viewerFlags: viewerFlags ?? this.viewerFlags,
    chapterFlags: chapterFlags ?? this.chapterFlags,
  );
  MangaData copyWithCompanion(MangasCompanion data) {
    return MangaData(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
      genre: data.genre.present ? data.genre.value : this.genre,
      status: data.status.present ? data.status.value : this.status,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      lastUpdate: data.lastUpdate.present
          ? data.lastUpdate.value
          : this.lastUpdate,
      viewerFlags: data.viewerFlags.present
          ? data.viewerFlags.value
          : this.viewerFlags,
      chapterFlags: data.chapterFlags.present
          ? data.chapterFlags.value
          : this.chapterFlags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaData(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('genre: $genre, ')
          ..write('status: $status, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('favorite: $favorite, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('viewerFlags: $viewerFlags, ')
          ..write('chapterFlags: $chapterFlags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    url,
    title,
    artist,
    author,
    description,
    genre,
    status,
    thumbnailUrl,
    favorite,
    dateAdded,
    lastUpdate,
    viewerFlags,
    chapterFlags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaData &&
          other.id == this.id &&
          other.source == this.source &&
          other.url == this.url &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.author == this.author &&
          other.description == this.description &&
          other.genre == this.genre &&
          other.status == this.status &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.favorite == this.favorite &&
          other.dateAdded == this.dateAdded &&
          other.lastUpdate == this.lastUpdate &&
          other.viewerFlags == this.viewerFlags &&
          other.chapterFlags == this.chapterFlags);
}

class MangasCompanion extends UpdateCompanion<MangaData> {
  final Value<int> id;
  final Value<int> source;
  final Value<String> url;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> genre;
  final Value<int> status;
  final Value<String?> thumbnailUrl;
  final Value<bool> favorite;
  final Value<DateTime?> dateAdded;
  final Value<DateTime?> lastUpdate;
  final Value<int> viewerFlags;
  final Value<int> chapterFlags;
  const MangasCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.genre = const Value.absent(),
    this.status = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.favorite = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.viewerFlags = const Value.absent(),
    this.chapterFlags = const Value.absent(),
  });
  MangasCompanion.insert({
    this.id = const Value.absent(),
    required int source,
    required String url,
    required String title,
    this.artist = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.genre = const Value.absent(),
    this.status = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.favorite = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.viewerFlags = const Value.absent(),
    this.chapterFlags = const Value.absent(),
  }) : source = Value(source),
       url = Value(url),
       title = Value(title);
  static Insertable<MangaData> custom({
    Expression<int>? id,
    Expression<int>? source,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? genre,
    Expression<int>? status,
    Expression<String>? thumbnailUrl,
    Expression<bool>? favorite,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? lastUpdate,
    Expression<int>? viewerFlags,
    Expression<int>? chapterFlags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (genre != null) 'genre': genre,
      if (status != null) 'status': status,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (favorite != null) 'favorite': favorite,
      if (dateAdded != null) 'date_added': dateAdded,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (viewerFlags != null) 'viewer_flags': viewerFlags,
      if (chapterFlags != null) 'chapter_flags': chapterFlags,
    });
  }

  MangasCompanion copyWith({
    Value<int>? id,
    Value<int>? source,
    Value<String>? url,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? author,
    Value<String?>? description,
    Value<String?>? genre,
    Value<int>? status,
    Value<String?>? thumbnailUrl,
    Value<bool>? favorite,
    Value<DateTime?>? dateAdded,
    Value<DateTime?>? lastUpdate,
    Value<int>? viewerFlags,
    Value<int>? chapterFlags,
  }) {
    return MangasCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      url: url ?? this.url,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      author: author ?? this.author,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      favorite: favorite ?? this.favorite,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      viewerFlags: viewerFlags ?? this.viewerFlags,
      chapterFlags: chapterFlags ?? this.chapterFlags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<DateTime>(lastUpdate.value);
    }
    if (viewerFlags.present) {
      map['viewer_flags'] = Variable<int>(viewerFlags.value);
    }
    if (chapterFlags.present) {
      map['chapter_flags'] = Variable<int>(chapterFlags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangasCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('genre: $genre, ')
          ..write('status: $status, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('favorite: $favorite, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('viewerFlags: $viewerFlags, ')
          ..write('chapterFlags: $chapterFlags')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mangaIdMeta = const VerificationMeta(
    'mangaId',
  );
  @override
  late final GeneratedColumn<int> mangaId = GeneratedColumn<int>(
    'manga_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mangas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanlatorMeta = const VerificationMeta(
    'scanlator',
  );
  @override
  late final GeneratedColumn<String> scanlator = GeneratedColumn<String>(
    'scanlator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bookmarkMeta = const VerificationMeta(
    'bookmark',
  );
  @override
  late final GeneratedColumn<bool> bookmark = GeneratedColumn<bool>(
    'bookmark',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bookmark" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPageReadMeta = const VerificationMeta(
    'lastPageRead',
  );
  @override
  late final GeneratedColumn<int> lastPageRead = GeneratedColumn<int>(
    'last_page_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<double> chapterNumber = GeneratedColumn<double>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _dateUploadMeta = const VerificationMeta(
    'dateUpload',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpload = GeneratedColumn<DateTime>(
    'date_upload',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFetchMeta = const VerificationMeta(
    'dateFetch',
  );
  @override
  late final GeneratedColumn<DateTime> dateFetch = GeneratedColumn<DateTime>(
    'date_fetch',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceOrderMeta = const VerificationMeta(
    'sourceOrder',
  );
  @override
  late final GeneratedColumn<int> sourceOrder = GeneratedColumn<int>(
    'source_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mangaId,
    url,
    name,
    scanlator,
    read,
    bookmark,
    lastPageRead,
    chapterNumber,
    dateUpload,
    dateFetch,
    sourceOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_id')) {
      context.handle(
        _mangaIdMeta,
        mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scanlator')) {
      context.handle(
        _scanlatorMeta,
        scanlator.isAcceptableOrUnknown(data['scanlator']!, _scanlatorMeta),
      );
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    if (data.containsKey('bookmark')) {
      context.handle(
        _bookmarkMeta,
        bookmark.isAcceptableOrUnknown(data['bookmark']!, _bookmarkMeta),
      );
    }
    if (data.containsKey('last_page_read')) {
      context.handle(
        _lastPageReadMeta,
        lastPageRead.isAcceptableOrUnknown(
          data['last_page_read']!,
          _lastPageReadMeta,
        ),
      );
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    }
    if (data.containsKey('date_upload')) {
      context.handle(
        _dateUploadMeta,
        dateUpload.isAcceptableOrUnknown(data['date_upload']!, _dateUploadMeta),
      );
    }
    if (data.containsKey('date_fetch')) {
      context.handle(
        _dateFetchMeta,
        dateFetch.isAcceptableOrUnknown(data['date_fetch']!, _dateFetchMeta),
      );
    }
    if (data.containsKey('source_order')) {
      context.handle(
        _sourceOrderMeta,
        sourceOrder.isAcceptableOrUnknown(
          data['source_order']!,
          _sourceOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mangaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manga_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scanlator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scanlator'],
      ),
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
      bookmark: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bookmark'],
      )!,
      lastPageRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page_read'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chapter_number'],
      )!,
      dateUpload: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_upload'],
      ),
      dateFetch: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fetch'],
      ),
      sourceOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_order'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class ChapterData extends DataClass implements Insertable<ChapterData> {
  final int id;
  final int mangaId;
  final String url;
  final String name;
  final String? scanlator;
  final bool read;
  final bool bookmark;
  final int lastPageRead;
  final double chapterNumber;
  final DateTime? dateUpload;
  final DateTime? dateFetch;
  final int sourceOrder;
  const ChapterData({
    required this.id,
    required this.mangaId,
    required this.url,
    required this.name,
    this.scanlator,
    required this.read,
    required this.bookmark,
    required this.lastPageRead,
    required this.chapterNumber,
    this.dateUpload,
    this.dateFetch,
    required this.sourceOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['manga_id'] = Variable<int>(mangaId);
    map['url'] = Variable<String>(url);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || scanlator != null) {
      map['scanlator'] = Variable<String>(scanlator);
    }
    map['read'] = Variable<bool>(read);
    map['bookmark'] = Variable<bool>(bookmark);
    map['last_page_read'] = Variable<int>(lastPageRead);
    map['chapter_number'] = Variable<double>(chapterNumber);
    if (!nullToAbsent || dateUpload != null) {
      map['date_upload'] = Variable<DateTime>(dateUpload);
    }
    if (!nullToAbsent || dateFetch != null) {
      map['date_fetch'] = Variable<DateTime>(dateFetch);
    }
    map['source_order'] = Variable<int>(sourceOrder);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      mangaId: Value(mangaId),
      url: Value(url),
      name: Value(name),
      scanlator: scanlator == null && nullToAbsent
          ? const Value.absent()
          : Value(scanlator),
      read: Value(read),
      bookmark: Value(bookmark),
      lastPageRead: Value(lastPageRead),
      chapterNumber: Value(chapterNumber),
      dateUpload: dateUpload == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUpload),
      dateFetch: dateFetch == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFetch),
      sourceOrder: Value(sourceOrder),
    );
  }

  factory ChapterData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterData(
      id: serializer.fromJson<int>(json['id']),
      mangaId: serializer.fromJson<int>(json['mangaId']),
      url: serializer.fromJson<String>(json['url']),
      name: serializer.fromJson<String>(json['name']),
      scanlator: serializer.fromJson<String?>(json['scanlator']),
      read: serializer.fromJson<bool>(json['read']),
      bookmark: serializer.fromJson<bool>(json['bookmark']),
      lastPageRead: serializer.fromJson<int>(json['lastPageRead']),
      chapterNumber: serializer.fromJson<double>(json['chapterNumber']),
      dateUpload: serializer.fromJson<DateTime?>(json['dateUpload']),
      dateFetch: serializer.fromJson<DateTime?>(json['dateFetch']),
      sourceOrder: serializer.fromJson<int>(json['sourceOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mangaId': serializer.toJson<int>(mangaId),
      'url': serializer.toJson<String>(url),
      'name': serializer.toJson<String>(name),
      'scanlator': serializer.toJson<String?>(scanlator),
      'read': serializer.toJson<bool>(read),
      'bookmark': serializer.toJson<bool>(bookmark),
      'lastPageRead': serializer.toJson<int>(lastPageRead),
      'chapterNumber': serializer.toJson<double>(chapterNumber),
      'dateUpload': serializer.toJson<DateTime?>(dateUpload),
      'dateFetch': serializer.toJson<DateTime?>(dateFetch),
      'sourceOrder': serializer.toJson<int>(sourceOrder),
    };
  }

  ChapterData copyWith({
    int? id,
    int? mangaId,
    String? url,
    String? name,
    Value<String?> scanlator = const Value.absent(),
    bool? read,
    bool? bookmark,
    int? lastPageRead,
    double? chapterNumber,
    Value<DateTime?> dateUpload = const Value.absent(),
    Value<DateTime?> dateFetch = const Value.absent(),
    int? sourceOrder,
  }) => ChapterData(
    id: id ?? this.id,
    mangaId: mangaId ?? this.mangaId,
    url: url ?? this.url,
    name: name ?? this.name,
    scanlator: scanlator.present ? scanlator.value : this.scanlator,
    read: read ?? this.read,
    bookmark: bookmark ?? this.bookmark,
    lastPageRead: lastPageRead ?? this.lastPageRead,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    dateUpload: dateUpload.present ? dateUpload.value : this.dateUpload,
    dateFetch: dateFetch.present ? dateFetch.value : this.dateFetch,
    sourceOrder: sourceOrder ?? this.sourceOrder,
  );
  ChapterData copyWithCompanion(ChaptersCompanion data) {
    return ChapterData(
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      url: data.url.present ? data.url.value : this.url,
      name: data.name.present ? data.name.value : this.name,
      scanlator: data.scanlator.present ? data.scanlator.value : this.scanlator,
      read: data.read.present ? data.read.value : this.read,
      bookmark: data.bookmark.present ? data.bookmark.value : this.bookmark,
      lastPageRead: data.lastPageRead.present
          ? data.lastPageRead.value
          : this.lastPageRead,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      dateUpload: data.dateUpload.present
          ? data.dateUpload.value
          : this.dateUpload,
      dateFetch: data.dateFetch.present ? data.dateFetch.value : this.dateFetch,
      sourceOrder: data.sourceOrder.present
          ? data.sourceOrder.value
          : this.sourceOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterData(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('url: $url, ')
          ..write('name: $name, ')
          ..write('scanlator: $scanlator, ')
          ..write('read: $read, ')
          ..write('bookmark: $bookmark, ')
          ..write('lastPageRead: $lastPageRead, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('dateUpload: $dateUpload, ')
          ..write('dateFetch: $dateFetch, ')
          ..write('sourceOrder: $sourceOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mangaId,
    url,
    name,
    scanlator,
    read,
    bookmark,
    lastPageRead,
    chapterNumber,
    dateUpload,
    dateFetch,
    sourceOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterData &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.url == this.url &&
          other.name == this.name &&
          other.scanlator == this.scanlator &&
          other.read == this.read &&
          other.bookmark == this.bookmark &&
          other.lastPageRead == this.lastPageRead &&
          other.chapterNumber == this.chapterNumber &&
          other.dateUpload == this.dateUpload &&
          other.dateFetch == this.dateFetch &&
          other.sourceOrder == this.sourceOrder);
}

class ChaptersCompanion extends UpdateCompanion<ChapterData> {
  final Value<int> id;
  final Value<int> mangaId;
  final Value<String> url;
  final Value<String> name;
  final Value<String?> scanlator;
  final Value<bool> read;
  final Value<bool> bookmark;
  final Value<int> lastPageRead;
  final Value<double> chapterNumber;
  final Value<DateTime?> dateUpload;
  final Value<DateTime?> dateFetch;
  final Value<int> sourceOrder;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.url = const Value.absent(),
    this.name = const Value.absent(),
    this.scanlator = const Value.absent(),
    this.read = const Value.absent(),
    this.bookmark = const Value.absent(),
    this.lastPageRead = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.dateUpload = const Value.absent(),
    this.dateFetch = const Value.absent(),
    this.sourceOrder = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int mangaId,
    required String url,
    required String name,
    this.scanlator = const Value.absent(),
    this.read = const Value.absent(),
    this.bookmark = const Value.absent(),
    this.lastPageRead = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.dateUpload = const Value.absent(),
    this.dateFetch = const Value.absent(),
    this.sourceOrder = const Value.absent(),
  }) : mangaId = Value(mangaId),
       url = Value(url),
       name = Value(name);
  static Insertable<ChapterData> custom({
    Expression<int>? id,
    Expression<int>? mangaId,
    Expression<String>? url,
    Expression<String>? name,
    Expression<String>? scanlator,
    Expression<bool>? read,
    Expression<bool>? bookmark,
    Expression<int>? lastPageRead,
    Expression<double>? chapterNumber,
    Expression<DateTime>? dateUpload,
    Expression<DateTime>? dateFetch,
    Expression<int>? sourceOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (url != null) 'url': url,
      if (name != null) 'name': name,
      if (scanlator != null) 'scanlator': scanlator,
      if (read != null) 'read': read,
      if (bookmark != null) 'bookmark': bookmark,
      if (lastPageRead != null) 'last_page_read': lastPageRead,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (dateUpload != null) 'date_upload': dateUpload,
      if (dateFetch != null) 'date_fetch': dateFetch,
      if (sourceOrder != null) 'source_order': sourceOrder,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? mangaId,
    Value<String>? url,
    Value<String>? name,
    Value<String?>? scanlator,
    Value<bool>? read,
    Value<bool>? bookmark,
    Value<int>? lastPageRead,
    Value<double>? chapterNumber,
    Value<DateTime?>? dateUpload,
    Value<DateTime?>? dateFetch,
    Value<int>? sourceOrder,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      url: url ?? this.url,
      name: name ?? this.name,
      scanlator: scanlator ?? this.scanlator,
      read: read ?? this.read,
      bookmark: bookmark ?? this.bookmark,
      lastPageRead: lastPageRead ?? this.lastPageRead,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      dateUpload: dateUpload ?? this.dateUpload,
      dateFetch: dateFetch ?? this.dateFetch,
      sourceOrder: sourceOrder ?? this.sourceOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<int>(mangaId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scanlator.present) {
      map['scanlator'] = Variable<String>(scanlator.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (bookmark.present) {
      map['bookmark'] = Variable<bool>(bookmark.value);
    }
    if (lastPageRead.present) {
      map['last_page_read'] = Variable<int>(lastPageRead.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<double>(chapterNumber.value);
    }
    if (dateUpload.present) {
      map['date_upload'] = Variable<DateTime>(dateUpload.value);
    }
    if (dateFetch.present) {
      map['date_fetch'] = Variable<DateTime>(dateFetch.value);
    }
    if (sourceOrder.present) {
      map['source_order'] = Variable<int>(sourceOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('url: $url, ')
          ..write('name: $name, ')
          ..write('scanlator: $scanlator, ')
          ..write('read: $read, ')
          ..write('bookmark: $bookmark, ')
          ..write('lastPageRead: $lastPageRead, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('dateUpload: $dateUpload, ')
          ..write('dateFetch: $dateFetch, ')
          ..write('sourceOrder: $sourceOrder')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<int> flags = GeneratedColumn<int>(
    'flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, position, flags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('flags')) {
      context.handle(
        _flagsMeta,
        flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      flags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flags'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  final int position;
  final int flags;
  const CategoryData({
    required this.id,
    required this.name,
    required this.position,
    required this.flags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    map['flags'] = Variable<int>(flags);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      position: Value(position),
      flags: Value(flags),
    );
  }

  factory CategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      flags: serializer.fromJson<int>(json['flags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'flags': serializer.toJson<int>(flags),
    };
  }

  CategoryData copyWith({int? id, String? name, int? position, int? flags}) =>
      CategoryData(
        id: id ?? this.id,
        name: name ?? this.name,
        position: position ?? this.position,
        flags: flags ?? this.flags,
      );
  CategoryData copyWithCompanion(CategoriesCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      flags: data.flags.present ? data.flags.value : this.flags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('flags: $flags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, position, flags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position &&
          other.flags == this.flags);
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> position;
  final Value<int> flags;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.flags = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.position = const Value.absent(),
    this.flags = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? flags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (flags != null) 'flags': flags,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? position,
    Value<int>? flags,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      flags: flags ?? this.flags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (flags.present) {
      map['flags'] = Variable<int>(flags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('flags: $flags')
          ..write(')'))
        .toString();
  }
}

class $MangasCategoriesTable extends MangasCategories
    with TableInfo<$MangasCategoriesTable, MangaCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangasCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mangaIdMeta = const VerificationMeta(
    'mangaId',
  );
  @override
  late final GeneratedColumn<int> mangaId = GeneratedColumn<int>(
    'manga_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mangas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [mangaId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mangas_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaCategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('manga_id')) {
      context.handle(
        _mangaIdMeta,
        mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mangaId, categoryId};
  @override
  MangaCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaCategoryData(
      mangaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manga_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $MangasCategoriesTable createAlias(String alias) {
    return $MangasCategoriesTable(attachedDatabase, alias);
  }
}

class MangaCategoryData extends DataClass
    implements Insertable<MangaCategoryData> {
  final int mangaId;
  final int categoryId;
  const MangaCategoryData({required this.mangaId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['manga_id'] = Variable<int>(mangaId);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  MangasCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MangasCategoriesCompanion(
      mangaId: Value(mangaId),
      categoryId: Value(categoryId),
    );
  }

  factory MangaCategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaCategoryData(
      mangaId: serializer.fromJson<int>(json['mangaId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mangaId': serializer.toJson<int>(mangaId),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  MangaCategoryData copyWith({int? mangaId, int? categoryId}) =>
      MangaCategoryData(
        mangaId: mangaId ?? this.mangaId,
        categoryId: categoryId ?? this.categoryId,
      );
  MangaCategoryData copyWithCompanion(MangasCategoriesCompanion data) {
    return MangaCategoryData(
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaCategoryData(')
          ..write('mangaId: $mangaId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mangaId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaCategoryData &&
          other.mangaId == this.mangaId &&
          other.categoryId == this.categoryId);
}

class MangasCategoriesCompanion extends UpdateCompanion<MangaCategoryData> {
  final Value<int> mangaId;
  final Value<int> categoryId;
  final Value<int> rowid;
  const MangasCategoriesCompanion({
    this.mangaId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangasCategoriesCompanion.insert({
    required int mangaId,
    required int categoryId,
    this.rowid = const Value.absent(),
  }) : mangaId = Value(mangaId),
       categoryId = Value(categoryId);
  static Insertable<MangaCategoryData> custom({
    Expression<int>? mangaId,
    Expression<int>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mangaId != null) 'manga_id': mangaId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangasCategoriesCompanion copyWith({
    Value<int>? mangaId,
    Value<int>? categoryId,
    Value<int>? rowid,
  }) {
    return MangasCategoriesCompanion(
      mangaId: mangaId ?? this.mangaId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mangaId.present) {
      map['manga_id'] = Variable<int>(mangaId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangasCategoriesCompanion(')
          ..write('mangaId: $mangaId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lastReadMeta = const VerificationMeta(
    'lastRead',
  );
  @override
  late final GeneratedColumn<DateTime> lastRead = GeneratedColumn<DateTime>(
    'last_read',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeReadMeta = const VerificationMeta(
    'timeRead',
  );
  @override
  late final GeneratedColumn<int> timeRead = GeneratedColumn<int>(
    'time_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, chapterId, lastRead, timeRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('last_read')) {
      context.handle(
        _lastReadMeta,
        lastRead.isAcceptableOrUnknown(data['last_read']!, _lastReadMeta),
      );
    }
    if (data.containsKey('time_read')) {
      context.handle(
        _timeReadMeta,
        timeRead.isAcceptableOrUnknown(data['time_read']!, _timeReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      timeRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_read'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryData extends DataClass implements Insertable<HistoryData> {
  final int id;
  final int chapterId;
  final DateTime? lastRead;
  final int timeRead;
  const HistoryData({
    required this.id,
    required this.chapterId,
    this.lastRead,
    required this.timeRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    if (!nullToAbsent || lastRead != null) {
      map['last_read'] = Variable<DateTime>(lastRead);
    }
    map['time_read'] = Variable<int>(timeRead);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      lastRead: lastRead == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRead),
      timeRead: Value(timeRead),
    );
  }

  factory HistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      lastRead: serializer.fromJson<DateTime?>(json['lastRead']),
      timeRead: serializer.fromJson<int>(json['timeRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'lastRead': serializer.toJson<DateTime?>(lastRead),
      'timeRead': serializer.toJson<int>(timeRead),
    };
  }

  HistoryData copyWith({
    int? id,
    int? chapterId,
    Value<DateTime?> lastRead = const Value.absent(),
    int? timeRead,
  }) => HistoryData(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    lastRead: lastRead.present ? lastRead.value : this.lastRead,
    timeRead: timeRead ?? this.timeRead,
  );
  HistoryData copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryData(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      lastRead: data.lastRead.present ? data.lastRead.value : this.lastRead,
      timeRead: data.timeRead.present ? data.timeRead.value : this.timeRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lastRead: $lastRead, ')
          ..write('timeRead: $timeRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, lastRead, timeRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.lastRead == this.lastRead &&
          other.timeRead == this.timeRead);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryData> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<DateTime?> lastRead;
  final Value<int> timeRead;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.timeRead = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    this.lastRead = const Value.absent(),
    this.timeRead = const Value.absent(),
  }) : chapterId = Value(chapterId);
  static Insertable<HistoryData> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<DateTime>? lastRead,
    Expression<int>? timeRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (lastRead != null) 'last_read': lastRead,
      if (timeRead != null) 'time_read': timeRead,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<DateTime?>? lastRead,
    Value<int>? timeRead,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      lastRead: lastRead ?? this.lastRead,
      timeRead: timeRead ?? this.timeRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (lastRead.present) {
      map['last_read'] = Variable<DateTime>(lastRead.value);
    }
    if (timeRead.present) {
      map['time_read'] = Variable<int>(timeRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lastRead: $lastRead, ')
          ..write('timeRead: $timeRead')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MangasTable mangas = $MangasTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MangasCategoriesTable mangasCategories = $MangasCategoriesTable(
    this,
  );
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mangas,
    chapters,
    categories,
    mangasCategories,
    historyEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mangas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chapters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mangas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mangas_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mangas_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chapters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('history_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MangasTableCreateCompanionBuilder =
    MangasCompanion Function({
      Value<int> id,
      required int source,
      required String url,
      required String title,
      Value<String?> artist,
      Value<String?> author,
      Value<String?> description,
      Value<String?> genre,
      Value<int> status,
      Value<String?> thumbnailUrl,
      Value<bool> favorite,
      Value<DateTime?> dateAdded,
      Value<DateTime?> lastUpdate,
      Value<int> viewerFlags,
      Value<int> chapterFlags,
    });
typedef $$MangasTableUpdateCompanionBuilder =
    MangasCompanion Function({
      Value<int> id,
      Value<int> source,
      Value<String> url,
      Value<String> title,
      Value<String?> artist,
      Value<String?> author,
      Value<String?> description,
      Value<String?> genre,
      Value<int> status,
      Value<String?> thumbnailUrl,
      Value<bool> favorite,
      Value<DateTime?> dateAdded,
      Value<DateTime?> lastUpdate,
      Value<int> viewerFlags,
      Value<int> chapterFlags,
    });

final class $$MangasTableReferences
    extends BaseReferences<_$AppDatabase, $MangasTable, MangaData> {
  $$MangasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<ChapterData>>
  _chaptersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: $_aliasNameGenerator(db.mangas.id, db.chapters.mangaId),
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.mangaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MangasCategoriesTable, List<MangaCategoryData>>
  _mangasCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mangasCategories,
    aliasName: $_aliasNameGenerator(db.mangas.id, db.mangasCategories.mangaId),
  );

  $$MangasCategoriesTableProcessedTableManager get mangasCategoriesRefs {
    final manager = $$MangasCategoriesTableTableManager(
      $_db,
      $_db.mangasCategories,
    ).filter((f) => f.mangaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mangasCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MangasTableFilterComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewerFlags => $composableBuilder(
    column: $table.viewerFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterFlags => $composableBuilder(
    column: $table.chapterFlags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.mangaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mangasCategoriesRefs(
    Expression<bool> Function($$MangasCategoriesTableFilterComposer f) f,
  ) {
    final $$MangasCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangasCategories,
      getReferencedColumn: (t) => t.mangaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.mangasCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MangasTableOrderingComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewerFlags => $composableBuilder(
    column: $table.viewerFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterFlags => $composableBuilder(
    column: $table.chapterFlags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MangasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get viewerFlags => $composableBuilder(
    column: $table.viewerFlags,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterFlags => $composableBuilder(
    column: $table.chapterFlags,
    builder: (column) => column,
  );

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.mangaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mangasCategoriesRefs<T extends Object>(
    Expression<T> Function($$MangasCategoriesTableAnnotationComposer a) f,
  ) {
    final $$MangasCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangasCategories,
      getReferencedColumn: (t) => t.mangaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mangasCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MangasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangasTable,
          MangaData,
          $$MangasTableFilterComposer,
          $$MangasTableOrderingComposer,
          $$MangasTableAnnotationComposer,
          $$MangasTableCreateCompanionBuilder,
          $$MangasTableUpdateCompanionBuilder,
          (MangaData, $$MangasTableReferences),
          MangaData,
          PrefetchHooks Function({bool chaptersRefs, bool mangasCategoriesRefs})
        > {
  $$MangasTableTableManager(_$AppDatabase db, $MangasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> source = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<DateTime?> lastUpdate = const Value.absent(),
                Value<int> viewerFlags = const Value.absent(),
                Value<int> chapterFlags = const Value.absent(),
              }) => MangasCompanion(
                id: id,
                source: source,
                url: url,
                title: title,
                artist: artist,
                author: author,
                description: description,
                genre: genre,
                status: status,
                thumbnailUrl: thumbnailUrl,
                favorite: favorite,
                dateAdded: dateAdded,
                lastUpdate: lastUpdate,
                viewerFlags: viewerFlags,
                chapterFlags: chapterFlags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int source,
                required String url,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<DateTime?> lastUpdate = const Value.absent(),
                Value<int> viewerFlags = const Value.absent(),
                Value<int> chapterFlags = const Value.absent(),
              }) => MangasCompanion.insert(
                id: id,
                source: source,
                url: url,
                title: title,
                artist: artist,
                author: author,
                description: description,
                genre: genre,
                status: status,
                thumbnailUrl: thumbnailUrl,
                favorite: favorite,
                dateAdded: dateAdded,
                lastUpdate: lastUpdate,
                viewerFlags: viewerFlags,
                chapterFlags: chapterFlags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MangasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({chaptersRefs = false, mangasCategoriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chaptersRefs) db.chapters,
                    if (mangasCategoriesRefs) db.mangasCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chaptersRefs)
                        await $_getPrefetchedData<
                          MangaData,
                          $MangasTable,
                          ChapterData
                        >(
                          currentTable: table,
                          referencedTable: $$MangasTableReferences
                              ._chaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MangasTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mangaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mangasCategoriesRefs)
                        await $_getPrefetchedData<
                          MangaData,
                          $MangasTable,
                          MangaCategoryData
                        >(
                          currentTable: table,
                          referencedTable: $$MangasTableReferences
                              ._mangasCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MangasTableReferences(
                                db,
                                table,
                                p0,
                              ).mangasCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mangaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MangasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangasTable,
      MangaData,
      $$MangasTableFilterComposer,
      $$MangasTableOrderingComposer,
      $$MangasTableAnnotationComposer,
      $$MangasTableCreateCompanionBuilder,
      $$MangasTableUpdateCompanionBuilder,
      (MangaData, $$MangasTableReferences),
      MangaData,
      PrefetchHooks Function({bool chaptersRefs, bool mangasCategoriesRefs})
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required int mangaId,
      required String url,
      required String name,
      Value<String?> scanlator,
      Value<bool> read,
      Value<bool> bookmark,
      Value<int> lastPageRead,
      Value<double> chapterNumber,
      Value<DateTime?> dateUpload,
      Value<DateTime?> dateFetch,
      Value<int> sourceOrder,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<int> mangaId,
      Value<String> url,
      Value<String> name,
      Value<String?> scanlator,
      Value<bool> read,
      Value<bool> bookmark,
      Value<int> lastPageRead,
      Value<double> chapterNumber,
      Value<DateTime?> dateUpload,
      Value<DateTime?> dateFetch,
      Value<int> sourceOrder,
    });

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, ChapterData> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MangasTable _mangaIdTable(_$AppDatabase db) => db.mangas.createAlias(
    $_aliasNameGenerator(db.chapters.mangaId, db.mangas.id),
  );

  $$MangasTableProcessedTableManager get mangaId {
    final $_column = $_itemColumn<int>('manga_id')!;

    final manager = $$MangasTableTableManager(
      $_db,
      $_db.mangas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HistoryEntriesTable, List<HistoryData>>
  _historyEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historyEntries,
    aliasName: $_aliasNameGenerator(
      db.chapters.id,
      db.historyEntries.chapterId,
    ),
  );

  $$HistoryEntriesTableProcessedTableManager get historyEntriesRefs {
    final manager = $$HistoryEntriesTableTableManager(
      $_db,
      $_db.historyEntries,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanlator => $composableBuilder(
    column: $table.scanlator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPageRead => $composableBuilder(
    column: $table.lastPageRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpload => $composableBuilder(
    column: $table.dateUpload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFetch => $composableBuilder(
    column: $table.dateFetch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$MangasTableFilterComposer get mangaId {
    final $$MangasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableFilterComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historyEntriesRefs(
    Expression<bool> Function($$HistoryEntriesTableFilterComposer f) f,
  ) {
    final $$HistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanlator => $composableBuilder(
    column: $table.scanlator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPageRead => $composableBuilder(
    column: $table.lastPageRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpload => $composableBuilder(
    column: $table.dateUpload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFetch => $composableBuilder(
    column: $table.dateFetch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$MangasTableOrderingComposer get mangaId {
    final $$MangasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableOrderingComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scanlator =>
      $composableBuilder(column: $table.scanlator, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<bool> get bookmark =>
      $composableBuilder(column: $table.bookmark, builder: (column) => column);

  GeneratedColumn<int> get lastPageRead => $composableBuilder(
    column: $table.lastPageRead,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpload => $composableBuilder(
    column: $table.dateUpload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateFetch =>
      $composableBuilder(column: $table.dateFetch, builder: (column) => column);

  GeneratedColumn<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => column,
  );

  $$MangasTableAnnotationComposer get mangaId {
    final $$MangasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableAnnotationComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historyEntriesRefs<T extends Object>(
    Expression<T> Function($$HistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$HistoryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          ChapterData,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (ChapterData, $$ChaptersTableReferences),
          ChapterData,
          PrefetchHooks Function({bool mangaId, bool historyEntriesRefs})
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mangaId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> scanlator = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<bool> bookmark = const Value.absent(),
                Value<int> lastPageRead = const Value.absent(),
                Value<double> chapterNumber = const Value.absent(),
                Value<DateTime?> dateUpload = const Value.absent(),
                Value<DateTime?> dateFetch = const Value.absent(),
                Value<int> sourceOrder = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                mangaId: mangaId,
                url: url,
                name: name,
                scanlator: scanlator,
                read: read,
                bookmark: bookmark,
                lastPageRead: lastPageRead,
                chapterNumber: chapterNumber,
                dateUpload: dateUpload,
                dateFetch: dateFetch,
                sourceOrder: sourceOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mangaId,
                required String url,
                required String name,
                Value<String?> scanlator = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<bool> bookmark = const Value.absent(),
                Value<int> lastPageRead = const Value.absent(),
                Value<double> chapterNumber = const Value.absent(),
                Value<DateTime?> dateUpload = const Value.absent(),
                Value<DateTime?> dateFetch = const Value.absent(),
                Value<int> sourceOrder = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                mangaId: mangaId,
                url: url,
                name: name,
                scanlator: scanlator,
                read: read,
                bookmark: bookmark,
                lastPageRead: lastPageRead,
                chapterNumber: chapterNumber,
                dateUpload: dateUpload,
                dateFetch: dateFetch,
                sourceOrder: sourceOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mangaId = false, historyEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historyEntriesRefs) db.historyEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (mangaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mangaId,
                                    referencedTable: $$ChaptersTableReferences
                                        ._mangaIdTable(db),
                                    referencedColumn: $$ChaptersTableReferences
                                        ._mangaIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historyEntriesRefs)
                        await $_getPrefetchedData<
                          ChapterData,
                          $ChaptersTable,
                          HistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ChaptersTableReferences
                              ._historyEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).historyEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      ChapterData,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (ChapterData, $$ChaptersTableReferences),
      ChapterData,
      PrefetchHooks Function({bool mangaId, bool historyEntriesRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> position,
      Value<int> flags,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> position,
      Value<int> flags,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MangasCategoriesTable, List<MangaCategoryData>>
  _mangasCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mangasCategories,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.mangasCategories.categoryId,
    ),
  );

  $$MangasCategoriesTableProcessedTableManager get mangasCategoriesRefs {
    final manager = $$MangasCategoriesTableTableManager(
      $_db,
      $_db.mangasCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mangasCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mangasCategoriesRefs(
    Expression<bool> Function($$MangasCategoriesTableFilterComposer f) f,
  ) {
    final $$MangasCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangasCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.mangasCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  Expression<T> mangasCategoriesRefs<T extends Object>(
    Expression<T> Function($$MangasCategoriesTableAnnotationComposer a) f,
  ) {
    final $$MangasCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangasCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mangasCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryData,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryData, $$CategoriesTableReferences),
          CategoryData,
          PrefetchHooks Function({bool mangasCategoriesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> flags = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                position: position,
                flags: flags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> position = const Value.absent(),
                Value<int> flags = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                position: position,
                flags: flags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mangasCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mangasCategoriesRefs) db.mangasCategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mangasCategoriesRefs)
                    await $_getPrefetchedData<
                      CategoryData,
                      $CategoriesTable,
                      MangaCategoryData
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._mangasCategoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).mangasCategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryData,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryData, $$CategoriesTableReferences),
      CategoryData,
      PrefetchHooks Function({bool mangasCategoriesRefs})
    >;
typedef $$MangasCategoriesTableCreateCompanionBuilder =
    MangasCategoriesCompanion Function({
      required int mangaId,
      required int categoryId,
      Value<int> rowid,
    });
typedef $$MangasCategoriesTableUpdateCompanionBuilder =
    MangasCategoriesCompanion Function({
      Value<int> mangaId,
      Value<int> categoryId,
      Value<int> rowid,
    });

final class $$MangasCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MangasCategoriesTable,
          MangaCategoryData
        > {
  $$MangasCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MangasTable _mangaIdTable(_$AppDatabase db) => db.mangas.createAlias(
    $_aliasNameGenerator(db.mangasCategories.mangaId, db.mangas.id),
  );

  $$MangasTableProcessedTableManager get mangaId {
    final $_column = $_itemColumn<int>('manga_id')!;

    final manager = $$MangasTableTableManager(
      $_db,
      $_db.mangas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.mangasCategories.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MangasCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MangasCategoriesTable> {
  $$MangasCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MangasTableFilterComposer get mangaId {
    final $$MangasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableFilterComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangasCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangasCategoriesTable> {
  $$MangasCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MangasTableOrderingComposer get mangaId {
    final $$MangasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableOrderingComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangasCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangasCategoriesTable> {
  $$MangasCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MangasTableAnnotationComposer get mangaId {
    final $$MangasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mangaId,
      referencedTable: $db.mangas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangasTableAnnotationComposer(
            $db: $db,
            $table: $db.mangas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangasCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangasCategoriesTable,
          MangaCategoryData,
          $$MangasCategoriesTableFilterComposer,
          $$MangasCategoriesTableOrderingComposer,
          $$MangasCategoriesTableAnnotationComposer,
          $$MangasCategoriesTableCreateCompanionBuilder,
          $$MangasCategoriesTableUpdateCompanionBuilder,
          (MangaCategoryData, $$MangasCategoriesTableReferences),
          MangaCategoryData,
          PrefetchHooks Function({bool mangaId, bool categoryId})
        > {
  $$MangasCategoriesTableTableManager(
    _$AppDatabase db,
    $MangasCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangasCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangasCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangasCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> mangaId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangasCategoriesCompanion(
                mangaId: mangaId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int mangaId,
                required int categoryId,
                Value<int> rowid = const Value.absent(),
              }) => MangasCategoriesCompanion.insert(
                mangaId: mangaId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MangasCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mangaId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mangaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mangaId,
                                referencedTable:
                                    $$MangasCategoriesTableReferences
                                        ._mangaIdTable(db),
                                referencedColumn:
                                    $$MangasCategoriesTableReferences
                                        ._mangaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$MangasCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$MangasCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MangasCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangasCategoriesTable,
      MangaCategoryData,
      $$MangasCategoriesTableFilterComposer,
      $$MangasCategoriesTableOrderingComposer,
      $$MangasCategoriesTableAnnotationComposer,
      $$MangasCategoriesTableCreateCompanionBuilder,
      $$MangasCategoriesTableUpdateCompanionBuilder,
      (MangaCategoryData, $$MangasCategoriesTableReferences),
      MangaCategoryData,
      PrefetchHooks Function({bool mangaId, bool categoryId})
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required int chapterId,
      Value<DateTime?> lastRead,
      Value<int> timeRead,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<DateTime?> lastRead,
      Value<int> timeRead,
    });

final class $$HistoryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryData> {
  $$HistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
        $_aliasNameGenerator(db.historyEntries.chapterId, db.chapters.id),
      );

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<int>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeRead => $composableBuilder(
    column: $table.timeRead,
    builder: (column) => ColumnFilters(column),
  );

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeRead => $composableBuilder(
    column: $table.timeRead,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  GeneratedColumn<int> get timeRead =>
      $composableBuilder(column: $table.timeRead, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryData,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (HistoryData, $$HistoryEntriesTableReferences),
          HistoryData,
          PrefetchHooks Function({bool chapterId})
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<DateTime?> lastRead = const Value.absent(),
                Value<int> timeRead = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                chapterId: chapterId,
                lastRead: lastRead,
                timeRead: timeRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                Value<DateTime?> lastRead = const Value.absent(),
                Value<int> timeRead = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                chapterId: chapterId,
                lastRead: lastRead,
                timeRead: timeRead,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable: $$HistoryEntriesTableReferences
                                    ._chapterIdTable(db),
                                referencedColumn:
                                    $$HistoryEntriesTableReferences
                                        ._chapterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryData,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (HistoryData, $$HistoryEntriesTableReferences),
      HistoryData,
      PrefetchHooks Function({bool chapterId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MangasTableTableManager get mangas =>
      $$MangasTableTableManager(_db, _db.mangas);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$MangasCategoriesTableTableManager get mangasCategories =>
      $$MangasCategoriesTableTableManager(_db, _db.mangasCategories);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
