import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class AddEvent extends StatefulWidget {
  final User? userCreds;
  final LatLng? droppedPin;
  final Map? formDetail;
  final String? updateEvent;
  final String? imageUrl;
  const AddEvent(
      {Key? key,
      required this.userCreds,
      required this.droppedPin,
      required this.updateEvent,
      this.formDetail,
      this.imageUrl})
      : super(key: key);

  @override
  AddEventState createState() => AddEventState();
}

class AddEventState extends State<AddEvent> {
  late String defaultImg;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? userAddress;
  late TextEditingController dateControl;
  late TextEditingController titleControl;
  late TextEditingController descControl;
  String? streetAddress;
  bool _enableBtn = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('events');

  TextEditingController? locationControl;

  void _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void checkButtonStatus() {
    if (dateControl.text != "" &&
        titleControl.text != "" &&
        descControl.text != "") {
      _enableBtn = true;
    }
  }

  @override
  void initState() {
    super.initState();
    dateControl = TextEditingController(text: widget.formDetail!["date"] ?? "");
    defaultImg = widget.imageUrl ?? "https://www.colorhexa.com/bdbdbd.png";
    titleControl =
        TextEditingController(text: widget.formDetail!["title"] ?? "");
    descControl = TextEditingController(text: widget.formDetail!["desc"] ?? "");
    getUserLocation(widget.droppedPin);
    setState(() {
      checkButtonStatus();
    });
  }

  addEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference ref = firestore
            .collection('events')
            .doc("custom")
            .collection(userAddress!.toLowerCase());

        List<String> emptyList = [];
        String? imageUrl;

        if (_image != null) {
          var fileRef = firebase_storage.FirebaseStorage.instance
              .ref(const Uuid().v4().toString());
          try {
            await fileRef.putFile(File(_image!.path));
          } catch (e) {
            // e.g, e.code == 'canceled'
          }
          imageUrl = await fileRef.getDownloadURL();
        }

        await ref.add({
          'title': titleControl.text,
          'location': streetAddress,
          'latitude': widget.droppedPin!.latitude,
          'longitude': widget.droppedPin!.longitude,
          'dateTime': dateControl.text,
          'description': descControl.text,
          'createdBy': widget.userCreds!.uid,
          'createdByName': widget.userCreds!.displayName,
          'numAttendees': 0,
          'attendees': emptyList,
          "imageUrl": imageUrl ?? defaultImg,
        });

        showBox("Event Added Succesfully", "SUCCESS");
      } catch (e) {
        showBox(e.toString(), "ERROR");
      }
    }
  }

  void updateEvent() async {
    var ref = firestore
        .collection('events')
        .doc("custom")
        .collection(userAddress!.toLowerCase())
        .doc(widget.updateEvent);

    await ref.update({
      'title': titleControl.text,
      'location': streetAddress,
      'latitude': widget.droppedPin!.latitude,
      'longitude': widget.droppedPin!.longitude,
      'dateTime': dateControl.text,
      'description': descControl.text,
    });

    Navigator.pop(context);
  }

  getUserLocation(LatLng? position) async {
    late GoogleGeocoding googleGeocoding;
    if (Platform.isAndroid) {
      googleGeocoding = GoogleGeocoding(dotenv.env["API_KEY_ANDRIOD"]!);
    } else if (Platform.isIOS) {
      googleGeocoding = GoogleGeocoding(dotenv.env["API_KEY_IOS"]!);
    }
    var result = await googleGeocoding.geocoding
        .getReverse(LatLon(position!.latitude, position.longitude));

    String? locationString;
    List<String> splitAddress =
        result!.results![0].formattedAddress!.split(',');

    if (splitAddress.length >= 5) {
      locationString = splitAddress[0] + splitAddress[1];
      userAddress = splitAddress[2].trim();
    } else if (splitAddress.length == 3) {
      var formatAddress = splitAddress[0].split(" ")[1];
      locationString = formatAddress;
      userAddress = formatAddress.trim();
    } else {
      locationString = splitAddress[0];
      userAddress = splitAddress[1].trim();
    }
    streetAddress = result.results![0].formattedAddress;

    setState(() {
      locationControl = TextEditingController(text: locationString);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  showBox(String? message, String? title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title!),
            content: Text(message!),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                    if (title == "SUCCESS") {
                      Navigator.of(context).pop("Added");
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            backgroundColor: Colors.blue,
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
            width: widthVariable,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: _image == null
                        ? NetworkImage(defaultImg) as ImageProvider
                        : FileImage(File(_image!.path)),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(widthVariable / 1.2, 100, 0, 10),
              child: FloatingActionButton(
                heroTag: "btn2",
                mini: true,
                onPressed: () {
                  _showPicker(context);
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
              child: Form(
                  key: _formKey,
                  onChanged: () => setState(() => {checkButtonStatus()}),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: titleControl,
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Please enter a Title";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Title ',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: locationControl,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.of(context).pop({
                            "title": titleControl.text,
                            "desc": descControl.text,
                            "date": dateControl.text,
                          });
                        },
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Enter a location";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: dateControl,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));

                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          dateControl.text =
                              DateFormat('EEEE, d MMM yyyy').format(date!) +
                                  " " +
                                  time!.format(context) +
                                  " " +
                                  date.timeZoneName;
                        },
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Enter a time and date";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: descControl,
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        maxLines: null,
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "";
                          }
                        },
                        decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                          width: widthVariable,
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            elevation: 7.0,
                            child: ElevatedButton(
                              style: _enableBtn
                                  ? ElevatedButton.styleFrom(
                                      primary: Colors.blue)
                                  : ElevatedButton.styleFrom(
                                      primary: Colors.grey),
                              onPressed: _enableBtn
                                  ? () {
                                      if (widget.updateEvent == null) {
                                        addEvent();
                                      } else {
                                        updateEvent();
                                      }
                                    }
                                  : () {},
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(height: 20.0),
                    ],
                  ))),
        ])));
  }
}
