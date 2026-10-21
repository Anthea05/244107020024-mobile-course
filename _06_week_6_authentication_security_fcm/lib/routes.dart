class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  
  // Fungsi helper untuk generate rute dinamis
  static String pengumuman(String id) => '/pengumuman/$id';
}