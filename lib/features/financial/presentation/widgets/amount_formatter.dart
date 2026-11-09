import 'package:intl/intl.dart';

class AmountFormatter {
  static final _nf = NumberFormat('#,###', 'en_US');

  /// backend amounts are in IRR. Show Toman by dividing by 10.
  static String toToman(num rial) {
    final toman = (rial / 10).round();
    return '${_nf.format(toman)} تومان';
  }

  static String toTomanNaked(num rial) {
    final toman = (rial / 10).round();
    return _nf.format(toman);
  }
}
