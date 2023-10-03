import 'dart:convert';

mixin CreatedAt {
  get createdAt {
    final now = DateTime.now();
    final createdAt = [now.toString(), now.timeZoneOffset.inHours];
    return jsonEncode(createdAt);
  }
}
