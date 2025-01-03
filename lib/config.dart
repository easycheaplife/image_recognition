class AppConfig {
  static const String baseUrl = 'http://8.140.248.32:80';

  static const String uploadUrl = '$baseUrl/api/file/upload';
  static const String downloadUrl = '$baseUrl/api/file/download';
  static const String imageRecognitionUrl = '$baseUrl/api/image-recognition';

  static String getDownloadUrl(String fileName) => '$downloadUrl/$fileName';
  static String getImageRecognitionUrl(String imageUrl) =>
      '$imageRecognitionUrl?image_url=$imageUrl&question=${Uri.encodeComponent(imageRecognitionPrompt)}';

  static const String imageRecognitionPrompt = '''请分析图片内容：
1. 如果是文字内容，直接返回文字原文
2. 如果不是文字，请详细描述：
   - 主体对象：请准确说明具体物品/生物的名称（如植物要说出具体品种，物品要说出具体类型）
   - 外观特征：形状、大小、颜色、纹理等明显特征
   - 空间布局：物体的位置关系和摆放方式
   - 环境场景：周围环境、背景、光线等
   - 显著细节：独特标记、装饰、状态等''';
}
