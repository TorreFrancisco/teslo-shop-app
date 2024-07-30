import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

import '../../../../shared/infrastructure/inputs/inputs.dart';

final productFormProvider = StateNotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, Product>((ref, product) {
  //final createUpdateCallback = ref.watch(productsRepositoryProvider).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(productsProvider.notifier).createOrUdpateProduct;
  return ProductFormNotifier(
      product: product, onSubmitCallback: createUpdateCallback);
});

//METODOS PARA MANEJAR LOS ESTADOS
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Future<bool> Function(Map<String, dynamic> productLike)?
      onSubmitCallback;

  ProductFormNotifier({
    this.onSubmitCallback,
    required Product product,
  }) : super(ProductFormState(
          id: product.id,
          title: Title.dirty(product.title),
          slug: Slug.dirty(product.slug),
          price: Price.dirty(product.price),
          inStock: Stock.dirty(product.stock),
          sizes: product.sizes,
          gender: product.gender,
          description: product.description,
          tags: product.tags.join(', '),
          images: product.images,
        ));

  Future<bool> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;
    final productLike = {
      'id': (state.id == 'new') ? null : state.id,
      "title": state.title.value,
      "price": state.price.value,
      "description": state.description,
      "slug": state.slug.value,
      "stock": state.inStock.value,
      "sizes": state.sizes,
      "gender": state.gender,
      "tags": state.tags.split(','),
      "images": state.images
          .map((image) =>
              image.replaceAll('${Environment.apiUrl}/files/product/', ''))
          .toList()
    };
    try {
      return await onSubmitCallback!(productLike);
    } catch (e) {
      return false;
    }
  }

  void updateProductImage(String path) {
    state = state.copywith(
      images: [...state.images, path],
    );
  }

  void _touchedEverything() {
    state = state.copywith(
        isFormValid: Formz.validate([
      Title.dirty(state.title.value),
      Slug.dirty(state.slug.value),
      Price.dirty(state.price.value),
      Stock.dirty(state.inStock.value)
    ]));
  }

  void onTitleChanged(String value) {
    state = state.copywith(
      title: Title.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value)
      ]),
    );
  }

  void onSlugChanged(String value) {
    state = state.copywith(
      slug: Slug.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value)
      ]),
    );
  }

  void onPriceChanged(double value) {
    state = state.copywith(
      price: Price.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(value),
        Stock.dirty(state.inStock.value)
      ]),
    );
  }

  void onStockChanged(int value) {
    state = state.copywith(
      inStock: Stock.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(value)
      ]),
    );
  }

  void onSizeChanged(List<String> sizes) {
    state = state.copywith(sizes: sizes);
  }

  void onGenderChanged(String gender) {
    state = state.copywith(gender: gender);
  }

  void onDescriptionChanged(String description) {
    state = state.copywith(description: description);
  }

  void onTagsChanged(String tags) {
    state = state.copywith(tags: tags);
  }
}

//COMO QUIERO QUE LUZCA MI ESTADO
class ProductFormState {
  final bool isFormValid;
  final String? id;
  final Title title;
  final Slug slug;
  final Price price;
  final List<String> sizes;
  final String gender;
  final Stock inStock;
  final String description;
  final String tags;
  final List<String> images;

  ProductFormState(
      {this.isFormValid = false,
      this.id,
      this.title = const Title.dirty(''),
      this.slug = const Slug.dirty(''),
      this.price = const Price.dirty(0),
      this.sizes = const [],
      this.gender = '',
      this.inStock = const Stock.dirty(0),
      this.description = '',
      this.tags = '',
      this.images = const []});

  ProductFormState copywith({
    bool? isFormValid,
    String? id,
    Title? title,
    Slug? slug,
    Price? price,
    List<String>? sizes,
    String? gender,
    Stock? inStock,
    String? description,
    String? tags,
    List<String>? images,
  }) =>
      ProductFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        price: price ?? this.price,
        sizes: sizes ?? this.sizes,
        gender: gender ?? this.gender,
        inStock: inStock ?? this.inStock,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        images: images ?? this.images,
      );
}
