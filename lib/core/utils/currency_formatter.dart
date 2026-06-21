class CurrencyFormatter {
  const CurrencyFormatter._();

  static String rupiah(num price) {
    final raw = price.round().toString();
    final buffer = StringBuffer();
    var count = 0;

    for (var i = raw.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(raw[i]);
      count++;
    }

    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }
}
