class MediaQueryHelper {
  static bool isSmall(double width) {
    return width < 450;
  }

  static bool isMedium(double width) {
    return width > 450 && width < 800;
  }

  static bool isMediumOrLarger(double width) {
    return width > 450;
  }

  static bool isLarge(double width) {
    return width > 800;
  }
}
