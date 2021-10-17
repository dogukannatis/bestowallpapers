import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {

  final String baseUrl = "https://api.pexels.com/v1";
  final String apiKey = "563492ad6f917000010000019536815b28c14be7a7a6d7c35d0077ba";


  Future<List> search(String searchText, {int? page}) async{
    List images = [];
    await http.get(
        Uri.parse(
            page == null ? baseUrl+"/search?query=$searchText&per_page=40"
                : baseUrl+"/search?query=$searchText&per_page=40&page=${page.toString()}"
        ),
        headers: {
          "Authorization" : apiKey
        }
    ).then((value) {
      Map result = jsonDecode(value.body);

      images = result["photos"];
      print(images.toString());
    });

    return images;
  }

  Future<List> fetchCurated({int? page}) async{
    List images = [];
    await http.get(
        Uri.parse(
            page == null ? baseUrl+"/curated?per_page=40"
                : baseUrl+"/curated?per_page=40&page=${page.toString()}"
        ),
      headers: {
          "Authorization" : apiKey
      }
    ).then((value) {
      Map result = jsonDecode(value.body);

      images = result["photos"];
      print(images.toString());
    });

    return images;
  }

  Future<List> loadMoreCurated(int page) async{
    List images = [];
    images = await this.fetchCurated(page: page);
    return images;
  }
  Future<List> loadMoreSearch(String searchText, int page) async{
    List images = [];
    images = await this.search(searchText,page: page);
    return images;
  }


}