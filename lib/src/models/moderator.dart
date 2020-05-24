import 'dart:convert';

class Moderator {
  final String name;
  final String authorFlairText;
  final List<String> modPermissions;
  final DateTime date;
  final String relId;
  final String id;
  final String authorFlairCssClass;

  Moderator(
    this.name,
    this.authorFlairText,
    this.modPermissions,
    this.date,
    this.relId,
    this.id,
    this.authorFlairCssClass,
  );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'authorFlairText': authorFlairText,
      'modPermissions': modPermissions,
      'date': date?.millisecondsSinceEpoch,
      'relId': relId,
      'id': id,
      'authorFlairCssClass': authorFlairCssClass,
    };
  }

  static Moderator fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Moderator(
      map['name'],
      map['author_flair_text'],
      List<String>.from(map['mod_permissions']),
      DateTime.fromMillisecondsSinceEpoch(map['date']),
      map['rel_id'],
      map['id'],
      map['author_flair_css_class'],
    );
  }

  String toJson() => json.encode(toMap());

  static Moderator fromJson(String source) => fromMap(json.decode(source));
}
