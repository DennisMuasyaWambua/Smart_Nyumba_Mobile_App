import 'package:flutter/material.dart';

class EstateTenants extends StatefulWidget {
  const EstateTenants({super.key});

  @override
  State<EstateTenants> createState() => _EstateTenantsState();
}

class _EstateTenantsState extends State<EstateTenants> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Center(
                child: SizedBox(
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
                                          side: const BorderSide(
                                              width: 0.80, color: Color(0xFFE3E2E6)),
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
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40, left: 10),
                child: Text(
                  'Tenants',
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
              SizedBox(
                width: 331,
                height: 60,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(51),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "https://photo-cdn2.icons8.com/JMvRwpohHZB8QadFTId1DMUrYA8PhdO4B8l49X8Q24c/rs:fit:288:432/czM6Ly9pY29uczgu/bW9vc2UtcHJvZC5h/c3NldHMvYXNzZXRz/L3NhdGEvb3JpZ2lu/YWwvNzI3LzgxYTk2/ZmNiLTk0ZWItNGI0/Ny05YmM4LTgwYjdl/ZjRiYWUwMi5qcGc.webp"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctor Wanjala',
                              style: TextStyle(
                                color: Color(0xFF1A1E25),
                                fontSize: 16,
                                fontFamily: 'Hind',
                                fontWeight: FontWeight.w700,
                                height: 0.06,
                                letterSpacing: 0.21,
                              ),
                            ),
                            SizedBox(height: 25),
                            SizedBox(
                              width: 140,
                              child: Text(
                                'Apt No: A104',
                                style: TextStyle(
                                  color: Color(0xFF7D7F88),
                                  fontSize: 14,
                                  fontFamily: 'Hind',
                                  fontWeight: FontWeight.w400,
                                  height: 0.07,
                                  letterSpacing: 0.28,
                                ),
                              ),
                            ),
                            SizedBox(height: 18),
                            SizedBox(
                              width: 140,
                              child: Text(
                                'Tel: 07 ** *** ***',
                                style: TextStyle(
                                  color: Color(0xFF7D7F88),
                                  fontSize: 14,
                                  fontFamily: 'Hind',
                                  fontWeight: FontWeight.w400,
                                  height: 0.07,
                                  letterSpacing: 0.28,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 81),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '15:23',
                              style: TextStyle(
                                color: Color(0xFF7D7F88),
                                fontSize: 12,
                                fontFamily: 'Hind',
                                fontWeight: FontWeight.w400,
                                height: 0.08,
                                letterSpacing: 0.24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
