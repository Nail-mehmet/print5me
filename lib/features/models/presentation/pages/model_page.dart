import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/model_bloc.dart';
import '../bloc/model_event.dart';
import '../../domain/repo/model_repo.dart';
import '../bloc/model_state.dart';
import '../../domain/entity/model.dart';



class ModelHomePage extends StatefulWidget {
  const ModelHomePage({super.key});

  @override
  State<ModelHomePage> createState() => _ModelHomePageState();
}

class _ModelHomePageState extends State<ModelHomePage> {
  String selectedCategory = 'Tümü';
  late List<String> categories = ['Tümü', 'EĞLENCE', 'POPÜLER'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => ModelBloc(ModelRepository())..add(FetchModelsEvent()),
        child: BlocBuilder<ModelBloc, ModelState>(
          builder: (context, state) {
            // Kategorileri dinamik olarak güncelle
            if (state is ModelLoaded) {
              final allCategories = state.models.map((e) => e.category).toSet().toList();
              if (allCategories.length > categories.length - 1) {
                categories = ['Tümü']..addAll(allCategories);
              }
            }

            return Column(
              children: [
                _buildSearchField(),
                _buildCategoryChips(),
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Model ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected ? category : 'Tümü';
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: const Color(0xFFF0F4F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                ),
              ),
              elevation: isSelected ? 4 : 0,
              shadowColor: Colors.black26,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ModelState state) {
    if (state is ModelLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ModelLoaded) {
      // Önce kategoriye göre filtrele
      var filteredModels = selectedCategory == 'Tümü'
          ? state.models
          : state.models.where((model) => model.category == selectedCategory).toList();

      // Sonra arama sorgusuna göre filtrele
      if (_searchQuery.isNotEmpty) {
        filteredModels = filteredModels.where((model) =>
            model.title.toLowerCase().contains(_searchQuery)).toList();
      }

      return filteredModels.isEmpty
          ? const Center(child: Text('Sonuç bulunamadı'))
          : _buildModelGrid(filteredModels, context);
    } else if (state is ModelError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox();
  }

  Widget _buildModelGrid(List<Model> models, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModelDetailPage(model: model),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      model.pic,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModelDetailPage extends StatelessWidget {
  final Model model;

  const ModelDetailPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(model.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  model.pic,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', model.category),
            _buildDetailRow('Oluşturan', model.createdBy),
            _buildDetailRow('Etiketler', model.tags.join(", ")),
            _buildDetailRow('Ek Bilgi', model.additional),
            const SizedBox(height: 16),
            const Text('URLler:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...model.url.map((url) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SelectableText(url),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(
        width: 100,
        child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        //const SizedBox(width: 8),
        ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}