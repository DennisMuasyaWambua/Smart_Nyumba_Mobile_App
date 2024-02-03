import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';
import '../../widgets/status_indicator.dart';

List<Map<String, dynamic>> companies = [
  {
    "name": "Clean City Services",
    "status": 1,
    "time_period": "Oct 2023  - Present",
  },
  {
    "name": "Johnstone Construction Company",
    "status": 1,
    "time_period": "July 2023  - Present",
  },
  {
    "name": "Fence Trimming Services",
    "status": 0,
    "time_period": "Apr 2023 - May 2023",
  },
  {
    "name": "Joy's Event Planning",
    "status": 0,
    "time_period": "Jan 2023 - Feb 2023",
  },
];

class Companies extends StatelessWidget {
  static const routeName = "/companies";

  const Companies({super.key});

  @override
  Widget build(BuildContext context) {
    List<String?> valuesToShow = ModalRoute.of(context)!.settings.arguments as List<String?>;
    List<dynamic> pastCompanies =
        companies.where((element) => element['status'] == 0).toList();
    List<dynamic> activeCompanies =
        companies.where((element) => element['status'] == 1).toList();

    List<dynamic> renderedList = [];

    switch (valuesToShow.first.toString()) {
      case "past":
        renderedList = pastCompanies;
        break;
      case "active":
        renderedList = activeCompanies;
        break;
      default:
        renderedList = companies;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Companies"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
              itemCount: renderedList.length,
              itemBuilder: (context, index) {
                var company = renderedList[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      company['name'],
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    subtitle: Text(company['time_period']),
                    trailing:
                        StatusIndicator(color: company['status'] == 1 ? darkGreen : lightGrey),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
