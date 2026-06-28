abstract final class DefaultBlockedApps {
  static const List<String> packages = [
    'com.instagram.android',
    'com.google.android.youtube',
    'com.twitter.android',
    'com.facebook.katana',
    'com.snapchat.android',
    'com.zhiliaoapp.musically',
    'com.reddit.frontpage',
    'com.whatsapp',
    'com.facebook.orca',
    'com.discord',
    'com.netflix.mediaclient',
    'com.spotify.music',
    'com.linkedin.android',
    'com.pinterest',
  ];

  static const Map<String, String> labels = {
    'com.instagram.android': 'Instagram',
    'com.google.android.youtube': 'YouTube',
    'com.twitter.android': 'X (Twitter)',
    'com.facebook.katana': 'Facebook',
    'com.snapchat.android': 'Snapchat',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.reddit.frontpage': 'Reddit',
    'com.whatsapp': 'WhatsApp',
    'com.facebook.orca': 'Messenger',
    'com.discord': 'Discord',
    'com.netflix.mediaclient': 'Netflix',
    'com.spotify.music': 'Spotify',
    'com.linkedin.android': 'LinkedIn',
    'com.pinterest': 'Pinterest',
  };
}
