import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data/product_repository.dart';
import 'screens/home_screen.dart';
import 'state/product_state.dart';

void main() {
  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductState(ProductRepository())..init(),
      child: MaterialApp(
        title: 'Справочник продуктов',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}