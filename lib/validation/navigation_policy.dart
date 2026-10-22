import '../models/property.dart';

bool canPreviewPropertyRoute(Property property) =>
    !property.isSample &&
    property.hasCoordinates &&
    (property.hasVerifiedLocation ||
        property.locationVerificationStatus == 'approximate');

bool requiresApproximateRouteAcknowledgement(Property property) =>
    canPreviewPropertyRoute(property) &&
    property.locationVerificationStatus == 'approximate';
