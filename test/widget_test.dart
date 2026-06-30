import 'package:flutter_test/flutter_test.dart';

import 'package:qrcode_scanner/core/qr_builders.dart';
import 'package:qrcode_scanner/core/qr_kind.dart';
import 'package:qrcode_scanner/core/upi.dart';

void main() {
  group('QR payload builders', () {
    test('UPI builds a valid deep link', () {
      final upi = QrBuilders.upi(
          vpa: 'alice@bank', name: 'Alice', amount: '100', note: 'lunch');
      expect(upi, startsWith('upi://pay?'));
      expect(upi, contains('pa=alice%40bank'));
      expect(upi, contains('am=100'));
      expect(upi, contains('cu=INR'));
    });

    test('Wi-Fi escapes special characters', () {
      final wifi = QrBuilders.wifi(ssid: 'My;Net', password: 'p@ss');
      expect(wifi, startsWith('WIFI:T:WPA;'));
      expect(wifi, contains(r'S:My\;Net;'));
    });

    test('vCard contains required fields', () {
      final v = QrBuilders.vcard(name: 'Bob', phone: '123', email: 'b@x.com');
      expect(v, contains('BEGIN:VCARD'));
      expect(v, contains('FN:Bob'));
      expect(v, contains('TEL;TYPE=CELL:123'));
      expect(v, contains('END:VCARD'));
    });
  });

  group('UPI VPA format', () {
    test('rejects a bare phone number', () {
      expect(Upi.isValidVpa('9876543210'), isFalse);
    });

    test('accepts handle@psp', () {
      expect(Upi.isValidVpa('9876543210@ybl'), isTrue);
      expect(Upi.isValidVpa('alice.b@okhdfcbank'), isTrue);
    });

    test('accepts psp handles ending in digits (e.g. kotak811)', () {
      expect(Upi.isValidVpa('john@kotak811'), isTrue);
      expect(Upi.isValidVpa('9876543210@axl'), isTrue);
    });

    test('rejects malformed ids', () {
      expect(Upi.isValidVpa('alice@'), isFalse);
      expect(Upi.isValidVpa('@bank'), isFalse);
      expect(Upi.isValidVpa('a@b@c'), isFalse);
    });
  });

  group('WhatsApp', () {
    test('builds wa.me link with country code, no plus/zeros', () {
      final w = QrBuilders.whatsapp(
          countryCode: '+91', phone: '098765 43210', message: 'hi there');
      expect(w, startsWith('https://wa.me/919876543210'));
      expect(w, contains('text=hi%20there'));
    });

    test('detects and captions a wa.me link', () {
      expect(detectKind('https://wa.me/919876543210'), QrKind.whatsapp);
      expect(qrCaption(QrKind.whatsapp, 'https://wa.me/919876543210'),
          '+919876543210');
    });
  });

  group('Captions', () {
    test('url strips scheme and www', () {
      expect(qrCaption(QrKind.url, 'https://www.example.com/'), 'example.com');
    });
    test('wifi shows ssid', () {
      expect(qrCaption(QrKind.wifi, 'WIFI:T:WPA;S:HomeNet;P:pw;;'), 'HomeNet');
    });
  });

  group('Kind detection', () {
    test('detects common schemes', () {
      expect(detectKind('https://example.com'), QrKind.url);
      expect(detectKind('upi://pay?pa=a@b'), QrKind.upi);
      expect(detectKind('WIFI:T:WPA;S:net;P:pw;;'), QrKind.wifi);
      expect(detectKind('tel:+10000'), QrKind.phone);
      expect(detectKind('BEGIN:VCARD'), QrKind.contact);
      expect(detectKind('hello world'), QrKind.text);
      expect(detectKind('example.com'), QrKind.url);
    });
  });
}
