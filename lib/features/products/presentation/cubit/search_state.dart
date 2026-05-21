import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

class SearchState extends Equatable {
  final String query;
  final String? category;
  final String? storeName;

  // Each inner list is one API "page".
  final List<List<Product>> pages;
  final int currentPageIndex;
  final bool isLoadingFirstPage;
  final bool isLoadingNextPage;
  final bool hasMore;
  final String? errorMessage;

  const SearchState({
    required this.query,
    required this.category,
    required this.storeName,
    required this.pages,
    required this.currentPageIndex,
    required this.isLoadingFirstPage,
    required this.isLoadingNextPage,
    required this.hasMore,
    required this.errorMessage,
  });

  factory SearchState.initial() => const SearchState(
        query: '',
        category: null,
        storeName: null,
        pages: [],
        currentPageIndex: 0,
        isLoadingFirstPage: false,
        isLoadingNextPage: false,
        hasMore: true,
        errorMessage: null,
      );

  int get loadedPagesCount => pages.length;

  SearchState copyWith({
    String? query,
    String? category,
    String? storeName,
    List<List<Product>>? pages,
    int? currentPageIndex,
    bool? isLoadingFirstPage,
    bool? isLoadingNextPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      category: category ?? this.category,
      storeName: storeName ?? this.storeName,
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        query,
        category,
        storeName,
        pages,
        currentPageIndex,
        isLoadingFirstPage,
        isLoadingNextPage,
        hasMore,
        errorMessage,
      ];
}

