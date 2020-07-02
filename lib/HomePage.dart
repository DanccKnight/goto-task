import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:goto_task/Models/Photo.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:shake/shake.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ShakeDetector detector;
  PageController controller;
  GlobalKey<PageContainerState> key = GlobalKey();
  Future<List<Photo>> images;
  String url =
      'https://api.unsplash.com/photos/random?query=Nature&orientation=portrait&client_id=${DotEnv().env['API_KEY']}&count=10';

  @override
  void initState() {
    images = fetchImages();
    controller = PageController();
    detector = ShakeDetector.autoStart(onPhoneShake: () {
      setState((){
        images = fetchImages();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    detector.stopListening();
    super.dispose();
  }

  Future<List<Photo>> fetchImages() async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<Photo> pictures = (json.decode(response.body) as List)
          .map((i) => Photo.fromJson(i))
          .toList();
      print("got the cargo");
      return pictures;
    } else {
      throw Exception("Failed to fetch images");
    }
  }

  downloadImage(String url,String guidelineUrl) async {
    try{
      var imageId = await ImageDownloader.downloadImage(url);
      //Adhering to the usage guidelines cause I'm a nice guy
      await http.get(guidelineUrl + "?client_id=${DotEnv().env['API_KEY']}");
    } on PlatformException catch (error){
      print(error);
    }
  }

  showSuccessMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Image downloaded successfully!"),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: PageIndicatorContainer(
            key: key,
            length: 10,
            align: IndicatorAlign.bottom,
            padding: const EdgeInsets.only(bottom: 30),
            shape: IndicatorShape.circle(size: 6),
            indicatorSpace: 10,
            indicatorColor: Colors.grey,
            indicatorSelectorColor: Colors.white,
            child: PageView(
              children: [
                displayImage(0),
                displayImage(1),
                displayImage(2),
                displayImage(3),
                displayImage(4),
                displayImage(5),
                displayImage(6),
                displayImage(7),
                displayImage(8),
                displayImage(9),
              ],
              controller: controller,
            ),
          )),
    );
  }

  Widget displayImage(index) {
    return FutureBuilder(
      future: images,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Text("Fetching the images..."));
        } else if(snapshot.connectionState == ConnectionState.done){
          return Stack(
            children: [
              GestureDetector(
                onDoubleTap: () async {
                  await downloadImage(snapshot.data[index].url.regular, snapshot.data[index].downloadLink.downloadLocation);
                  showSuccessMessage();
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Image.network(snapshot.data[index].url.regular,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes == null
                                  ? null
                                  : loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes,
                            ));
                      }),
                ),
              ),
              displayCredit(index, snapshot)
            ],
          );
        } else {
          return Center(child: Text("Fetching the images..."));
        }
      },
    );
  }

  Widget displayCredit(index, imagesSnapshot) {
    return Align(
      alignment: Alignment(-0.69, 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: MediaQuery.of(context).size.width / 4,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text("Photo by",
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(color: Colors.white, fontSize: 13)),
              ),
            ),
            SizedBox(height: 3),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width / 2,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(imagesSnapshot.data[index].user.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}