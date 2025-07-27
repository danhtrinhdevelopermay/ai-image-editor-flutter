import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

enum ProcessingOperation {
  removeBackground,
  removeText,
  cleanup,
  removeLogo,
  uncrop,
  imageUpscaling,
  reimagine,
  productPhotography,
  textToImage,
  replaceBackground,
}

class ClipDropService {
  static const String _baseUrl = 'https://clipdrop-api.co';
  static const String _removeBackgroundUrl = '$_baseUrl/remove-background/v1';
  static const String _removeTextUrl = '$_baseUrl/remove-text/v1';
  static const String _cleanupUrl = '$_baseUrl/cleanup/v1';
  static const String _uncropUrl = '$_baseUrl/uncrop/v1';
  static const String _imageUpscalingUrl = '$_baseUrl/image-upscaling/v1';
  static const String _reimagineUrl = '$_baseUrl/reimagine/v1';
  static const String _productPhotographyUrl = '$_baseUrl/product-photography/v1';
  static const String _textToImageUrl = '$_baseUrl/text-to-image/v1';
  static const String _replaceBackgroundUrl = '$_baseUrl/replace-background/v1';
  
  // API keys - primary and backup
  static const String _primaryApiKey = '2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664';
  static const String _backupApiKey = '7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2';
  
  // Current API key being used
  String _currentApiKey = _primaryApiKey;
  bool _usingBackupApi = false;
  
  final Dio _dio = Dio();

  ClipDropService() {
    _updateApiKey();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  void _updateApiKey() {
    _dio.options.headers['x-api-key'] = _currentApiKey;
  }

  void _switchToBackupApi() {
    if (!_usingBackupApi) {
      _currentApiKey = _backupApiKey;
      _usingBackupApi = true;
      _updateApiKey();
      print('Đã chuyển sang API dự phòng do API chính hết credit');
    }
  }

  void _resetToPrimaryApi() {
    if (_usingBackupApi) {
      _currentApiKey = _primaryApiKey;
      _usingBackupApi = false;
      _updateApiKey();
      print('Đã reset về API chính');
    }
  }

  // Failover execution wrapper
  Future<T> _executeWithFailover<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e) {
      // Check if it's a credit/quota issue (HTTP 429, 402 or specific error messages)
      bool isQuotaError = e.response?.statusCode == 429 || 
                         e.response?.statusCode == 402 ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('quota')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('credit'));
      
      if (isQuotaError && !_usingBackupApi) {
        print('API chính hết credit/quota, đang chuyển sang API dự phòng...');
        _switchToBackupApi();
        
        // Retry with backup API
        try {
          return await operation();
        } catch (retryError) {
          // If backup also fails, throw original error
          rethrow;
        }
      } else if (isQuotaError && _usingBackupApi) {
        // Both APIs exhausted
        throw Exception('Cả hai API đều đã hết credit/quota. Vui lòng thử lại sau hoặc liên hệ để nạp thêm credit.');
      }
      rethrow;
    }
  }

  Future<Uint8List> processImage(
    File imageFile, 
    ProcessingOperation operation, {
    File? maskFile,
    File? backgroundFile,
    String? prompt,
    String? aspectRatio,
    String? scene,
    double? uncropExtendRatio,
    int? targetWidth,
    int? targetHeight,
  }) async {
    return await _executeWithFailover(() async {
      if (_currentApiKey.isEmpty) {
        throw Exception('Vui lòng cấu hình API key Clipdrop');
      }

      String apiUrl;
      switch (operation) {
        case ProcessingOperation.removeBackground:
          apiUrl = _removeBackgroundUrl;
          break;
        case ProcessingOperation.removeText:
          apiUrl = _removeTextUrl;
          break;
        case ProcessingOperation.cleanup:
          apiUrl = _cleanupUrl;
          break;
        case ProcessingOperation.removeLogo:
          apiUrl = _removeTextUrl; // Logo removal uses same endpoint as text removal
          break;
        case ProcessingOperation.uncrop:
          apiUrl = _uncropUrl;
          break;
        case ProcessingOperation.imageUpscaling:
          apiUrl = _imageUpscalingUrl;
          break;
        case ProcessingOperation.reimagine:
          apiUrl = _reimagineUrl;
          break;
        case ProcessingOperation.productPhotography:
          apiUrl = _productPhotographyUrl;
          break;
        case ProcessingOperation.textToImage:
          apiUrl = _textToImageUrl;
          break;
        case ProcessingOperation.replaceBackground:
          apiUrl = _replaceBackgroundUrl;
          break;
      }

      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.${imageFile.path.split('.').last}',
        ),
      });

      // Add specific parameters for each operation
      switch (operation) {
        case ProcessingOperation.cleanup:
          if (maskFile != null) {
            formData.files.add(MapEntry(
              'mask_file',
              await MultipartFile.fromFile(
                maskFile.path,
                filename: 'mask.${maskFile.path.split('.').last}',
              ),
            ));
          }
          break;
        
        case ProcessingOperation.uncrop:
          if (aspectRatio != null) {
            formData.fields.add(MapEntry('aspect_ratio', aspectRatio));
          }
          if (uncropExtendRatio != null) {
            formData.fields.add(MapEntry('extend_ratio', uncropExtendRatio.toString()));
          }
          break;
        
        case ProcessingOperation.imageUpscaling:
          if (targetWidth != null) {
            formData.fields.add(MapEntry('target_width', targetWidth.toString()));
          }
          if (targetHeight != null) {
            formData.fields.add(MapEntry('target_height', targetHeight.toString()));
          }
          break;
        
        case ProcessingOperation.reimagine:
          // Reimagine doesn't need additional parameters
          break;
        
        case ProcessingOperation.productPhotography:
          if (scene != null) {
            formData.fields.add(MapEntry('scene', scene));
          }
          break;
        
        case ProcessingOperation.textToImage:
          if (prompt != null) {
            formData.fields.add(MapEntry('prompt', prompt));
          }
          break;
        
        case ProcessingOperation.replaceBackground:
          if (backgroundFile != null) {
            formData.files.add(MapEntry(
              'background_file',
              await MultipartFile.fromFile(
                backgroundFile.path,
                filename: 'background.${backgroundFile.path.split('.').last}',
              ),
            ));
          } else if (prompt != null) {
            formData.fields.add(MapEntry('prompt', prompt));
          }
          break;
        
        default:
          // No additional parameters needed
          break;
      }

      final response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('API key không hợp lệ - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Không có quyền truy cập API - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Đã vượt quá giới hạn API - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else {
        throw Exception('Lỗi kết nối: ${e.message} - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
    }
    });
  }

  // Convenience methods for backward compatibility and easier usage
  Future<Uint8List> removeBackground(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.removeBackground);
  }

  Future<Uint8List> removeText(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.removeText);
  }

  Future<Uint8List> cleanup(File imageFile, File maskFile) async {
    return processImage(imageFile, ProcessingOperation.cleanup, maskFile: maskFile);
  }

  Future<Uint8List> removeLogo(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.removeLogo);
  }

  // New API methods
  Future<Uint8List> uncrop(File imageFile, {String? aspectRatio, double? extendRatio}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.uncrop,
      aspectRatio: aspectRatio,
      uncropExtendRatio: extendRatio,
    );
  }

  Future<Uint8List> upscaleImage(File imageFile, {int? targetWidth, int? targetHeight}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.imageUpscaling,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }

  Future<Uint8List> reimagine(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.reimagine);
  }

  Future<Uint8List> productPhotography(File imageFile, {String? scene}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.productPhotography,
      scene: scene,
    );
  }

  Future<Uint8List> textToImage(String prompt) async {
    // For text to image, we create a dummy file
    throw UnimplementedError('Text to image requires different implementation');
  }

  Future<Uint8List> replaceBackground(File imageFile, {File? backgroundFile, String? prompt}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.replaceBackground,
      backgroundFile: backgroundFile,
      prompt: prompt,
    );
  }

  // Special method for text-to-image that doesn't require an input image
  Future<Uint8List> generateImageFromText(String prompt) async {
    return await _executeWithFailover(() async {
      if (_currentApiKey.isEmpty) {
        throw Exception('Vui lòng cấu hình API key Clipdrop');
      }

      final formData = FormData.fromMap({
        'prompt': prompt,
      });

      final response = await _dio.post(
        _textToImageUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('API key không hợp lệ - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Không có quyền truy cập API - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Đã vượt quá giới hạn API - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      } else {
        throw Exception('Lỗi kết nối: ${e.message} - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e - ${_usingBackupApi ? "API dự phòng" : "API chính"}');
    }
    });
  }

  // Utility methods to get API status
  bool get isUsingBackupApi => _usingBackupApi;
  String get currentApiStatus => _usingBackupApi ? 'API dự phòng' : 'API chính';
  
  // Method to manually reset to primary API (useful for testing/recovery)
  void resetToPrimaryApi() {
    _resetToPrimaryApi();
  }
}
