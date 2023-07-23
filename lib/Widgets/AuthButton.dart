import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({Key? key, required this.text,required this.onClick,required this.bgColor,required this.textColor}) : super(key: key);
  final text, onClick,bgColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: MediaQuery.of(context).size.width*0.5,
        child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                        elevation: 5.0, backgroundColor: bgColor,
                        padding:const EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(15.0)
                        ),
                ),
                onPressed:onClick,
                child: Text(text,style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: textColor),),

        ),
    );
  }
}
