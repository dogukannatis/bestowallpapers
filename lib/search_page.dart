import 'package:bestwallpapers/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchKey = GlobalKey<FormState>();
  Api api = Api();


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _searchKey,
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: "Search..."
              ),
              validator: (v){
                if( v == null || v.isEmpty ){
                  return "Please enter something";
                }
              },
              onSaved: (v){

              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){
              if(_searchKey.currentState!.validate()){
                _searchKey.currentState!.save();
              }
            },
            child: Text("Search", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}
