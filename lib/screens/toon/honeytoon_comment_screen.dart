import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../providers/comment_provider.dart';
import '../../helpers/dateFormatHelper.dart';
import 'package:provider/provider.dart';

class HoneytoonCommentScreen extends StatefulWidget {
  static const routeName = '/comment';

  @override
  _HoneytoonCommentScreenState createState() => _HoneytoonCommentScreenState();
}

class _HoneytoonCommentScreenState extends State<HoneytoonCommentScreen> {
  CommentProvider _commentProvider;
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String id, String text) async {
    try {
      print('id=$id');
      final user = await FirebaseAuth.instance.currentUser();
      Comment comment = Comment(toonId: id, uid: user.uid, comment: text, createTime: Timestamp.now());
      print(comment);
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
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);
    _commentProvider = Provider.of<CommentProvider>(context, listen: false);

    return Scaffold(
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
          _handleSubmitted(id, value);
        },
        decoration: InputDecoration(
          hintText: '댓글을 입력해주세요', 
          suffixIcon: Icon(Icons.add)
        ),
      ),
    );
  }

  Widget _buildComments(id, height){
    return Container(
      height: height * 0.75,
      child: FutureBuilder(
        future: _commentProvider.getComments(id),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          } else if(snapshot.hasData){
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (ctx, index) => ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(snapshot.data[index].thumbnail),
                ),
                title: Container(
                  child: Row(
                    children: <Widget>[
                      Text('유저혀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(width: 25,),
                      Text('${DateFormatHelper.getDateTime(snapshot.data[index].createTime)}', style: TextStyle(color: Colors.grey))
                  ],)
                ),
                subtitle: Text('${snapshot.data[index].comment}', style: TextStyle(color: Colors.grey, fontSize: 16),),
              ),
              
            );
          } else {
            return null;
          }
        }
      ),
    );
  }
}