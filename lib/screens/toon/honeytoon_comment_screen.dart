import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart';
import '../../providers/auth_provider.dart';
import '../../models/comment.dart';
import '../../providers/comment_provider.dart';
import '../../helpers/dateFormatHelper.dart';


class HoneytoonCommentScreen extends StatefulWidget {
  static const routeName = '/comment';

  @override
  _HoneytoonCommentScreenState createState() => _HoneytoonCommentScreenState();
}

class _HoneytoonCommentScreenState extends State<HoneytoonCommentScreen> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  String userId;
  CommentProvider _commentProvider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();
  List<dynamic> _commentList = [];

  void _handleSubmitted(String id) async {
    try {
      final text = _textController.text;
      final user = FirebaseAuth.instance.currentUser;
      Comment comment = Comment(toonId: id, uid: user.uid, comment: text, createTime: Timestamp.now());
      _commentProvider.setComment(comment);
      _textController.clear();
    } catch(error){
      print(error.message);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this._memoizer.runOnce(() async {
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      setState(() {
        userId = uid;
      });
    });
  }

  Future<void> _showDialog(BuildContext context, data) async {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('댓글을 삭제하실건가요?'),
              ],
            )
          ),
          actions: <Widget>[ 
            FlatButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(ctx).pop();
                _deleteComment(ctx, data);
              },
            ),
            FlatButton(
              child: Text('취소'),
              onPressed: (){
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      }  
    );
  }

  void _deleteComment(BuildContext ctx, data) async {
    try {
      await _commentProvider.deleteComment(data);
      _showSnackbar(ctx, '댓글을 삭제하였습니다');
    } catch(error){
      print(error);
      _showSnackbar(ctx, '댓글 삭제에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);
    _commentProvider = Provider.of<CommentProvider>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('댓글'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildForm(args['id'], height),
              _buildComments(args['id'], height)

            ]
          ),
        )
      
      )
    );
  }

  Widget _buildForm(id, height){
    return Container(
      height: height * 0.1,
      child: TextField(
        controller: _textController,
        onSubmitted: (String value){
          _handleSubmitted(id);
        },
        decoration: InputDecoration(
          hintText: '댓글을 입력해주세요', 
          suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: (){ _handleSubmitted(id);}
          ),
        )
      ),
    );
  }

  Widget _buildComments(id, height){
    return Container(
      height: height * 0.75,
      child: StreamBuilder(
        stream: _commentProvider.commentStream(id),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          } else if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              _commentList = snapshot.data.documents
                .map((item) => Comment.fromMap(id, item.id, item.data()))
                .toList();
            }
            return FutureBuilder(
              future: _commentProvider.getCommentsWithUser(_commentList),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                } else if(snapshot.hasData){
                  return _buildCommentList(snapshot);
                } else {
                  return Container();
                }   
             }
           );
        } else {
          return Container();
        }
      }
      )
    );
    }

  Widget _buildCommentList(snapshot){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: snapshot.data.length,
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (ctx, index) => 
        ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 6), 
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
              width: 50,
              height: 50,
              imageUrl: snapshot.data[index].thumbnail,
              placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png',),
              errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png'),
              fit: BoxFit.fill,
            ), 
        ),
        title: Container(
          child: Row(
            children: <Widget>[
              Text('${snapshot.data[index].username}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 10,),
              Text('${DateFormatHelper.getDateTime(snapshot.data[index].createTime)}', style: TextStyle(color: Colors.grey, fontSize: 12))
          ],)
        ),
        subtitle: Text('${snapshot.data[index].comment}', style: TextStyle(color: Colors.grey, fontSize: 14),),
        trailing: (userId == snapshot.data[index].uid) ?  
          IconButton(icon: Icon(
            Icons.delete, color: Colors.black54,
          ),
          onPressed: () {
            _showDialog(context, snapshot.data[index]);
          }
        ): null,
      ),
    );  
  }
  
  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }
}