enum MarkerQuality {
  low(1.0),
  medium(2.0),
  high(3.0),
  ultra(4.0);

  final double pixelRatio;
  const MarkerQuality(this.pixelRatio);
}
