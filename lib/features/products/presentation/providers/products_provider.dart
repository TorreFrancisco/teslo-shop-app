import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_repository_provider.dart';

//SABE COMO LUCE LOS ESTADOS DE EL PRODUCTO Y LOS METODOS QUE MANEJAN A ESOS ESTADOS DE LOS PRODUCTOS
final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  return ProductsNotifier(productsRepository: productsRepository);
});

//MANEJAR EL ESTADO BASE DE LOS VALORES DE PRODUCTSSTATE MEDIANTE METODOS
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository productsRepository;

  ProductsNotifier({required this.productsRepository})
      : super(ProductsState()) {
    loadNextPage();
  }
  //ACA ACTUALIZO EL ESTADO DE LOS PRODUCTOS (TSHIRT ---MODIFICACION---> SHIRT)
  Future<bool> createOrUdpateProduct(Map<String, dynamic> productLike) async {
    try {
      final product = await productsRepository.createUpdateProduct(productLike);
      final isProductInList =
          state.products.any((element) => element.id == product.id);
      if (!isProductInList) {
        state = state.copywith(
          products: [...state.products, product],
        );
        return true;
      }
      state = state.copywith(
          products: state.products
              .map(
                (element) => (element.id == product.id) ? product : element,
              )
              .toList()); //siempre poner tolist para que no regrese un iterable (necesito la lista de los productos)
      return true;
    } catch (e) {
      return false;
    }
  }

//METODO PARA CARGAR MAS PRODUCTOS (CARGAR MAS PAGINAS)
  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) {
      return; //Peticiones innecesarias no pueden haber
    }
    state = state.copywith(
      isLoading: true,
    );

    final products = await productsRepository.getProductsByPage(
        limit: state.limit, offset: state.offset);
    if (products.isEmpty) {
      state = state.copywith(
        isLoading: false,
        isLastPage: true,
      );
      return;
    }
    state = state.copywith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        products: [...state.products, ...products]);
  }
}

//SETEAR LOS VALORES COMO QUIERO QUE SU ESTADO LUZCA
class ProductsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;

  ProductsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.products = const []});

  ProductsState copywith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Product>? products,
  }) =>
      ProductsState(
          isLastPage: isLastPage ?? this.isLastPage,
          limit: limit ?? this.limit,
          offset: offset ?? this.offset,
          isLoading: isLoading ?? this.isLoading,
          products: products ?? this.products);
}
