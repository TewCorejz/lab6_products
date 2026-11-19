import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_field.dart';
import '../widgets/sort_menu_button.dart';
import '../widgets/state_views.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник продуктов'),
        actions: const [SortMenuButton()],
      ),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ProductSearchField(),
          ),
          CategoryChips(),
          SizedBox(height: 8),
          Expanded(child: _ProductListBody()),
        ],
      ),
    );
  }
}

class _ProductListBody extends StatelessWidget {
  const _ProductListBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductState>();

    if (state.status == LoadStatus.initial || state.isLoading) {
      return const LoadingView();
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage ?? 'Не удалось загрузить данные',
        onRetry: state.retry,
      );
    }

    if (state.isEmptyResult) {
      return EmptyView(
        icon: Icons.search_off,
        title: 'Ничего не найдено',
        message: state.hasActiveFilters
            ? 'Попробуйте изменить запрос или выбрать другую категорию'
            : 'Каталог пока пуст',
        actionLabel: state.hasActiveFilters ? 'Сбросить фильтры' : null,
        onAction: state.hasActiveFilters ? state.resetFilters : null,
      );
    }

    final products = state.visibleProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Найдено товаров: ${products.length}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: GridView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}