import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/search_products.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProducts _searchProducts;
  Timer? _debounce;

  static const int _pageSize = 50;
  static const _debounceDuration = Duration(milliseconds: 450);

  SearchCubit(this._searchProducts) : super(SearchState.initial());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  /// Updates the query and auto-triggers search after a short debounce pause.
  void setQuery(String query) {
    emit(state.copyWith(query: query, errorMessage: null));
    _debounce?.cancel();
    // Trigger automatically once the user pauses typing.
    _debounce = Timer(_debounceDuration, () {
      if (!isClosed) searchFirstPage();
    });
  }

  void setCategory(String? category) {
    emit(state.copyWith(category: category, errorMessage: null));
  }

  void setStore(String? storeName) {
    emit(state.copyWith(storeName: storeName, errorMessage: null));
  }

  void setCurrentPageIndex(int index) {
    emit(state.copyWith(currentPageIndex: index));
  }

  Future<void> searchFirstPage() async {
    _debounce?.cancel();
    emit(state.copyWith(
      isLoadingFirstPage: true,
      isLoadingNextPage: false,
      pages: const [],
      currentPageIndex: 0,
      hasMore: true,
      errorMessage: null,
    ));

    final result = await _fetchPage(1);
    if (isClosed) return;
    if (result.isSuccess) {
      final items = result.data!;
      emit(state.copyWith(
        pages: [items],
        isLoadingFirstPage: false,
        hasMore: items.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        isLoadingFirstPage: false,
        errorMessage: result.failure!.message,
      ));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingFirstPage || state.isLoadingNextPage || !state.hasMore) return;
    if (state.pages.isEmpty) {
      await searchFirstPage();
      return;
    }

    emit(state.copyWith(isLoadingNextPage: true, errorMessage: null));
    final nextPageNumber = state.pages.length + 1;
    final result = await _fetchPage(nextPageNumber);
    if (isClosed) return;
    if (result.isSuccess) {
      final items = result.data!;
      emit(state.copyWith(
        pages: [...state.pages, items],
        isLoadingNextPage: false,
        hasMore: items.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        isLoadingNextPage: false,
        errorMessage: result.failure!.message,
      ));
    }
  }

  Future<Result<List<Product>>> _fetchPage(int page) {
    final q = state.query.trim();
    return _searchProducts(
      query: q.isEmpty ? null : q,
      category: state.category,
      storeName: state.storeName,
      page: page,
      limit: _pageSize,
    );
  }
}
