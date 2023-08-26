import 'package:bookbode/app/Core/utilities/constants/colors.dart';
import 'package:bookbode/app/Core/utilities/constants/spacing.dart';
import 'package:flutter/widgets.dart';

class CitiesList extends StatefulWidget {
  const CitiesList({super.key});

  @override
  State<CitiesList> createState() => _CitiesListState();
}

class _CitiesListState extends State<CitiesList> {
  var citiesList = {
    "2.png": "Paris",
    "3.png": "London",
    "4.png": "Bangkok",
    "5.png": "Roma",
    "6.png": "Jakarta",
  };
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.maxFinite,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: citiesList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 24),
              child: Column(children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: hMnueColor,
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Image.asset(
                      "assets/imgs/${citiesList.keys.elementAt(index)}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                kVSpace8,
                Text(
                  citiesList.values.elementAt(index),
                  style: const TextStyle(color: hDarkGray, fontSize: 14),
                ),
              ]),
            );
          }),
    );
  }
}
