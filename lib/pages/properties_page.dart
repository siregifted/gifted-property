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
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery);
    _propertiesFuture = _propertyRepository.getPublishedProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retryLoad() {
    setState(() {
      _propertiesFuture = _propertyRepository.getPublishedProperties();
    });
  }

  List<Property> _filter(List<Property> properties) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return properties;
    return properties.where((property) {
      return property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query) ||
          property.propertyType.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text('Properties',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text('Our Properties',
                    style: TextStyle(
                      fontSize: compact ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1F33),
                    )),
                const SizedBox(height: 10),
                const Text(
                  'Explore published properties available through Gifted Property.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by location, property type or title',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<Property>>(
                  future: _propertiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _statusMessage(
                        'Properties could not be loaded. Check your connection and try again.',
                        action: TextButton.icon(
                          onPressed: _retryLoad,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      );
                    }
                    final properties = _filter(snapshot.data ?? const []);
                    if (properties.isEmpty) {
                      return _statusMessage(
                        _searchQuery.trim().isEmpty
                            ? 'There are no published properties yet. Please check back soon.'
                            : 'No properties found. Try another location or property type.',
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 700) {
                          return Column(
                            children: [
                              for (final property in properties) ...[
                                PropertyCard(property: property),
                                const SizedBox(height: 20),
                              ],
                            ],
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: properties.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: 520,
                          ),
                          itemBuilder: (context, index) =>
                              PropertyCard(property: properties[index]),
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

  Widget _statusMessage(String message, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
      child: Center(
        child: Column(
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: Colors.black54)),
            if (action != null) ...[
              const SizedBox(height: 12),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
