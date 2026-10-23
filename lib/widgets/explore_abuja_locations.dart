import 'package:flutter/material.dart';

const _locationNavy = Color(0xFF0B1F33);
const _locationMuted = Color(0xFF5B6B7C);
const _locationGold = Color(0xFFC9A227);
const _locationSurface = Color(0xFFF6F8FB);
const _locationBorder = Color(0xFFE4E9F0);

const _premiumLocations = <String>[
  'Maitama',
  'Asokoro',
  'Wuse 1',
  'Wuse 2',
  'Guzape',
  'Katampe',
  'Katampe Extension',
  'Jabi',
  'Central Area',
  'Garki',
];

const _residentialLocations = <String>[
  'Gwarinpa',
  'Lokogoma',
  'Galadimawa',
  'Apo',
  'Life Camp',
  'Karsana',
  'Kaba District',
  'Dakwo',
  'Kabusa',
  'Durumi',
  'Dawaki',
  'Gaduwa',
  'Mbora',
  'Utako',
  'Kado',
  'Dutse Alhaji',
  'Kubwa',
  'Lugbe',
  'Pyakasa',
  'Airport Road',
  'Karu',
  'Nyanya',
  'Kurudu',
  'Orozo',
  'Karshi',
  'Idu',
  'Dei-Dei',
  'Zuba',
  'Bwari',
  'Gwagwalada',
];

List<String> _filterLocations(Iterable<String> locations, String query) {
  final normalized = query.trim().toLowerCase();
  final unique = locations.toSet().toList();
  if (normalized.isEmpty) return unique;
  return unique
      .where((location) => location.toLowerCase().contains(normalized))
      .toList();
}

/// Searchable Abuja district picker. The parent decides what to do with a
/// selected location; this widget does not assume properties exist there.
class ExploreAbujaLocations extends StatefulWidget {
  const ExploreAbujaLocations({super.key, this.onLocationSelected});

  final ValueChanged<String>? onLocationSelected;

  @override
  State<ExploreAbujaLocations> createState() => _ExploreAbujaLocationsState();
}

class _ExploreAbujaLocationsState extends State<ExploreAbujaLocations> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(String location) {
    widget.onLocationSelected?.call(location);
  }

  void _showAllLocations() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AllAbujaLocationsSheet(
        onSelected: (location) {
          Navigator.of(sheetContext).pop();
          _selectLocation(location);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final allLocations = [..._premiumLocations, ..._residentialLocations];
    final matches = _filterLocations(allLocations, _query);

    return Container(
      width: double.infinity,
      color: _locationSurface,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 40,
        vertical: MediaQuery.sizeOf(context).width < 600 ? 40 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: _locationGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Explore Abuja Locations',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _locationNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a district to search published properties there.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: _locationMuted,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search Abuja districts',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _locationBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _locationBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _locationNavy,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                searching ? 'MATCHING DISTRICTS' : 'POPULAR LOCATIONS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: _locationMuted,
                ),
              ),
              const SizedBox(height: 12),
              if (searching)
                if (matches.isEmpty)
                  Text(
                    'No Abuja district matches "${_query.trim()}". Try another name.',
                    style: const TextStyle(color: _locationMuted),
                  )
                else
                  _LocationChipWrap(
                    locations: matches,
                    onSelected: _selectLocation,
                  )
              else
                _LocationChipWrap(
                  locations: _premiumLocations,
                  onSelected: _selectLocation,
                ),
              if (!searching) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _showAllLocations,
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('View all locations'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _locationNavy,
                    side: const BorderSide(color: _locationNavy),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AllAbujaLocationsSheet extends StatefulWidget {
  const _AllAbujaLocationsSheet({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  State<_AllAbujaLocationsSheet> createState() =>
      _AllAbujaLocationsSheetState();
}

class _AllAbujaLocationsSheetState extends State<_AllAbujaLocationsSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premium = _filterLocations(_premiumLocations, _query);
    final residential = _filterLocations(_residentialLocations, _query);
    final noMatches = premium.isEmpty && residential.isEmpty;

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _locationBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'All Abuja locations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _locationNavy,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search all districts',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: noMatches
                  ? Center(
                      child: Text(
                        'No Abuja district matches "${_query.trim()}".',
                        style: const TextStyle(color: _locationMuted),
                      ),
                    )
                  : ListView(
                      children: [
                        if (premium.isNotEmpty) ...[
                          const _LocationGroupLabel('Premium locations'),
                          _LocationChipWrap(
                            locations: premium,
                            onSelected: widget.onSelected,
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (residential.isNotEmpty) ...[
                          const _LocationGroupLabel(
                            'Residential and developing locations',
                          ),
                          _LocationChipWrap(
                            locations: residential,
                            onSelected: widget.onSelected,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationGroupLabel extends StatelessWidget {
  const _LocationGroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: _locationMuted,
      ),
    ),
  );
}

class _LocationChipWrap extends StatelessWidget {
  const _LocationChipWrap({required this.locations, required this.onSelected});

  final List<String> locations;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 340
        ? 7.0
        : 14.0;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final location in locations)
          Semantics(
            button: true,
            label: 'Search properties in $location',
            child: Material(
              color: Colors.white,
              shape: const StadiumBorder(
                side: BorderSide(color: _locationBorder),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(location),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ).copyWith(left: horizontalPadding, right: horizontalPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: _locationGold,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _locationNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
