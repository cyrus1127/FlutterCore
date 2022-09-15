import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app_devbase_v1/component/commonStatefulWidget.dart';
import 'package:app_devbase_v1/component/hex_color.dart';
import 'package:app_devbase_v1/component/responsiveStatefulWidget.dart';
import 'package:app_devbase_v1/pages/afterLogin/postCreate.dart';
import 'package:app_devbase_v1/pages/afterLogin/profileEditing.dart';
import 'package:app_devbase_v1/pages/afterLogin/subviews/zoomingPhotoView.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoAlbum extends CommonStatefulWidget {
  const PhotoAlbum({required Key? key}) : super(key: key);

  @override
  _PhotoAlbumState createState() => _PhotoAlbumState();
}

class _PhotoAlbumState extends State<PhotoAlbum> {
  final TextEditingController _controller = TextEditingController();

  double topBarOffSet =
      (Platform.isIOS ? (window.viewPadding.bottom > 0 ? 39 : 30) : 30);
  double topBarHeight = 45;
  double endAnimatedPosition = -40;
  double editingBlockHeight = 565;
  double datetimePickerHeight = 216;
  double quaityBarHeight = 45;

  double layoutMargin = globalDataStore.getResponsiveSize(15); //for builds bar

  bool showAsGallery = false;
  bool needShowPhotoView = false;
  String selectedPhotoAsset = '';
  var rand = new Random(Random().nextInt(1000));

  int onSelectedMedia = -1;
  List<String> medias = [
    'assets/images/thumbnails/original/02-e89189e5afb6e5afb6-e1566198293252.jpg',
    'assets/images/thumbnails/original/02e0-hphsupx4870075.jpg',
    'assets/images/thumbnails/original/54-1606903865.jpg',
    'assets/images/thumbnails/original/1629518770594950.jpg',
    'assets/images/thumbnails/original/b1.jpeg',
    'assets/images/thumbnails/original/b2.jpeg',
    'assets/images/thumbnails/original/b3.jpeg',
    'assets/images/thumbnails/original/b4.jpeg',
    'assets/images/thumbnails/original/b5.jpeg',
    'assets/images/thumbnails/original/b6.jpg',
  ];

  List<String> mediasSet1 = [
    'assets/images/thumbnails/original/baby_1.jpg',
    'assets/images/thumbnails/original/baby_2.jpg',
    'assets/images/thumbnails/original/baby_3.jpg',
    'assets/images/thumbnails/original/baby_5.jpg',
    'assets/images/thumbnails/original/baby_6.jpg',
    'assets/images/thumbnails/original/baby_7.jpg',
    'assets/images/thumbnails/original/baby_8.jpg',
    'assets/images/thumbnails/original/baby_9.jpg',
    'assets/images/thumbnails/original/d1.jpeg',
    'assets/images/thumbnails/original/d2.jpeg',
    'assets/images/thumbnails/original/d3.jpeg',
    'assets/images/thumbnails/original/d4.jpeg',
    'assets/images/thumbnails/original/d5.jpeg',
    'assets/images/thumbnails/original/f1.jpeg',
    'assets/images/thumbnails/original/f2.jpeg',
    'assets/images/thumbnails/original/f3.jpeg',
    'assets/images/thumbnails/original/f4.jpeg',
    'assets/images/thumbnails/original/f5.jpeg',
  ];

  List<String> mediasSet2 = [
    'assets/images/thumbnails/original/GsPpqc9t6YfVghEWjzWyPLuBeGAczqnWrhh4Qkbu.jpeg',
    'assets/images/thumbnails/original/ID5_1.jpg',
    'assets/images/thumbnails/original/ID5_2.jpg',
    'assets/images/thumbnails/original/ID9_1.jpg',
    'assets/images/thumbnails/original/ID9_2.jpg',
    'assets/images/thumbnails/original/ID14_1.jpg',
    'assets/images/thumbnails/original/ID22_1.jpg',
    'assets/images/thumbnails/original/ID22_2.jpg',
    'assets/images/thumbnails/original/ID23_1.jpg',
    'assets/images/thumbnails/original/ID23_3.jpg',
    'assets/images/thumbnails/original/ID26_1.jpg',
    'assets/images/thumbnails/original/ID26_2.jpg',
    'assets/images/thumbnails/original/ID29_1.jpg',
  ];

  List<String> mediasSet3 = [
    'assets/images/thumbnails/original/m1.jpeg',
    'assets/images/thumbnails/original/m2.jpeg',
    'assets/images/thumbnails/original/m3.jpeg',
    'assets/images/thumbnails/original/m4.jpeg',
    'assets/images/thumbnails/original/m5.jpeg',
    'assets/images/thumbnails/original/m6.jpeg',
    'assets/images/thumbnails/original/m7.jpeg',
    'assets/images/thumbnails/original/OMDb9z4I0hj3gsIbR84NzFPGYr7xZ4mgJgoN7pIq.jpg',
    'assets/images/thumbnails/original/P1404299861722.jpg',
    'assets/images/thumbnails/original/Ru5JFxe4uKDmYkbvlem998N02gVfKjBxATo6nBCK.jpg',
    'assets/images/thumbnails/original/wZS4l4SBBm1AODVcuQbOTGm1YOmMPDGIfmC51SrE.jpg',
  ];

  List<List<String>> mediaAlbums = [];

  ProfileData myData = ProfileData();
  List<PostData> postRecords = [];

  double getHeightOfView(double precetage) {
    return widget
        .getResponsiveSize(MediaQuery.of(context).size.height * precetage);
  }

  void showPhotoView(String resourcePath) {
    // setState(() {
    //   needShowPhotoView = true;
    //   selectedPhotoAsset = resourcePath;
    // });

    Navigator.push(
        context,
        PageTransition(
            child: new ZoomingPhotoView.clean(
              resourcePath,
              myData: myData,
            ),
            type: PageTransitionType.topToBottom));
  }

  void showPhotoGalaryView(String resourcePath) {
    showPhotoView(resourcePath);
  }

  void onChange() {
    if (globalDataStore.changeNotifier.hasListeners) {
      print('');
      globalDataStore.changeNotifier.notifyListeners();
    }
  }

  /*
=-=-=-=-=-=-=-=-= =-=-=-=-=-=-=-=-=
*/

  void loadPostRecords() async {
    postRecords.clear();
    await widget.getPostDatas().then((value) {
      value!.forEach((element) {
        postRecords.add(element);
      });
      setState(() {});
    });
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileID = prefs.getString('selectedProfile') ?? '';
    List<ProfileData>? datas = await widget.getProfileDatas();

    Future.forEach(datas!, (element) {
      var data = element as ProfileData;
      print('stored profile : $data ??' + data.id + ' , ' + data.name);
      if (data.id.compareTo(profileID) == 0) {
        myData = data;
      }
    });

    localRecordNeedUpdate();
  }

  void localRecordNeedUpdate() {
    //sim to load albums
    mediaAlbums = [
      medias,
      mediasSet1,
      mediasSet2,
      mediasSet3,
    ];

    loadPostRecords();
  }

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: HexColor('#F4F4F4'),
            body: Stack(
              children: [
                //Topbar
                Positioned(
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: globalDataStore.getResponsiveSize(topBarOffSet)),
                      width: MediaQuery.of(context).size.width,
                      height: globalDataStore
                          .getResponsiveSize(topBarHeight + topBarOffSet),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          BackButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text('Photo')
                        ],
                      ),
                    )),

                Positioned(
                  top: globalDataStore
                      .getResponsiveSize(topBarHeight + topBarOffSet),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        globalDataStore
                            .getResponsiveSize(topBarHeight + topBarOffSet),
                    width: MediaQuery.of(context).size.width,
                    // margin: EdgeInsets.symmetric(
                    //     vertical: globalDataStore.getResponsiveSize(10),
                    //     horizontal: globalDataStore.getResponsiveSize(15)),
                    // decoration: BoxDecoration(color: Colors.blue),
                    child: ListView(children: [
                      Container(
                        height: globalDataStore.getResponsiveSize(367),
                        margin: EdgeInsets.only(
                          bottom: globalDataStore.getResponsiveSize(10),
                        ),
                        // decoration: BoxDecoration(color: Colors.amber),
                        child: ListView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(mediaAlbums.length, (index) {
                            String firstMediaPath = mediaAlbums[index][0];
                            return assetBlock(245, index, firstMediaPath,
                                onSelectedMedia == index, showPhotoGalaryView,
                                mediaSetName:
                                    myData.name + '\'s 0-12 Months Memory',
                                totalMedias: mediaAlbums[index].length);
                          }),
                        ),
                      ),
                      Container(
                        height: globalDataStore.getResponsiveSize(108),
                        margin: EdgeInsets.symmetric(
                            vertical: globalDataStore.getResponsiveSize(10),
                            horizontal: globalDataStore.getResponsiveSize(0)),
                        // decoration: BoxDecoration(color: Colors.amber),
                        child: ListView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(mediasSet1.length, (index) {
                            double size = 108;
                            return assetBlock(size, index, mediasSet1[index],
                                onSelectedMedia == index, showPhotoView);
                          }),
                        ),
                      ),
                      Container(
                        height: globalDataStore.getResponsiveSize(108),
                        margin: EdgeInsets.symmetric(
                            vertical: globalDataStore.getResponsiveSize(10),
                            horizontal: globalDataStore.getResponsiveSize(0)),
                        // decoration: BoxDecoration(color: Colors.amber),
                        child: ListView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(mediasSet2.length, (index) {
                            double size = rand.nextInt(mediasSet3.length) == 0
                                ? 231
                                : 108;
                            return assetBlock(size, index, mediasSet2[index],
                                onSelectedMedia == index, showPhotoView);
                          }),
                        ),
                      ),
                      Container(
                        height: globalDataStore.getResponsiveSize(108),
                        margin: EdgeInsets.symmetric(
                            vertical: globalDataStore.getResponsiveSize(10),
                            horizontal: globalDataStore.getResponsiveSize(0)),
                        // decoration: BoxDecoration(color: Colors.amber),
                        child: ListView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(mediasSet3.length, (index) {
                            double size = rand.nextInt(mediasSet3.length) == 0
                                ? 231
                                : 108;
                            return assetBlock(size, index, mediasSet3[index],
                                onSelectedMedia == index, showPhotoView);
                          }),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            )),
        onWillPop: () async {
          return false;
        });
  }
}

Widget assetBlock(double width, int idx, String resourcePath, bool onSelected,
    Function(String) onPress,
    {String mediaSetName = '', int totalMedias = 0}) {
  bool showAlbumeTitle = mediaSetName.length > 0;
  String photoAmontText = '$totalMedias Photo' + (totalMedias > 1 ? 's' : '');

  return Container(
    width: width,
    margin: EdgeInsets.only(left: idx == 0 ? 15 : 0, right: 15),
    // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
        image:
            DecorationImage(image: AssetImage(resourcePath), fit: BoxFit.cover),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border:
            Border.all(width: onSelected ? 3 : 0, color: HexColor('#FFB2B2')),
        boxShadow: [BoxShadow(spreadRadius: 0, blurRadius: 3)],
        color: HexColor('#FFB2B2')),
    child: MaterialButton(
      onPressed: () {
        onPress(resourcePath);
      },
      child: Column(
        children: [
          if (showAlbumeTitle) ...[
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(
                  top: globalDataStore.getResponsivePositioning(8),
                  bottom: globalDataStore.getResponsiveSize(12)),
              padding: EdgeInsets.symmetric(
                  horizontal: globalDataStore.getResponsivePositioning(8),
                  vertical: globalDataStore.getResponsivePositioning(5)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(globalDataStore.getResponsiveSize(5))),
                color: HexColor('#0C3658'),
              ),
              child: Text(
                mediaSetName,
                style: TextStyle(
                    fontFamily: 'SFProText-Semibold',
                    fontSize: globalDataStore.getResponsiveSize(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                photoAmontText,
                style: TextStyle(
                    fontFamily: 'SFProText-Bold',
                    fontSize: globalDataStore.getResponsiveSize(30),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: globalDataStore.getResponsiveSize(10))
                    ]),
              ),
            )
          ],
        ],
      ),
    ),
  );
}
