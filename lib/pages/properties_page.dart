import 'package:flutter/material.dart';

import '../models/property.dart';
import '../repositories/property_repository.dart';
import '../widgets/property_card.dart';

class PropertiesPage extends StatefulWidget {
  final String initialSearchQuery;

  const PropertiesPage({super.key, this.initialSearchQuery = ''});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final PropertyRepository _propertyRepository = const PropertyRepository();
  late final TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Property> get _filteredProperties {
    final query = _searchQuery.trim().toLowerCase();
    final allProperties = _propertyRepository.getProperties();

    if (query.isEmpty) {
      return allProperties;
    }

    return allProperties.where((property) {
      return property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query) ||
          property.propertyType.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _filteredProperties;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text(
          'Properties',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 40,
          vertical: compact ? 28 : 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Properties',
                  style: TextStyle(
                    fontSize: compact ? 28 : 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B1F33),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Explore premium properties available through Gifted Property.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by location, property type or title',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (filteredProperties.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text(
                        'No properties found. Try another location or property type.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return Column(
                          children: [
                            for (final property in filteredProperties) ...[
                              PropertyCard(property: property),
                              const SizedBox(height: 20),
                            ],
                          ],
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProperties.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              mainAxisExtent: 520,
                            ),
                        itemBuilder: (context, index) {
                          return PropertyCard(
                            property: filteredProperties[index],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
