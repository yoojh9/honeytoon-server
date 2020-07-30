import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/providers/honeytoon_content_provider.dart';
import 'package:honeytoon/providers/honeytoon_meta_provider.dart';
import '../screens/honeytoon_view_screen.dart';
import '../screens/my/add_content_screen.dart';
import 'package:provider/provider.dart';


class HoneytoonDetailScreen extends StatefulWidget {
  static final routeName = 'honeytoon-detail';

  @override
  _HoneytoonDetailScreenState createState() => _HoneytoonDetailScreenState();


}

class _HoneytoonDetailScreenState extends State<HoneytoonDetailScreen> {
  HoneytoonContentProvider _contentProvider;
  HoneytoonMetaProvider _metaProvider;
  AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _contentProvider = Provider.of<HoneytoonContentProvider>(context);
    _metaProvider = Provider.of<HoneytoonMetaProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (mediaQueryData.padding.top + mediaQueryData.padding.bottom);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){Navigator.of(context).pop();}),
        actions: <Widget>[
          FutureBuilder(
            future: _authProvider.getCurrentFirebaseUserUid(),
            builder: (ctx, snapshot){
              if(snapshot.hasData && snapshot.data == args['uid']){
                return IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    Navigator.of(ctx)
                    .pushNamed(AddContentScreen.routeName, arguments: {'id': args['id']});
                  });
              } else {
                return IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: (){},
                );
              }
            })
        ],
        
      ),
      body: SafeArea( 
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                child: Column(
                    children: [
                      _buildHoneytoonMetaInfo(args['id'], height),
                      _buildHoneytoonContentList(args['id'])
                    ]
                  )
                )
            )
      )
    );
  }

Widget _buildHoneytoonMetaInfo(id, height) {
  return  FutureBuilder(
    future: _metaProvider.getHoneytoonMeta(id),
    builder: (context, snapshot) {
      if(snapshot.hasData){
        return Container(
          height: height * 0.4,
          child: Column(children: <Widget>[
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 4/3,
                child: CachedNetworkImage(
                  imageUrl: snapshot.data.coverImgUrl,
                  placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover
                )
              )
            ),                      
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('${snapshot.data.title}', style: TextStyle(fontSize: 20),),
                  Text('${snapshot.data.displayName}'),
                ]
              ),
            ),
          ],)
        );
      } else {
        return Center(child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
      }
      }
    );
  }
  
  Widget _buildHoneytoonContentList(id, ){
  return FutureBuilder(
    future: _contentProvider.getHoneytoonContentList(id),
    builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if(snapshot.hasData) {
        return Container(
          child: GridView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, index) => ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: GridTile(
                child: GestureDetector(
                  onTap: (){ Navigator.of(context).pushNamed(HoneytoonViewScreen.routeName, 
                    arguments: {
                      'id': id, 
                      'images': snapshot.data[index].contentImgUrls,
                      'times': snapshot.data[index].times,
                    }); 
                  },
                  child: CachedNetworkImage(
                    imageUrl: snapshot.data[index].coverImgUrl,
                    placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover
                  )
                ),
                footer: GridTileBar(
                  backgroundColor: Colors.white70,
                  title: Text('${snapshot.data[index].times}화', textAlign: TextAlign.start, style: TextStyle(color: Colors.black),),
                ),
              ),
                
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5/2, 
              crossAxisSpacing: 5, 
              mainAxisSpacing: 5
            ),
          ),
        );
      } else {
        return Center(child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
      }
    },
  );
  }
}