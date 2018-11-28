import 'dart:async';
import 'package:meta/meta.dart';
import 'package:http_client/console.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'client.dart';
import 'bucket.dart';

class Spaces extends Client {
  Spaces(
      {@required String region,
      @required String accessKey,
      @required String secretKey,
      String endpointUrl,
      http.Client httpClient})
      : super(
            region: region,
            accessKey: accessKey,
            secretKey: secretKey,
            service: "s3",
            endpointUrl: endpointUrl,
            httpClient: httpClient) {
    // ...
  }

  Bucket bucket(String bucket) {
    if (endpointUrl == "https://s3.${region}.amazonaws.com") {
      return new Bucket(
          region: region,
          accessKey: accessKey,
          secretKey: secretKey,
          endpointUrl: "https://${bucket}.s3.amazonaws.com",
          httpClient: httpClient);
    } else {
      throw Exception(
          "Endpoint URL not supported. Create Bucket client manually.");
    }
  }

  Future<List<String>> listAllBuckets() async {
    xml.XmlDocument doc = await getUri(Uri.parse(endpointUrl + '/'));
    List<String> res = new List<String>();
    for (xml.XmlElement root in doc.findElements('ListAllMyBucketsResult')) {
      for (xml.XmlElement buckets in root.findElements('Buckets')) {
        for (xml.XmlElement bucket in buckets.findElements('Bucket')) {
          for (xml.XmlElement name in bucket.findElements('Name')) {
            res.add(name.text);
          }
        }
      }
    }
    return res;
  }
}