import 'package:bestwallpapers/full_screen.dart';
import 'package:bestwallpapers/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CuratedPage extends StatefulWidget {
  const CuratedPage({Key? key}) : super(key: key);

  @override
  _CuratedPageState createState() => _CuratedPageState();
}

class _CuratedPageState extends State<CuratedPage> {

  Api api = Api();
  List images = [];
  final _searchKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  String? _searchText;
  late FocusNode myFocusNode;
  bool isLoading = false;
  bool isCurated = true;
  int page = 1;


  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    _getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
        /*
          IconButton(
            onPressed: (){
              showBarModalBottomSheet(
                  context: context,
                  builder: (context){
                    return Expanded(
                      child: Column(

                      ),
                    )
                  }
              );
            },
            icon: Icon(Icons.filter),
          ),
         */
          TextButton(
            onPressed: (){
              if( _searchController.text.isEmpty){
                _searchKey.currentState!.save();
                _getImages();
              }else{
                _searchKey.currentState!.save();
                _search();
              }
            },
            child: Text("Search", style: TextStyle(color: Colors.white),),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _searchKey,
            child: TextFormField(
              controller: _searchController,
              autofocus: false,
              focusNode: myFocusNode,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 0.1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 0.1),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 0.1),
                ),
                hintStyle: TextStyle(color: Colors.white),
                  hintText: "Search..."
              ),
              onSaved: (v){
                _searchController.text = v!;
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          images.isEmpty ?
          Center(
            child: Text("There is not found any image"),
          ) :
          Column(
            children: [
              Expanded(
                child: Container(
                  child: GridView.builder(
                      itemCount: images.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 2,
                          crossAxisCount: 2,
                          childAspectRatio: 2 / 3,
                          mainAxisSpacing: 2),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            myFocusNode.unfocus();
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                FullScreen(
                                  imageurl: images[index]['src']['large2x'],
                                  originalUrl: images[index]['src']['original'],
                                  ultraUrl:  images[index]['src']['large2x'],
                                  largeUrl:  images[index]['src']['large'],
                                  mediumUrl:  images[index]['src']['medium'],
                                  smallUrl:  images[index]['src']['small'],
                                )));
                          },
                          child: Container(
                            color: Colors.white,
                            child: Image.network(
                              images[index]['src']['medium'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                ),
              ),
              InkWell(
                onTap: () {
                  _loadMore();
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Text('Load More',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
          Opacity(
            opacity: isLoading ? 0.4 : 0,
              child: isLoading ? _loading() : null
          ) ,


        ],
      ),
    );
  }
  /*
  StaggeredGridView.countBuilder(

        crossAxisCount: 4,
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return Image.network(images[index]["src"]["large"]);
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(2, index.isEven ? 2 : 1);
        },
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
   */

  Future<void> _getImages() async{
    setState(() {
      isLoading = true;
    });
    images = await api.fetchCurated();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _search() async{
    setState(() {
      isLoading = true;
    });
    images = await api.search(_searchController.text,);
    setState(() {
      isLoading = false;
    });
  }
  _loadMore() async {
    setState(() {
      isLoading = true;
      page += 1;
    });
     if(_searchController.text.isEmpty){
       List _result = await api.loadMoreCurated(page);
       images.addAll(_result);
     }else{
       List _result = await api.loadMoreSearch(_searchController.text, page);
       images.addAll(_result);
     }
     setState(() {
       isLoading = false;
     });
  }

  Widget _loading(){
    return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(color: Colors.black,),
          ),


    );
  }

}
