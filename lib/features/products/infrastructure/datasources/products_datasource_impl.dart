import 'package:dio/dio.dart';
import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/infrastructure/errors/product_errors.dart';

import '../../domain/datasources/products_datasource.dart';
import '../mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource {
  late final Dio dio; //late porque se configura en otro momento
  final String accessToken;
  ProductsDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(baseUrl: Environment.apiUrl, headers: {
            'Authorization':
                'Bearer $accessToken' //NO ME IMPORTA DE DONDE VENGA EL ACCESSTOKEN, EVENTUALMENTE VIENE DEL PROVIDER
          }),
        );

  Future<String> _upLoadFile(String path) async {
    try {
      final fileName = path.split('/').last;

      final FormData data = FormData.fromMap(
          {'file': MultipartFile.fromFileSync(path, filename: fileName)});

      final response = await dio.post('/files/product', data: data);

      return response.data['image'];
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<String>> _uploadPhotos(List<String> photos) async {
    final photosToUpload =
        photos.where((element) => element.contains('/')).toList();
    final photosToIgnore =
        photos.where((element) => !element.contains('/')).toList();
    final List<Future<String>> uploadJob = photosToUpload
        .map(_upLoadFile)
        .toList(); //generar strings que quiero que sean parte de el url de las imagenes
    final newImages = await Future.wait(uploadJob);
    return [...photosToIgnore, ...newImages];
  }

  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async {
    try {
      final String? productId = productLike['id'];

      productLike['images'] = await _uploadPhotos(
        productLike['images'],
      );
      final String method = (productId == null) ? 'POST' : 'PATCH';
      final String url =
          (productId == null) ? '/products' : '/products/$productId';
      productLike.remove('id');
      final response = await dio.request(url,
          data: productLike, options: Options(method: method));

      final product = ProductMapper.jsonToEntity(response.data);

      return product;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity(response.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];
    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }
    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }
}
