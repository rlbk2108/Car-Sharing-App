import 'dart:io';

import 'package:car_sharing/main.dart';
import 'package:car_sharing/models/cars.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateCarScreen extends StatefulWidget {
  @override
  _UpdateCarScreenState createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateCarScreen> with ChangeNotifier{
  final carModelController = TextEditingController();
  final carTypeController = TextEditingController();
  final carColorController = TextEditingController();
  final carMileageController = TextEditingController();
  final carCostPerDayController = TextEditingController();
  final carImageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late String carImage;

  void onUpdate(Car car) {
      car = Car(id: car.id, model: carModelController.text, type: carTypeController.text,
          color: carColorController.text,
          mileage: int.parse(carMileageController.text), costPerDay: int.parse(carCostPerDayController.text),
      image: _imageFileList);
      Provider.of<MyAppState>(context, listen: false).updateCar(car);
  }

  late String _imageFileList = carImage;

  Future<void> _setImageFileListFromFile(File value) async {
    _imageFileList = value.path;
    notifyListeners();
    print(value.path);
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
        print("ERAA");
        setState(() {
          _setImageFileListFromFile(File(path));
        });
      } catch (e) {
        print('Error from _filePick $e');
      }
    } else {
      print('File system picker open error.');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final car = ModalRoute.of(context)!.settings.arguments as Car;
    carModelController.text = car.model;
    carTypeController.text = car.type;
    carColorController.text = car.color;
    carMileageController.text = car.mileage.toString();
    carCostPerDayController.text = car.costPerDay.toString();
    carImage = car.image;
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit car'),
          elevation: 2.0),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.hardEdge,
                  child: Ink.image(
                    fit: BoxFit.cover,
                    height: 200,
                    image: Image(
                      image: _imageFileList.startsWith('http') ?
                      Image.network(car.image).image
                          :
                      Image.file(File(_imageFileList)).image,
                        fit: BoxFit.cover
                    ).image,
                    child: InkWell(
                      onTap: () {
                        _dialogBuilder(context);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 17),
                TextFormField(
                  controller: carModelController,
                  decoration: InputDecoration(
                      labelText: 'Enter a model',
                      prefixIcon: Icon(Icons.mode),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      )),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: carTypeController,
                  decoration: InputDecoration(
                      labelText: 'Enter a type',
                      prefixIcon: Icon(Icons.car_crash),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      )),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: carColorController,
                  decoration: InputDecoration(
                      labelText: 'Enter a color',
                      prefixIcon: Icon(Icons.color_lens),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      )),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: carMileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Enter a mileage',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)
                      )),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: carCostPerDayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Specify the price',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      )),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                FilledButton(
                  clipBehavior: Clip.hardEdge,
                    onPressed: () {
                      onUpdate(car);
                      Navigator.of(context).pop();
                    }, child: Text('Save'),)
              ],
            ),
          )
        ],
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
        });
        print('object');
      } catch (e) {
        print('catch $e');
        setState(() {

        });
      }
    }
  }
}