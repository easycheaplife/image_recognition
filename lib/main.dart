import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Recognition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MyHomePage(title: '图片识别'),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isImage;
  final String? imageUrl;
  final String? recognitionResult;

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isImage = false,
    this.imageUrl,
    this.recognitionResult,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // 读取图片数据
      final Uint8List imageBytes = await image.readAsBytes();

      // 创建 multipart 请求
      var uri = Uri.parse('http://8.140.248.32:80/api/file/upload');
      var request = http.MultipartRequest('POST', uri);

      // 添加文件，使用原始文件名和 MIME 类型
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: image.name,
        contentType: MediaType.parse(
            'image/${image.name.split('.').last}'), // 根据文件扩展名设置正确的 MIME 类型
      );

      request.files.add(multipartFile);

      // 发送请求
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['data'] != null &&
            responseData['data']['file_name'] != null) {
          var fileName = responseData['data']['file_name'];
          var downloadUrl =
              'http://8.140.248.32:80/api/file/download/$fileName';

          // 添加上传成功的消息
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                text: downloadUrl,
                isMe: true,
                isImage: true,
                imageUrl: downloadUrl,
              ),
            );
          });

          // 调用图像识别 API
          try {
            var recognitionUrl = Uri.parse(
                'http://8.140.248.32:80/api/image-recognition?image_url=$downloadUrl');
            var recognitionResponse = await http.get(recognitionUrl);
            if (recognitionResponse.statusCode == 200) {
              var recognitionData = jsonDecode(recognitionResponse.body);
              var recognitionResult =
                  recognitionData['data']['data']['content'];

              setState(() {
                _messages[0] = ChatMessage(
                  text: downloadUrl,
                  isMe: true,
                  isImage: true,
                  imageUrl: downloadUrl,
                  recognitionResult: recognitionResult,
                );
              });
            } else {
              _showError('图像识别失败');
            }
          } catch (e) {
            _showError('图像识别出错: $e');
          }
        } else {
          _showError('上传应格式错误');
        }
      } else {
        _showError('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      _showError('错误: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (message.isImage && message.imageUrl != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.network(
                                          message.imageUrl!,
                                          height: 250,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (message.recognitionResult != null)
                                        Container(
                                          padding: const EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '识别结果',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                message.recognitionResult!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _isUploading ? null : _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '选择图片',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isUploading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            '正在处理...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
