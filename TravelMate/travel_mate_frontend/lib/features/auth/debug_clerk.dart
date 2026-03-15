import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(validateStatus: (s) => true, followRedirects: false),
  );

  final res = await dio.get(
    'https://many-rooster-99.clerk.accounts.dev/v1/client?_is_native=1',
    options: Options(
      headers: {
        'Authorization': 'Bearer ',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    ),
  );

  print('Status: ${res.statusCode}');
  print('Headers: ${res.headers.map}');
  print('Data: ${res.data}');
}
