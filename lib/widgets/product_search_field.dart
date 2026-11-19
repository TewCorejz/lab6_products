import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';

class ProductSearchField extends StatelessWidget {
  const ProductSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: context.read<ProductState>().setQuery,
      decoration: const InputDecoration(hintText: 'Поиск'),
    );
  }
}