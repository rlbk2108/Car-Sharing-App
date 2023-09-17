import 'dart:async';
import 'dart:convert';
import 'package:car_sharing/models/clients.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:cr_calendar/cr_calendar.dart';
import 'package:car_sharing/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:cool_alert/cool_alert.dart';
import '../env.sample.dart';
import '../models/cars.dart';
import '../models/sharing.dart';
import '../pages/bottom_button.dart';
import '../pages/maps.dart';
import '../pages/stat_details.dart';

class CarDetail extends StatefulWidget {
  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetail> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const LatLng _center = LatLng(43.06030845753327, 74.4709868318596);
  late Car rentingCar;
  DateTimeRange? _selectedDateRange;
  var days = 0;

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2024, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade200, // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Colors.white,
              surface: Colors.deepPurple,

            ),
          ),
          child: child!,
        );
      }
    );

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });
    }
  }


  void onRent() {
    DateTime? start = _selectedDateRange?.start;
    DateTime? end = _selectedDateRange?.end;
    int difference = 0;

    if (start != null && end != null) {
      difference = end.difference(start).inDays;

      days = difference;
      if (difference > 0) {
        final Share sharing = Share(client: 1, car: rentingCar.id!, dateOfIssue: start.toUtc().toString(),
            dateOfReturn: end.toUtc().toString(), numberOfDays: difference, fullCar: rentingCar.toJson());
        print(sharing.dateOfIssue);
        print(sharing.dateOfReturn);
        Provider.of<MyAppState>(context, listen: false).rentCar(sharing);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final car = ModalRoute.of(context)!.settings.arguments as Car;
    rentingCar = car;
    return Scaffold(
      appBar: AppBar(
        bottomOpacity: 0.0,
        elevation: 10.0,
        shadowColor: Colors.transparent,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18
            ),
            child: Stack(
              children: [
                ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    SizedBox(height: 20,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        car.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            car.model.toString(),
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withAlpha(215),
                              fontSize: 33,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${car.costPerDay}\$ per day',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withAlpha(215),
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStat(
                            UniconsLine.dashboard,
                            'Mileage:',
                            '${car.mileage} KM',
                            size,
                          ),
                          buildStat(
                            UniconsLine.palette,
                            'Color:',
                            car.color,
                            size,
                          ),
                          buildStat(
                            UniconsLine.car_sideview,
                            'Car type:',
                            car.type,
                            size,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        size.height * 0.03,
                        0,
                        size.height * 0.01,
                      ),
                      child: Text(
                        'Vehicle Location',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha(215),
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: size.height * 0.15,
                        width: size.width * 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.25),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15,),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.052,
                                  vertical: size.height * 0.020,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      UniconsLine.map_marker,
                                      color: Colors.deepPurple.withOpacity(0.99),
                                      size: size.height * 0.05,
                                    ),
                                    Text(
                                      'Manas Airport',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withAlpha(215),
                                        fontSize: size.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manas Airport Rd, Bishkek',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: size.width * 0.032,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.17,
                                width: size.width * 0.275,
                                child: GoogleMap(
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: const CameraPosition(
                                    target: _center,
                                    zoom: 12.0,
                                  ),
                                  onMapCreated: (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                  zoomControlsEnabled: false,
                                  scrollGesturesEnabled: true,
                                  zoomGesturesEnabled: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 1.0,
                    ),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(500, 70),
                            backgroundColor: Colors.deepPurple.shade400,
                            foregroundColor: Colors.white,
                            elevation: 20.0
                        ),
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    elevation: 20.0,
                                    title: Text('Want to rent ${car.model}?'),
                                    content: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('You have to specify the number of days you want to rent car for.\n'),
                                        Text('Press the "Select date" button.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600
                                        ),),
                                        SizedBox(height: 6,),

                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: _show,
                                          child: Text('Select date')),
                                      SizedBox(width: 43,),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: Theme.of(context).textTheme.labelLarge,
                                        ),
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FilledButton(
                                        style: TextButton.styleFrom(
                                          textStyle: Theme.of(context).textTheme.labelLarge,
                                        ),
                                        child: const Text('Rent'),
                                        onPressed: () {
                                          onRent();
                                          Navigator.of(context).pop();
                                          _selectedDateRange != null ?
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.success,
                                            text: "Car rented successfully!",
                                          ) :
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.warning,
                                            text: "You haven't specified the number of days!",
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                        child: Text('Rent the car',
                        style: GoogleFonts.poppins(
                          fontSize: 20
                        ),)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
