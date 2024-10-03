class DomainHelper {
  /// Extracts the base domain from a URL or domain string
  ///
  /// Examples:
  /// - "www.example.com" -> "example.com"
  /// - "https://www.example.com" -> "example.com"
  /// - "sub.example.com" -> "example.com"
  /// - "example.com" -> "example.com"
  /// - "example.co.uk" -> "example.co.uk"
  static String extractBaseDomain(String input) {
    // Remove any protocol (http:// or https://)
    final withoutProtocol = input.replaceAll(RegExp(r'https?://'), '');

    // Remove any path, query parameters, or fragments
    final domainOnly = withoutProtocol;//.split('/')[0];

    // Split the domain into parts
    final parts = domainOnly.split('.');

    // Handle special cases for country-specific TLDs (e.g., co.uk, com.au)
    if (parts.length > 2) {
      // Check for country-specific TLDs
      final lastTwo = parts.sublist(parts.length - 2).join('.');
      if (_isCountrySpecificTLD(lastTwo)) {
        // If we have enough parts (e.g., www.example.co.uk), return example.co.uk
        if (parts.length > 3) {
          return parts.sublist(parts.length - 3).join('.');
        }
        // Otherwise return as is (already in correct format)
        return domainOnly;
      }

      // For regular domains, remove www and any other subdomains
      if (parts.length > 2) {
        return parts.sublist(parts.length - 2).join('.');
      }
    }

    return domainOnly;
  }

  /// Checks if the given TLD is a country-specific one
  static bool _isCountrySpecificTLD(String tld) {
    // Add more country TLDs as needed
    final countryTLDs = [
      'co.uk',
      'co.jp',
      'com.au',
      'co.nz',
      'com.br',
      'com.mx',
      'co.in',
      'co.za',
      // Add more as needed
    ];

    return countryTLDs.contains(tld.toLowerCase());
  }

  /// Validates if a string is a valid domain
  static bool isValidDomain(String domain) {
    final RegExp domainRegex = RegExp(
        r'^(?!-)[A-Za-z0-9-]{1,63}(?<!-)(\.[A-Za-z0-9-]{1,63})*\.[A-Za-z]{2,}$'
    );
    return domainRegex.hasMatch(domain);
  }
}
