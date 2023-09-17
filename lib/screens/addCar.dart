import 'dart:io';

import 'package:car_sharing/main.dart';
import 'package:car_sharing/models/cars.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> with ChangeNotifier {
  late List<File> _imageFileList = <File>[];

  Future<void> _setImageFileListFromFile(File value) async {
    _imageFileList = <File>[value];
    notifyListeners();
    print(value.path);
    carImage = value.path;
  }

  _filePick({required BuildContext context}) async {
    if (context.mounted) {
      try {
        Directory appDocDir = Directory("/storage/emulated/0/");

        final String path = (await FilesystemPicker.openDialog(
          title: 'Pick an image',
          context: context,
          rootDirectory: appDocDir,
          fsType: FilesystemType.file,
          pickText: 'Save file to this folder',
          allowedExtensions: ['.png', '.jpg', '.jpeg', '.webp'],
          fileTileSelectMode: FileTileSelectMode.wholeTile,
        )).toString();

        setState(() {
          _setImageFileListFromFile(File(path));
        });
      } catch (e) {
        print(e);
      }
    } else {
      print('File system picker open error.');
    }
  }


  final carModelController = TextEditingController();
  final carTypeController = TextEditingController();
  final carColorController = TextEditingController();
  final carMileageController = TextEditingController();
  final carCostPerDayController = TextEditingController();
  late String carImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  dynamic _pickImageError;

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Choose image source'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.icon(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.camera, context: context);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera')),
                FilledButton.icon(
                    onPressed: () {
                      //_onImageButtonPressed(ImageSource.gallery, context: context);
                      FilesystemPickerDefaultOptions(
                          fsType: FilesystemType.all,
                          fileTileSelectMode: FileTileSelectMode.wholeTile,
                          theme: FilesystemPickerTheme(
                            topBar: FilesystemPickerTopBarThemeData(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                          child: _filePick(context: context),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.image),
                    label: Text('Gallery')),
              ],
            )
        );
      },
    );
  }

  void onAdd(BuildContext context) {
    final String modelValue = carModelController.text;
    final String typeValue = carTypeController.text;
    final String colorValue = carColorController.text;
    final String mileageValue = carMileageController.text;
    final String costPerDayValue = carCostPerDayController.text;
    final String carImageValue = carImage;

    if (modelValue.isNotEmpty && typeValue.isNotEmpty && colorValue.isNotEmpty) {
      final Car car = Car(model: modelValue, type: typeValue, color: colorValue,
                          mileage: int.parse(mileageValue), costPerDay: int.parse(costPerDayValue), image: carImageValue);
      Provider.of<MyAppState>(context, listen: false).addCar(car, carImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add car'),
        elevation: 2.0),
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose an image', style: TextStyle(fontSize: 30),),
                  Card(
                    clipBehavior: Clip.hardEdge,
                    child: Ink.image(
                      fit: BoxFit.cover,
                      height: 200,
                      image: Image(
                        image: _imageFileList.isEmpty ?
                        Image.asset('assets/images/empty.png').image
                            :
                        Image.file(_imageFileList.single).image,
                        fit: BoxFit.cover,
                      ).image,
                      child: InkWell(
                        onTap: () {
                          _dialogBuilder(context);
                        },
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: carModelController,
                    decoration: InputDecoration(
                        labelText: 'Enter a model',
                        prefixIcon: Icon(Icons.mode),
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: carTypeController,
                    decoration: InputDecoration(
                        labelText: 'Enter a type',
                        prefixIcon: Icon(Icons.car_crash),
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: carColorController,
                    decoration: InputDecoration(
                        labelText: 'Enter a color',
                        prefixIcon: Icon(Icons.color_lens),
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: carMileageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Enter a mileage',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: carCostPerDayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Specify the price',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    OutlinedButton(
                        style: ButtonStyle(fixedSize: MaterialStateProperty.resolveWith((states) => Size(80, 50))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel')),
                    SizedBox(width: 10,),
                    FilledButton(
                        style: ButtonStyle(fixedSize: MaterialStateProperty.resolveWith((states) => Size(80, 50))),
                        onPressed: () {
                          onAdd(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Add')),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }



  Future<void> _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    if (context.mounted) {
      print("IMAGE");
        try {
          print('After try');
          final XFile? pickedFile = (await _picker.pickImage(
            source: source,
          ));
          setState(() {
            _setImageFileListFromFile(File(pickedFile!.path));
            carImage = File(pickedFile.path).path;
          });
          print('object');
        } catch (e) {
          print('catch $e');
          setState(() {
            _pickImageError = e;
          });
        }
    }
  }
}