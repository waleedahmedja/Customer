import 'dart:math';

class LocationUtils {
  /// Calculates the distance between two geographical coordinates using the Haversine formula.
  ///
  /// [lat1], [lon1]: Coordinates of the first location in decimal degrees.
  /// [lat2], [lon2]: Coordinates of the second location in decimal degrees.
  /// [unit]: The unit of distance to return ('m' for meters, 'km' for kilometers, 'mi' for miles).
  ///
  /// Returns the distance between the two points in the specified unit (default is meters).
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    String unit = 'm', // Default unit: meters
  }) {
    // Validate inputs
    _validateCoordinates(lat1, lon1);
    _validateCoordinates(lat2, lon2);

    const double earthRadiusMeters = 6371e3; // Earth's radius in meters
    const double earthRadiusKilometers = 6371; // Earth's radius in kilometers
    const double earthRadiusMiles = 3958.8; // Earth's radius in miles

    // Convert degrees to radians
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Choose the appropriate Earth radius based on the desired unit
    double radius = earthRadiusMeters; // Default is meters
    if (unit == 'km') {
      radius = earthRadiusKilometers;
    } else if (unit == 'mi') {
      radius = earthRadiusMiles;
    } else if (unit != 'm') {
      throw ArgumentError('Invalid unit: $unit. Supported units are "m", "km", or "mi".');
    }

    return radius * c; // Distance in the specified unit
  }

  /// Validates latitude and longitude values.
  static void _validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Invalid latitude: $latitude. It must be between -90 and 90.');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Invalid longitude: $longitude. It must be between -180 and 180.');
    }
  }
}
