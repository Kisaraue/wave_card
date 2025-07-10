import 'package:uuid/uuid.dart';
import 'profile_card.dart';

class Contact {
  final String id;
  final ProfileCard profileCard;
  final DateTime receivedAt;
  final bool isFavorite;
  final List<String> tags;
  final String? notes;

  Contact({
    String? id,
    required this.profileCard,
    DateTime? receivedAt,
    bool? isFavorite,
    List<String>? tags,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        receivedAt = receivedAt ?? DateTime.now(),
        isFavorite = isFavorite ?? false,
        tags = tags ?? [];

  Contact copyWith({
    ProfileCard? profileCard,
    bool? isFavorite,
    List<String>? tags,
    String? notes,
  }) {
    return Contact(
      id: id,
      profileCard: profileCard ?? this.profileCard,
      receivedAt: receivedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileCard': profileCard.toJson(),
      'receivedAt': receivedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
      'notes': notes,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      profileCard: ProfileCard.fromJson(json['profileCard']),
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isFavorite: json['isFavorite'] as bool,
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ContactFilter {
  final String? searchQuery;
  final List<String> tags;
  final bool? isFavorite;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ContactSortBy sortBy;
  final bool isAscending;

  ContactFilter({
    this.searchQuery,
    List<String>? tags,
    this.isFavorite,
    this.fromDate,
    this.toDate,
    this.sortBy = ContactSortBy.receivedAt,
    this.isAscending = false,
  }) : tags = tags ?? [];

  ContactFilter copyWith({
    String? searchQuery,
    List<String>? tags,
    bool? isFavorite,
    DateTime? fromDate,
    DateTime? toDate,
    ContactSortBy? sortBy,
    bool? isAscending,
  }) {
    return ContactFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  bool matches(Contact contact) {
    // Search query filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final card = contact.profileCard;
      if (!card.fullName.toLowerCase().contains(query) &&
          !card.jobTitle.toLowerCase().contains(query) &&
          !card.company.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Tags filter
    if (tags.isNotEmpty) {
      if (!tags.any((tag) => contact.tags.contains(tag))) {
        return false;
      }
    }

    // Favorite filter
    if (isFavorite != null && contact.isFavorite != isFavorite) {
      return false;
    }

    // Date range filter
    if (fromDate != null && contact.receivedAt.isBefore(fromDate!)) {
      return false;
    }
    if (toDate != null && contact.receivedAt.isAfter(toDate!)) {
      return false;
    }

    return true;
  }
}

enum ContactSortBy {
  receivedAt,
  name,
  company,
  favorite,
}

extension ContactSortByExtension on ContactSortBy {
  String get displayName {
    switch (this) {
      case ContactSortBy.receivedAt:
        return 'Date Received';
      case ContactSortBy.name:
        return 'Name';
      case ContactSortBy.company:
        return 'Company';
      case ContactSortBy.favorite:
        return 'Favorite';
    }
  }
}