import 'dart:ui';

Offset? calculatePosition(
    double userHeading,
    double userTilt,
    double celestialAzimuth,
    double celestialAltitude,
    double screenWidth,
    double screenHeight,
    {double horizontalFOV = 45.0,
    double verticalFOV = 60.0}) {
  // If the celestial object is below the horizon, it’s not visible
  if (celestialAltitude < 0) return null;
  // Calculate the azimuth difference (normalized to -180 to 180 range)
  double azimuthDiff = (celestialAzimuth - userHeading + 360) % 360;
  if (azimuthDiff > 180) azimuthDiff -= 360;

  // If the azimuth difference is outside the horizontal FOV, object is off-screen
  if (azimuthDiff.abs() > horizontalFOV) return null;

  // Map azimuth difference to horizontal screen position (x-axis)
  double horizontalPosition =
      (screenWidth / 2) + (azimuthDiff / horizontalFOV) * (screenWidth / 2);

  // Calculate vertical position based on altitude and tilt
  // Map celestial altitude (-90 to 90) and tilt (-10 to 10) to the screen vertical FOV
  double adjustedAltitude = celestialAltitude + (userTilt * 9);

  // Check if the adjusted altitude is within the visible vertical field of view
  if (adjustedAltitude.abs() > verticalFOV) return null;

  // Map vertical difference to the vertical screen position
  double verticalPosition = (screenHeight / 2) -
      (adjustedAltitude / verticalFOV) * (screenHeight / 2);

  // Return the calculated screen position as an Offset
  return Offset(horizontalPosition, verticalPosition);
}
