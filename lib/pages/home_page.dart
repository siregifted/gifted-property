import 'package:flutter/material.dart';

import '../models/property.dart';
import '../repositories/property_repository.dart';
import '../widgets/property_card.dart';
import '../widgets/explore_abuja_locations.dart';
import 'properties_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const PropertyRepository _propertyRepository = PropertyRepository();
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<Property>> _featuredPropertiesFuture;

  @override
  void initState() {
    super.initState();
    _featuredPropertiesFuture = _propertyRepository.getFeaturedProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProperties({String initialSearchQuery = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PropertiesPage(initialSearchQuery: initialSearchQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GIFTED PROPERTY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: compact
            ? [
                PopupMenuButton<String>(
                  tooltip: 'Open navigation',
                  onSelected: (value) {
                    if (value == 'properties') {
                      _openProperties();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'properties',
                      child: Text('Properties'),
                    ),
                  ],
                ),
              ]
            : [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: _openProperties,
                  child: const Text(
                    'Properties',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
              ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildFeaturedSection(),
            _buildLocationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 40,
            vertical: compact ? 48 : 80,
          ),
          decoration: const BoxDecoration(color: Color(0xFF102A43)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FIND A PROPERTY\nWORTH INVESTING IN.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 36 : 48,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Discover premium homes, investment properties and off-plan developments in Abuja.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 16 : 18,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) =>
                                _openProperties(initialSearchQuery: value),
                            decoration: const InputDecoration(
                              hintText: 'Search location or property',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () => _openProperties(
                            initialSearchQuery: _searchController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B1F33),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 16 : 28,
                              vertical: 18,
                            ),
                          ),
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 40,
            vertical: compact ? 40 : 60,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Properties',
                    style: TextStyle(
                      fontSize: compact ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1F33),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore selected published properties available through Gifted Property.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder(
                    future: _featuredPropertiesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Featured properties could not be loaded. Please try the Properties page again.',
                          style: TextStyle(color: Colors.black54),
                        );
                      }
                      final properties = snapshot.data ?? [];
                      if (properties.isEmpty) {
                        return const Text(
                          'No featured properties are published yet.',
                          style: TextStyle(color: Colors.black54),
                        );
                      }
                      final visibleProperties = properties.take(3).toList();
                      if (constraints.maxWidth < 700) {
                        return Column(
                          children: [
                            for (var index = 0; index < visibleProperties.length; index++) ...[
                              PropertyCard(property: visibleProperties[index]),
                              if (index != visibleProperties.length - 1)
                                const SizedBox(height: 20),
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var index = 0; index < visibleProperties.length; index++) ...[
                            if (index > 0) const SizedBox(width: 20),
                            Expanded(
                              child: PropertyCard(property: visibleProperties[index]),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: _openProperties,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('View all properties'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationsSection() {
    return ExploreAbujaLocations(
      onLocationSelected: (location) =>
          _openProperties(initialSearchQuery: location),
    );
  }
}
