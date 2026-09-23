import 'package:flutter/material.dart';

import '../repositories/property_repository.dart';
import '../widgets/property_card.dart';
import 'properties_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Widget build(BuildContext context) {
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
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PropertiesPage()),
              );
            },
            child: const Text(
              'Properties',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('About', style: TextStyle(color: Colors.white)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(color: Color(0xFF102A43)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIND A PROPERTY\nWORTH INVESTING IN.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Discover premium homes, investment properties and off-plan developments in Abuja.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 35),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search location or property',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1F33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
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
  }

  Widget _buildFeaturedSection() {
    final properties = _propertyRepository.getProperties();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured Properties',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1F33),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Explore selected properties available through Gifted Property.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  if (width < 700) {
                    return Column(
                      children: [
                        PropertyCard(property: properties[0]),
                        const SizedBox(height: 20),
                        PropertyCard(property: properties[1]),
                        const SizedBox(height: 20),
                        PropertyCard(property: properties[2]),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: PropertyCard(property: properties[0])),
                      const SizedBox(width: 20),
                      Expanded(child: PropertyCard(property: properties[1])),
                      const SizedBox(width: 20),
                      Expanded(child: PropertyCard(property: properties[2])),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsSection() {
    const locations = [
      'Maitama',
      'Asokoro',
      'Katampe',
      'Guzape',
      'Jahi',
      'Mabushi',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      color: const Color(0xFFF4F6F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'Explore Abuja',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1F33),
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: locations.map((location) {
                  return Chip(
                    avatar: const Icon(Icons.location_on, size: 18),
                    label: Text(location),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
