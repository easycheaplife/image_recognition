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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: message.isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (message.isImage && message.imageUrl != null)
                            Column(
                              crossAxisAlignment: message.isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    message.imageUrl!,
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // 显示图片URL
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                                // 显示识别结果
                                if (message.recognitionResult != null)
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.only(top: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12.0),
                                      border:
                                          Border.all(color: Colors.green[100]!),
                                    ),
                                    child: Text(message.recognitionResult!),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 简化后的底部工具栏
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        color: _isUploading ? Colors.grey : Colors.blue,
                        iconSize: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
