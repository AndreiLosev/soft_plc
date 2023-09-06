mixin CreatedAt {
    get createdAt {
        final now = DateTime.now();
        final createdAt = [now, now.timeZoneOffset.inHours];
        return createdAt.toString();
    }
}
