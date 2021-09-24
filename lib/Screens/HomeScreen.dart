import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather/models/tempmodel.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int temprture=0;
  int woeid=0;
  String city="City";
  String weather="clear";
  String abbr="c";
  Future<void> fatchcity(String input) async {
    var url=Uri.parse("https://www.metaweather.com/api/location/search/?query=$input");
    var response= await http.get(url);
    var responsebody=jsonDecode(response.body)["consolidated_weather"][0];
    setState(() {
      woeid=responsebody["woeid"];
      weather=responsebody["weather_state_name"];
    });
  }
  Future<List<tempmodel>> fatchtemp() async {
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid");
    var response= await http.get(url);
    var responsebody=jsonDecode(response.body)["consolidated_weather"];
    setState(() {
      temprture=responsebody[0]["the_temp"].round();
      print(temprture);
      weather=responsebody[0]["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbr= responsebody[0]["weather_state_abbr"];
    });
    List<tempmodel>list=[];
    for(var i in responsebody){
      tempmodel temp=tempmodel(applicable_date: i["applicable_date"],weather_state_abbr: i["weather_state_abbr"],max_temp: i["max_temp"],min_temp: i["min_temp"]);
      list.add(temp);
    }
    return list;
  }
   Future<void> onTextFieldSumbit(String input) async {
    await fatchcity(input);
    await fatchtemp();
   }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/$weather.png",),fit: BoxFit.cover
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(child: Image.network("https://www.metaweather.com/static/img/weather/png/$abbr.png",width: 100,)),
                Center(child: Text("$temprture°C",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60.0
                  ),)),
                Center(child: Text("$city",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0
                  ),)),

              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onSubmitted: (String input){
                      print("$input");
                      onTextFieldSumbit(input);
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      hintText: "Seacrh by City...",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,

                      ),
                      prefixIcon: Icon(Icons.search,color: Colors.white,size: 25,),

                    ),
                  ),
                ),
                Container(
                  height: 200,
                  padding: EdgeInsets.symmetric(horizontal: 5,vertical: 20),
                  child: FutureBuilder(
                    future: fatchtemp(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if(snapshot.data==null){
                        return Text(" ");
                      }
                      else if(snapshot.hasData){
                        return ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context , int index) {
                              return Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  height: 170,
                                  width: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("Date:${snapshot.data[index].applicable_date}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                      Image.network("https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",width: 45,),
                                      Text("Min:${snapshot.data[index].min_temp.round()}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                      Text("Max:${snapshot.data[index].max_temp.round()}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              );
                            },);
                      }
                      else{
                        return Text(" ");
                      }
                    },),
                )
              ],
            ),
          ],
        ),
      ),

    );
  }
}
