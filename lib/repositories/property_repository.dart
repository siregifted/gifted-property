import '../data/properties.dart';
import '../models/property.dart';

class PropertyRepository {
  const PropertyRepository();

  List<Property> getProperties() {
    return properties;
  }
}
