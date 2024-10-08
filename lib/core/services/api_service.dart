// ignore_for_file: constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/constants/exceptions.dart';
import '../utils/helpers/auth_helper.dart';
import '../utils/helpers/network_info_helper.dart';
import 'logger_service.dart';

class ApiService {
  static ApiService? _instance;

  Dio _dio = Dio();
  static const Duration TIMEOUT_DURATION = Duration(seconds: 120);

  static ApiService getInstance() {
    _instance ??= ApiService();
    return _instance!;
  }

  ApiService() {
    _dio = Dio();
    _initInterceptor();
  }

  _initInterceptor() {
    _dio.interceptors.clear();
    _dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options); //continue
    }, onResponse: (response, handler) {
      return handler.next(response); // continue
    }, onError: (DioException error, handler) async {
      LoggerService.log('****** Dio Interceptor onError $error');
      LoggerService.log('****** Dio Interceptor onError path ${error.requestOptions.path}');
      // un-authorized (note: expired user token)
      if (error.response?.statusCode == 401) {
        try {
          if (error.requestOptions.headers['Authorization'] == null) {
            LoggerService.log('***** Dio onError no token');
            handler.next(error);
            return;
          } else if (error.requestOptions.headers['Authorization'] != AuthHelper.getIdToken(isAuth: true)) {
            // it is already updated
            LoggerService.log('***** Dio onError token is already updated');
            // note it will go here if auto logout is performed too
            final Response response = await _retry(error.requestOptions);
            handler.resolve(response);
            return;
          }

          // handle refresh token
          //   await AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl(), localDataSource: AuthLocaleDataSourceImpl())
          //       .checkAndHandleUserAccessToken();

          final Response response = await _retry(error.requestOptions);
          LoggerService.log('****** Dio Interceptor going to return response');
          handler.resolve(response);
        } catch (e) {
          LoggerService.log('****** Dio Interceptor going to return error $e');
          if (e is DioException) {
            return handler.next(e);
          } else {
            return handler.next(error);
          }
        }
      } else {
        handler.next(error);
      }
    }));
  }

  Future<dynamic>? tryCatchAsyncWrapper(String functionName, Function fn, {Function? onErrorCallback}) async {
    try {
      if (await NetworkInfo().isConnected()) {
        dynamic value = await fn();
        return value;
      } else {
        throw NetworkException();
      }
    } on SocketException catch (_) {
      throw NetworkException();
    } on NetworkException {
      rethrow;
    } on DioException catch (error) {
      LoggerService.log('logMessage  $error');
      if (error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionTimeout) {
        throw NetworkException();
      }
      if (error.type == DioExceptionType.badResponse) {
        throw ServerErrorException();
      }
      if (error.message != null &&
          (error.message!.contains('connection abort') || error.message!.contains('Failed host lookup'))) {
        throw NetworkException();
      }
      LoggerService.log('error.type ${error.type}');
      LoggerService.log('eeeeeeee $error');
      LoggerService.log('$functionName ERROR !!!! ${error.response?.statusCode}');

      LoggerService.log('$functionName ERROR !!!! ${error.response?.data}');
      try {
        var responseJson = json.decode(utf8.decode(error.response?.data));
        if (responseJson['message'] != null) {
          LoggerService.log('responseJson[message] != null $responseJson');
          LoggerService.log('responseJson[message] != null ${responseJson['message']}');
          if (responseJson['message'] is List) {
            throw ExceptionWithMessage(message: responseJson['message'][0]);
          } else {
            throw ExceptionWithMessage(message: responseJson['message']);
          }
        } else {
          return _handleErrorStatus(error.response?.statusCode);
        }
      } catch (e) {
        LoggerService.log('logMessage ##### $e');
        rethrow;
      }
    } catch (error) {
      LoggerService.log('$functionName ERROR !!!! $error');
      throw Exception();
    }
  }

  Future<dynamic> postWithoutInterceptor({Uri? uri, String? body, bool parseJson = true}) async {
    return await tryCatchAsyncWrapper('postWithoutInterceptor', () async {
      Dio localDio = Dio();
      localDio.options.headers['content-type'] = 'application/json';
      localDio.options.responseType = ResponseType.bytes;
      final response = await localDio.postUri(uri!, data: body);
      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      return responseJson;
    });
  }

  Future<dynamic> get({Uri? uri, bool isAuth = true, bool parseJson = true}) async {
    return await tryCatchAsyncWrapper('get', () async {
      _setDioHeaders(isAuth);
      LoggerService.log('-diiiooo111 ${_dio.options.headers['Authorization']}');

      LoggerService.log('-diiiooo ${_dio.options.headers['x-api-key']}');
      final response = await _dio.getUri(uri!);
      LoggerService.log('-diiiooo response $response');

      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      LoggerService.log('responseJSON $responseJson');
      return responseJson;
    });
  }

  Future<dynamic> post(
      {required Uri uri, required dynamic body, bool isAuth = true, bool shouldParseBody = true, bool parseJson = true}) async {
    return await tryCatchAsyncWrapper('post', () async {
      LoggerService.log('post uri is $uri shouldParse $shouldParseBody  parseJson $parseJson  isAuth $isAuth');
      LoggerService.log('post body is $body');

      dynamic data;
      if (shouldParseBody) {
        data = json.encode(body);
      } else {
        data = body;
      }
      LoggerService.log('post data is $data');
      _setDioHeaders(isAuth);

      LoggerService.log('post headers is ${_dio.options.headers}');
      Response response = await _dio.postUri(uri, data: data);

      LoggerService.log('post uri response is $response');

      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      LoggerService.log('post uri responseJson is $responseJson');

      return responseJson;
    });
  }

  Future<dynamic> put({Uri? uri, dynamic body, bool isAuth = true, bool parseJson = true}) async {
    return await tryCatchAsyncWrapper('put', () async {
      _setDioHeaders(isAuth);
      final response = await _dio.putUri(uri!, data: body);
      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      return responseJson;
    });
  }

  Future<dynamic> patch({Uri? uri, String? body, bool isAuth = false, bool parseJson = true}) async {
    return await tryCatchAsyncWrapper('patch', () async {
      _setDioHeaders(isAuth);
      final response = await _dio.patchUri(uri!, data: body);
      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      return responseJson;
    });
  }

  Future<dynamic> delete({Uri? uri, bool isAuth = false, bool parseJson = true, String body = ""}) async {
    return await tryCatchAsyncWrapper('delete', () async {
      _setDioHeaders(isAuth);
      final response = await _dio.deleteUri(uri!, data: body);
      var responseJson = _returnResponse(response: response, parseJson: parseJson);
      return responseJson;
    });
  }

  bool _isSuccess(statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204 || statusCode == 208;
  }

  _handleErrorStatus(statusCode) {
    LoggerService.log('statusCode $statusCode');
    if (statusCode == 401) {
      throw UnAuthorizedException();
    } else {
      throw Exception();
    }
  }

  dynamic _returnResponse({Response? response, bool parseJson = true}) {
    if (_isSuccess(response!.statusCode)) {
      if (parseJson) {
        var responseJson = json.decode(utf8.decode(response.data)); // to parse Arabic
        return responseJson;
      } else {
        LoggerService.log(response.headers);
        return {'headers': response.headers, 'data': response.data};
      }
    }
    LoggerService.log('Error response.statusCode ${response.statusCode} ${response.headers}');
    LoggerService.log('post ERROR !!!! ${response.data}');
    try {
      var responseJson = json.decode(utf8.decode(response.data));
      if (responseJson['error_msg'] != null) {
        throw ExceptionWithMessage(message: responseJson['error_msg']);
      } else {
        _handleErrorStatus(response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    LoggerService.log('****** Dio Interceptor going to retry !!! ${requestOptions.path}');
    var localDio = Dio(); // use new dio object to not have interceptor

    localDio.options.sendTimeout = TIMEOUT_DURATION;
    localDio.options.connectTimeout = TIMEOUT_DURATION;
    localDio.options.receiveTimeout = TIMEOUT_DURATION;
    final options = Options(method: requestOptions.method, headers: requestOptions.headers);

    bool isAuth = false;
    if (options.headers != null && options.headers!['Authorization'] != null) {
      isAuth = true;
    }
    options.headers!['Authorization'] = AuthHelper.getIdToken(isAuth: isAuth);
    options.responseType = ResponseType.bytes;

    return localDio.request(requestOptions.path,
        data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
  }

  _setDioHeaders(bool isAuth) {
    _dio.options.headers['Authorization'] = AuthHelper.getIdToken(isAuth: isAuth);
    _dio.options.headers['x-api-key'] = 'saZAyrAGxg8lJ7YacVk8x2eIZJWxwpX134PT1s9P';
    _dio.options.headers['content-type'] = 'application/json';
    _dio.options.responseType = ResponseType.bytes;
    _dio.options.connectTimeout = TIMEOUT_DURATION;
    _dio.options.receiveTimeout = TIMEOUT_DURATION;
    _dio.options.sendTimeout = TIMEOUT_DURATION;
  }
}
