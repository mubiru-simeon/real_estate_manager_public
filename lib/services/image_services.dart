import 'dart:io';
import 'dart:typed_data';
import 'package:dorx/models/language.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'services.dart';

class ImagePickerWidget extends StatefulWidget {
  final List images;
  final String text;
  final int crossAxisCount;
  final bool noSliver;
  final Function pickImages;
  const ImagePickerWidget({
    Key key,
    @required this.images,
    this.text,
    this.noSliver = false,
    this.crossAxisCount = 3,
    @required this.pickImages,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.noSliver
        ? body()
        : SliverList(
            delegate: SliverChildListDelegate([
              body(),
            ]),
          );
  }

  body() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: standardBorderRadius,
      ),
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          actualPickerBody(
            images: widget.images,
            imageMode: false,
            text: widget.text,
            pickImages: widget.pickImages,
          ),
          actualPickerBody(
            images: widget.images,
            crossAxisCount: 3,
            imageMode: true,
            pickImages: widget.pickImages,
          ),
        ],
      ),
    );
  }

  actualPickerBody({
    List images,
    bool imageMode,
    String text,
    int crossAxisCount = 3,
    Function pickImages,
  }) {
    return !imageMode
        ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 8,
            ),
            child: InkWell(
              onTap: () {
                pickImages();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: standardBorderRadius,
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate),
                      Text(text ?? "Add Images")
                    ],
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            height: 200,
            child: images.isEmpty
                ? Center(
                    child: Text(
                      translation(context).noImagesYet,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: images.map((e) {
                        return SingleThumbnail(
                          asset: e,
                          onCloseThingiePressed: () {
                            setState(() {
                              images.remove(e);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
          );
  }
}

class ImageServices {
  Future<List<File>> pickImages(
    BuildContext context, {
    int limit = 10,
  }) async {
    List<File> returnThis = [];

    await UIServices().showDatSheet(
      ImageOptionsBottomSheet(
        onCameraTap: () async {
          returnThis = await goToCamera(context, limit);

          Navigator.of(context).pop();
        },
        onGalleryTap: () async {
          returnThis = await goToMultiPicker(context, limit);

          Navigator.of(context).pop();
        },
      ),
      false,
      context,
      height: MediaQuery.of(context).size.height * 0.4,
    );

    return returnThis;
  }

  Future<List<File>> goToMultiPicker(
    BuildContext context,
    int limit,
  ) async {
    List<XFile> imges = await ImagePicker().pickMultiImage();

    if (imges != null && imges.isNotEmpty) {
      List<File> files = [];

      for (var element in imges) {
        files.add(File(element.path));
      }

      // ignore: use_build_context_synchronously
      List<File> images = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageView(
            limit: limit,
            images: files,
          ),
        ),
      );

      return images;
    } else {
      return [];
    }
  }

  Future<List<File>> goToCamera(
    BuildContext context,
    int limit,
  ) async {
    XFile image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      File ff = File(image.path);

      // ignore: use_build_context_synchronously
      List<File> images = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageView(
            limit: limit,
            images: [ff],
          ),
        ),
      );

      return images;
    } else {
      return [];
    }
  }

  Future<List<String>> uploadImages({
    @required String path,
    @required Function onError,
    @required List images,
    Uint8List bytes,
  }) async {
    List<String> imgUrls = [];

    if ((images == null || images.isEmpty || images[0] == null) &&
        (bytes == null || bytes.isEmpty)) {
      return imgUrls;
    } else {
      try {
        if (images != null && images.isNotEmpty) {
          for (var element in images) {
            if (element != null) {
              if (element is File) {
                List<int> imageData = await element.readAsBytes();
                String tyme = DateTime.now().toString();
                Reference ref = FirebaseStorage.instance
                    .ref()
                    .child(
                      path ?? "images",
                    )
                    .child(
                      "$tyme.jpg",
                    );
                UploadTask uploadTask = ref.putData(imageData);
                String url = await (await uploadTask).ref.getDownloadURL();
                imgUrls.add(url);
              } else {
                if (element.toString().trim().contains(
                      "assets/images",
                    )) {
                } else {
                  if (element is String) {
                    imgUrls.add(element.toString());
                  }
                }
              }
            }
          }
        } else {
          if (bytes != null) {
            String tyme = DateTime.now().toString();
            Reference ref = FirebaseStorage.instance
                .ref()
                .child(
                  path ?? "images",
                )
                .child(
                  "$tyme.jpg",
                );
            UploadTask uploadTask = ref.putData(bytes);
            String url = await (await uploadTask).ref.getDownloadURL();
            imgUrls.add(url);
          }
        }

        return imgUrls;
        // ignore: unused_catch_clause
      } on Exception catch (e) {
        onError();
        return [];
      }
    }
  }

  Future<bool> downloadFile(
    String link,
    Function onError,
  ) async {
    Directory dd = await getApplicationDocumentsDirectory();
    var ref = FirebaseStorage.instance.refFromURL(link);

    File download = File(
      "${dd.path}/${ref.name}",
    );

    try {
      return await FirebaseStorage.instance
          .ref(ref.fullPath)
          .writeToFile(download)
          .then((p0) {
        return true;
      });
    } catch (e) {
      onError();

      return false;
    }
  }
}

class ImageWorks extends StatelessWidget {
  const ImageWorks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }
}

class ImageOptionsBottomSheet extends StatelessWidget {
  final Function onCameraTap;
  final Function onGalleryTap;
  const ImageOptionsBottomSheet({
    Key key,
    @required this.onCameraTap,
    @required this.onGalleryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Select An Option",
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      onCameraTap();
                    },
                    icon: Icon(
                      Icons.camera,
                    ),
                  ),
                  Text(
                    "Camera",
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      onGalleryTap();
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                    ),
                  ),
                  Text(
                    "Gallery",
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CropImageView extends StatefulWidget {
  final CropAspectRatio cropAspectRatio;
  final List<File> images;
  final int limit;
  CropImageView({
    Key key,
    @required this.images,
    @required this.limit,
    this.cropAspectRatio,
  }) : super(key: key);

  @override
  State<CropImageView> createState() => _CropImageViewState();
}

class _CropImageViewState extends State<CropImageView> {
  @override
  void initState() {
    super.initState();

    finalList = widget.images;
  }

  List<File> finalList = [];
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return goBackAndReturnTheList();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: finalList.isNotEmpty
                    ? Image(
                        fit: BoxFit.cover,
                        // height: (MediaQuery.of(context).size.height - 110).toInt(),
                        // width: (MediaQuery.of(context).size.width).toInt(),
                        image: FileImage(finalList[count]),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translation(context).noImagesYet,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  count = index;
                                });
                              }
                            },
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: count == index ? 2 : 0,
                                          color: Colors.white)),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image(
                                      image: FileImage(finalList[index]),
                                      height: 60,
                                      width: 60,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(3),
                                      child: InkWell(
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              if (finalList[index] ==
                                                      finalList.last &&
                                                  finalList.length != 1) {
                                                count = index - 1;
                                              }
                                              finalList.removeAt(index);
                                            });
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.close,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }, childCount: finalList.length),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    cropThatBissh(count);
                  },
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 10,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    goBackAndReturnTheList();
                  },
                  label: Text("Done"),
                  icon: Icon(Icons.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cropThatBissh(int index) async {
    if (finalList.isNotEmpty) {
      CroppedFile croppedFailo = await ImageCropper().cropImage(
        sourcePath: finalList[index].path,
        aspectRatio: widget.cropAspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: capitalizedAppName,
            toolbarColor: altColor,
            cropGridColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            cropFrameColor: primaryColor,
            activeControlsWidgetColor: primaryColor,
            statusBarColor: Colors.grey,
            backgroundColor: primaryColor,
            dimmedLayerColor: primaryColor.withOpacity(0.5),
          )
        ],
      );

      if (croppedFailo != null) {
        File cc = File(croppedFailo.path);

        if (mounted) {
          setState(() {
            finalList.replaceRange(
              index,
              index + 1,
              [
                cc,
              ],
            );
          });
        }
      }
    } else {
      CommunicationServices()
          .showSnackBar(translation(context).noImagesYet, context);
    }
  }

  goBackAndReturnTheList() {
    Navigator.of(context).pop(finalList);
  }
}
