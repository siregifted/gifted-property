import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/property.dart';
import '../models/property_media.dart';
import '../widgets/property_location_map.dart';
import 'enquiry_page.dart';
import 'inspection_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  int _selectedMediaIndex = 0;

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '₦${(price / 1000000).toStringAsFixed(0)}M';
    }
    return '₦$price';
  }

  bool get _canSubmitLead =>
      !widget.property.isSample &&
      widget.property.id != null &&
      widget.property.id! > 0;

  Future<void> _openVideo(PropertyMedia media) async {
    final uri = Uri.tryParse(media.url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return;

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this property video.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this property video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text(
          'Property Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGallery(property),
                if (property.isSample) _buildDemoNotice(),
                Padding(
                  padding: EdgeInsets.all(compact ? 20 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: TextStyle(
                          fontSize: compact ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (property.hasVerifiedLocation &&
                          property.verifiedAddress != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Verified address: ${property.verifiedAddress}',
                          style: const TextStyle(
                            color: Color(0xFF16794B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        _formatPrice(property.price),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _infoChip(
                            Icons.bed_outlined,
                            '${property.bedrooms} Bedrooms',
                          ),
                          _infoChip(
                            Icons.bathtub_outlined,
                            '${property.bathrooms} Bathrooms',
                          ),
                          _infoChip(Icons.home_outlined, property.propertyType),
                          _infoChip(Icons.sell_outlined, property.status),
                        ],
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.description.isEmpty
                            ? 'No description has been published.'
                            : property.description,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      if (property.features.isNotEmpty) ...[
                        const SizedBox(height: 35),
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1F33),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...property.features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFF0B1F33),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      const Text(
                        'Location & directions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 15),
                      PropertyLocationMap(property: property),
                      const SizedBox(height: 30),
                      if (!_canSubmitLead) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE9D5A7)),
                          ),
                          child: Text(
                            property.isSample
                                ? 'Demo listing only. Enquiries and inspection requests are disabled.'
                                : 'This listing is not ready to accept requests yet.',
                            style: const TextStyle(
                              color: Color(0xFF704E00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compactButtons = constraints.maxWidth < 600;
                          final inspectionButton = ElevatedButton(
                            onPressed: _canSubmitLead
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InspectionPage(property: property),
                                    ),
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B1F33),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text('Schedule Inspection'),
                          );
                          final enquiryButton = OutlinedButton(
                            onPressed: _canSubmitLead
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EnquiryPage(property: property),
                                    ),
                                  )
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0B1F33),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text('Contact Agent'),
                          );

                          if (compactButtons) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                inspectionButton,
                                const SizedBox(height: 12),
                                enquiryButton,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: inspectionButton),
                              const SizedBox(width: 15),
                              Expanded(child: enquiryButton),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFFFF1D2),
      child: const Text(
        'DEMO ONLY — fictional listing and price; approximate area pin. Not for sale; do not use to arrange a viewing.',
        style: TextStyle(color: Color(0xFF704E00), fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildGallery(Property property) {
    final imageHeight = MediaQuery.sizeOf(context).width < 600 ? 260.0 : 500.0;
    final media = property.galleryMedia;

    if (media.isEmpty) {
      return Container(
        width: double.infinity,
        height: imageHeight,
        color: const Color(0xFFE8EEF3),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 90,
              color: Color(0xFF0B1F33),
            ),
            SizedBox(height: 15),
            Text(
              'Approved property media coming soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B1F33),
              ),
            ),
          ],
        ),
      );
    }

    final selectedIndex = _selectedMediaIndex < media.length
        ? _selectedMediaIndex
        : 0;
    final selected = media[selectedIndex];

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: selected.isImage
                  ? _buildNetworkImage(selected.url, BoxFit.cover)
                  : _buildVideoPreview(selected),
            ),
            if (selected.isCover)
              Positioned(
                left: 16,
                top: 16,
                child: Chip(
                  avatar: const Icon(Icons.star, size: 16),
                  label: Text(selected.isImage ? 'Cover photo' : 'Cover video'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (media.length > 1) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _galleryButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => setState(
                      () => _selectedMediaIndex =
                          (_selectedMediaIndex - 1 + media.length) %
                          media.length,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _galleryButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => setState(
                      () => _selectedMediaIndex =
                          (_selectedMediaIndex + 1) % media.length,
                    ),
                  ),
                ),
              ),
            ],
            if (selected.caption != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: Colors.black54,
                  child: Text(
                    selected.caption!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        if (media.length > 1)
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: media.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = media[index];
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMediaIndex = index),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0B1F33)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: item.isImage
                            ? _buildNetworkImage(item.url, BoxFit.cover)
                            : const ColoredBox(
                                color: Color(0xFF102A43),
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPreview(PropertyMedia media) {
    return Material(
      color: const Color(0xFF102A43),
      child: InkWell(
        onTap: () => _openVideo(media),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_fill, size: 84, color: Colors.white),
              const SizedBox(height: 8),
              const Text(
                'Open property video',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              if (media.caption != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    media.caption!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, BoxFit fit) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFE8EEF3),
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFE8EEF3),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 72,
            color: Color(0xFF0B1F33),
          ),
        ),
      ),
    );
  }

  Widget _galleryButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF0B1F33)),
          const SizedBox(width: 7),
          Text(label),
        ],
      ),
    );
  }
}
