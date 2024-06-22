import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _credentialsJson = '''{
   "type": "service_account",
  "project_id": "chuttu-29802",
  "private_key_id": "2e3a307f92a238a6b94b0f503f8616da2cb6d866",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC8Ulj1QEPl6Qfe\\n9RG8uw66CQCTap7myDa7PgvvzWIANWP53jFFZcdYw78fh1f/RqPcQCBrMpIBH/DT\\nBqj6xprUhoD3VBNnXEraupD7AX5ZEvvKe4dlpXe/c9UkxqxI8EnrklgIAi/RGt21\\nrtXLbLP033f6569jemcuG6DFZow5I38NISpOyAuxwLpbJjXKAJWkI35zG4SB+rUZ\\nyZ1ZhDv7Pp1PVk65soM582dkbVLDVgOcAEHEMLOhHS8X9cn6/ENs7Fs9W5X0MHyh\\neN5iVSNHdm8bNyCrybqIZsncWDPuxJcwagz+AD1okrSuvpw2Jtt0nWKoZPobsYCz\\nj2hztwKVAgMBAAECggEAKZT6OP7tbxrPBtswhS59gDTkKGjCuN0M/reizZqZMMgZ\\nMO8vjG3+gBpKvXS2SLLJlCShs+HI7NAnbgUaszK+tb4URGhPV4OAsL7Aq/fGtPbU\\n237+pMJOSFsUfWgT2xAZllcsMmp/Men/efImmWIBc0iTlrZpGutIVJ07mNK9lBDh\\nZTmBcsy/O+DbZCjj5aGRjXpynYduoIhQjydRYVyQh0Oscw8No41e/LQUFD8bpeXz\\nDc+GAuYkckpxZ0U6p8za1ANT4UAR2+RQAzjDUJ5+/Pb+23NhPUWgyr3mie8NxJST\\nWHFaCVxOfFo6kWZ9WoXqSoUDbGPmLPAixyEEXbfkOQKBgQD5qf2SQn+CI/YMg4IA\\n4MtHiDxiCCWh/ix+bYkOQZ1/Gc5WiiN2y9ufrgRe7k2TmY8177A8K0ORGuW6B7ZN\\nPle/RFNTCt6bm3WFoz03QFOjXp4Y2nsKGXFrBNb/JSe4FABFXufUy6PEvjGIBl27\\nDpy8YBa6n3IDwSZG3tSWXGc1GQKBgQDBGdRyRuqO9w4dxIfDYSchqO4McF+AO+Jl\\nr9dXi5m7QG0TNep2VefczzumznpKWI3MxUuNu/yjo0V6cA4PcBSyNdGmKpcR65wu\\nE9C/EPSI5tC5YnHjrCCXlHY+5zovBVIRpPxzUNmKIwpsnwTaAdKBwImlq6aPCr1C\\nu8+31EkM3QKBgQDB195tZPwjS1CKvsB9dgve6kQXyUOO1w4sy1cSnpduS9cNEgwe\\n/ID1JeN24YeSBjRPKF6pGN5JF50uJzbAGpt+gcpAO7xDDRzeObQZ5fQKcDhIC7pk\\nSQTqlsNnLq38GmtrcRiG++WXqCRE/MxhpCLFj8WV+J5Jk/noJLLiW7Q2YQKBgEMm\\nPlB3BL4uf4QugZ+Zu0fjPNSqhytKp9IAsfvJme4Z21Rg3WXFPdn1XqMFDlWoMbdR\\nrJJfGt20u0Z2jQ0lRq0qNft4uAwNSMRlM6Qdu0uYKGEvMLehdbwAbpY1RnBvgziL\\njRZ0uRFmWgunyMIe/BsO307zP/piG6qHMRaWBckpAoGBAJ3iKHmrE7TpE74FbUY+\\n7RiWlRsV4BQyRg2qToqThlz6tzfIbbL+k3ZyF2eeO5una2JF4GGTEPCYaaLTc50i\\n3hHpmMTvmhO7KVn7LSkIfHLPJBP2mlBZZRbsc9LFOG4DR0mgEuXW5wQ53/uRuyPm\\nmo4zvzejXBN+BssMZUOa0KUL\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-wr491@chuttu-29802.iam.gserviceaccount.com",
  "client_id": "102380859645381226776",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-wr491%40chuttu-29802.iam.gserviceaccount.com"
   }''';

  Future<String> getAccessToken() async {
    var accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(_credentialsJson));
    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    var client = http.Client();
    var accessToken;

    try {
      var authClient = await clientViaServiceAccount(accountCredentials, scopes);
      accessToken = authClient.credentials.accessToken.data;
      authClient.close();
    } finally {
      client.close();
    }

    return accessToken;
  }
}
