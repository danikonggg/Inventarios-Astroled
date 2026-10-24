import 'package:astroled_ofc/custom_code/barcode_quantity.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('Reads positive quantity without stripping the barcode', () {
    expect(quantityFromBarcode('PS-24100-D*100'), 100);
    expect(quantityFromBarcode('PS-24100-D*25'), 25);
    expect(quantityFromBarcode('PS-24100-D*001'), 1);
    expect(quantityFromBarcode('PS-24100-D'), isNull);
    expect(quantityFromBarcode('PS-24100-D*'), isNull);
    expect(quantityFromBarcode('PS-24100-D*0'), isNull);
    expect(quantityFromBarcode('PS-24100-D*-2'), isNull);
    expect(quantityFromBarcode('PS-24100-D*ABC'), isNull);
  });
}