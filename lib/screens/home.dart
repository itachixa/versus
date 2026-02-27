import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:versus/constants/color.dart';

class Home  extends StatelessWidget{
  const Home({Key? key}) : super(key : key);


  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: const Color.fromARGB(164, 4, 49, 194),
    appBar: _buildAppBar(),
    body: Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child:Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 90, 87, 87),
              borderRadius: BorderRadius.circular(20)
            ),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: tdBlack,
                  size:20,
                ),
                prefixIconConstraints: BoxConstraints(
                  maxHeight: 20,
                  minWidth: 25
                ),
                border: InputBorder.none,
                hintText: 'Search',

              ),
            ),
          )
        ],
      ),
    ),
   );
}

  AppBar _buildAppBar() {
    return AppBar( 
    backgroundColor: tdBGcolor ,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.menu,
          color: tdBlack,
          size: 30,
        ),
        Container(
          height: 40,
          width: 40,
          child: ClipRect(
            child: Image.asset('assets/images/versus.jpeg'),
          ),
        )
      ],
    ),
  );
  }
  }