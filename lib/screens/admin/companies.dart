import 'package:flutter/material.dart';

class Companies extends StatefulWidget {
  static const routeName = "/companies";

  const Companies({super.key});

  @override
  State<Companies> createState() => _CompaniesState();
}

class _CompaniesState extends State<Companies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Companies"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 15,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: SizedBox(
                                  width: 20,
                                  height: 15,
                                  child: Stack(children: []),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 243,
                          height: 48,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 243,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF2F1F2),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 0.80, color: Color(0xFFE3E2E6)),
                                      borderRadius: BorderRadius.circular(72),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 17),
                ],
              ),
            ),
            Container(
              width: 375,
              height: 41,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFFFCFCFC),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26A7A7A7),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 37,
                    height: 30,
                    child: Stack(children: []),
                  ),
                  const Positioned(
                    left: 45,
                    top: 30,
                    child: Text(
                      'Add Company',
                      style: TextStyle(
                        color: Color(0xFF1A1E25),
                        fontSize: 16,
                        fontFamily: 'Hind',
                        fontWeight: FontWeight.w400,
                        height: 0.06,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ),
                  const Positioned(top: 15, left: 300, child: Icon(Icons.add))
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 10),
              child: Text(
                'Service companies',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0.06,
                  letterSpacing: 0.35,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              width: 300,
              height: 99,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x26424242),
                    blurRadius: 96,
                    offset: Offset(0, 24),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 106,
                      height: 99,
                      clipBehavior: Clip.antiAlias,
                      decoration: const ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://gmcleaning.co.ke/wp-content/uploads/2022/04/Gm-Cleaning-Services-Team.jpg"),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 124,
                    top: 16,
                    child: SizedBox(
                      width: 160,
                      height: 134,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 25,
                                      ),
                                      SizedBox(
                                        width: 164,
                                        child: Text(
                                          'Clean City Services',
                                          style: TextStyle(
                                            color: Color(0xFF1A1E25),
                                            fontSize: 16,
                                            fontFamily: 'Hind',
                                            fontWeight: FontWeight.w400,
                                            height: 0.08,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 18),
                                      Text(
                                        'cleancity@smart.com',
                                        style: TextStyle(
                                          color: Color(0xFF7D7F88),
                                          fontSize: 13,
                                          fontFamily: 'Hind',
                                          fontWeight: FontWeight.w400,
                                          height: 0.10,
                                          letterSpacing: 0.13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
