
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/io_client.dart';

class WebUtils
{
   static Future<dom.Document> getDomFromURL_Get (String url,{Map<String,String>? headers,Function(int)? onStatusCode,Function(String?)? onCookie}) async
   {
     http.Response response = await http.Client().get(Uri.parse(url),headers: headers);
     if(onStatusCode!=null)
       {
         onStatusCode(response.statusCode);
       }
     if(onCookie != null)
       {
         onCookie(response.headers["set-cookie"]);
       }
     return parser.parse(response.body);
   }

   static Future<dom.Document> getDomFromURL_Post (String url,Object body,{Map<String,String>? headers}) async
   {
     http.Response response = await http.Client().post(Uri.parse(url),body: body,headers: headers);
     return parser.parse(response.body);
   }

   static Future<String?> makeGetRequest(String url,
       {Map<String, String>? headers,Function(String?)? requestCookieCallBack,Duration? timeout}) async
   {
     late http.Response response;
     if(timeout != null)
       {
         response = await http.Client().get(Uri.parse(url),headers: headers).timeout(timeout!);
       }
     else
       {
         response = await http.Client().get(Uri.parse(url),headers: headers);
       }

     if(requestCookieCallBack != null)
     {
       requestCookieCallBack(response.headers["location"]);
     }
     return response.body!;
   }

   static Future<Uint8List> makeGetRequestWithBodyBytes(String url,
       {Map<String, String>? headers}) async
   {
     http.Response response = await http.Client().get(Uri.parse(url),headers: headers);

     return response.bodyBytes!;
   }


   static Future<String> makePostRequest (String url,Object body, {Map<String,String>? headers,Function(String?)? requestCookieCallBack,Duration? timeout}) async
   {
     late http.Response response;
     if(timeout != null)
     {
       response = await http.Client().post(Uri.parse(url),body: body,headers: headers).timeout(timeout!);
     }
     else
     {
       response = await http.Client().post(Uri.parse(url),body: body,headers: headers);
     }
     if(requestCookieCallBack != null)
       {
         requestCookieCallBack(response.headers["set-cookie"]);
       }
     return response.body;
   }

   static Future<String> requestWithBadCertificate (String url) async
   {
     final ioc = new HttpClient();
     ioc.badCertificateCallback =
         (X509Certificate cert, String host, int port) => true;
     final http = new IOClient(ioc);
    var response =  await http.get(Uri.parse(url));
    return response.body;
   }

   static dom.Document getDomfromHtml (String html)
   {
     return parser.parse(html);
   }

   static Future<String?> getOriginalUrl(url,{Map<String,String> headers = const {},Duration? timeout}) async {
     try { 
       final client = HttpClient();
       client.connectionTimeout = timeout;
       var uri = Uri.parse(url);
       var request = await client.getUrl(uri);
       for (MapEntry<String,String> mapEntry in headers.entries)
         {
           request.headers.add(mapEntry.key, mapEntry.value);
         }
       request.followRedirects = false;
       var response = await request.close();
       if(response.isRedirect)
         {
           await response.drain();
           return response.headers.value(HttpHeaders.locationHeader);
         }
       else
         {
           return url;
         }
     } catch (e) {
       print(e);
     }
     return "";
     /*while () {
       response.drain();
       final location = response.headers.value(HttpHeaders.locationHeader);

       if (location != null) {
         uri = uri.resolve(location);
         request = await client.getUrl(uri);
         // Set the body or headers as desired.

         if (location.toString().contains('https://www.xxxxx.com')) {
           return location.toString();
         }
         request.followRedirects = false;
         response = await request.close();
       }
     }*/
   }

}