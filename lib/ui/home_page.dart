import 'dart:convert';
import 'package:share/share.dart';
import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variável de busca
  String _search;

  var _offset = 0;

  Future<Map> _getGifs() async {
    if(_search != null){
      var response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=rMx7HEIq2brS3hb8XvwTwZWZs5TRaBlx&q=$_search&limit=19&offset=$_offset&rating=g&lang=en');
      return json.decode(response.body);
    }else{
      var response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=rMx7HEIq2brS3hb8XvwTwZWZs5TRaBlx&limit=19&rating=g&offset=$_offset');
      return json.decode(response.body);
    }   
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
  
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  //Icon de carregar mais. +
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
      ),
      backgroundColor: Colors.black,
      
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 25.0),
              textAlign: TextAlign.left,
              onSubmitted: (text) {
                setState(() {
                   _search = text; 
                  _offset = 0;
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    //Cria um loading
                    return Center(
                      child: Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                        ),
                      ),
                    );
                  default: 
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      )
    );
  }
}