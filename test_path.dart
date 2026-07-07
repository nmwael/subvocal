import "dart:io";
void main() {
  final uri1 = Uri.parse("https://api.opensubtitles.com/api/v1/login");
  final uri2 = Uri.parse("https://api.opensubtitles.com/api/v1/download");
  print("login path: ${uri1.path}");
  print("download path: ${uri2.path}");
  print("login endsWith /login: ${uri1.path.endsWith("/login")}");
  print("download endsWith /download: ${uri2.path.endsWith("/download")}");
}
