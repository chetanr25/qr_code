/// UPI helper — format validation only.
///
/// Note: there is no free way to verify a UPI ID actually exists (NPCI
/// verify-VPA APIs require a licensed payment aggregator). We only check the
/// shape of the address, never its existence.
class Upi {
  /// VPA format: handle@psp — handle 2-256 of word/.-_ chars, psp 2-64 letters.
  static final _vpaRe = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

  static bool isValidVpa(String vpa) => _vpaRe.hasMatch(vpa.trim());
}
