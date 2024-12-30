class AppConfig {
  static const String baseUrl = 'http://8.140.248.32:80';

  static const String uploadUrl = '$baseUrl/api/file/upload';
  static const String downloadUrl = '$baseUrl/api/file/download';
  static const String imageRecognitionUrl = '$baseUrl/api/image-recognition';

  static String getDownloadUrl(String fileName) => '$downloadUrl/$fileName';
  static String getImageRecognitionUrl(String imageUrl) =>
      '$imageRecognitionUrl?image_url=$imageUrl';
}
