import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants.dart';

class SingleOrder extends StatefulWidget {
  @override
  _SingleOrderState createState() => _SingleOrderState();
}

class _SingleOrderState extends State<SingleOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlueColor,
      body: Container(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  "assets/images/bk.png",
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: kToolbarHeight,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Details About\n",
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                          TextSpan(
                            text: "Order #521",
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Constants.scaffoldBackgroundColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Details",
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromRGBO(74, 77, 84, 1),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                          const Text(
                            "Lubricants",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(143, 148, 162, 1),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          getItemRow("3", "Delo-x Silver", "\Rs : 673.00"),
                          getItemRow("2", "Delo-x Gold", "\Rs : 773.00"),
                          getItemRow("4", "Havoline Super", "\Rs : 673.00"),
                          getItemRow("1", "Rando HD", "\Rs : 873.00"),
                          const SizedBox(
                            height: 30.0,
                          ),
                          const Text(
                            "Lubricants",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(143, 148, 162, 1),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          getItemRow("3", "Canopus 46", "\Rs : 1773.00"),
                          const Divider(),
                          getSubtotalRow("Subtotal", "\Rs : 2973.00"),
                          getSubtotalRow("Delivery", "\Rs : 999.00"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          getTotalRow("Total", "\$225.00"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      height: ScreenUtil().setHeight(120.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Your Lubricants are now out.",
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromRGBO(74, 77, 84, 1),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Estimated Delivery\n",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color.fromRGBO(143, 148, 162, 1),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "01 May 2025",
                                      style: TextStyle(
                                        color: Color.fromRGBO(74, 77, 84, 1),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                "assets/images/chevron.png",
                                height: 50,
                                width: 50,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getTotalRow(String title, String amount) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RedColor,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(
            color: BlueColor,
            fontWeight: FontWeight.w600,
            fontSize: 17.0,
          ),
        )
      ],
    ),
  );
}

Widget getSubtotalRow(String title, String price) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color.fromRGBO(74, 77, 84, 1),
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          price,
          style: const TextStyle(
            color: Color.fromRGBO(74, 77, 84, 1),
            fontSize: 15.0,
          ),
        )
      ],
    ),
  );
}

Widget getItemRow(String count, String item, String price) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Color.fromRGBO(74, 77, 84, 1),
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            " x $item",
            style: const TextStyle(
              color: Color.fromRGBO(143, 148, 162, 1),
              fontSize: 15.0,
            ),
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            color: Color.fromRGBO(74, 77, 84, 1),
            fontSize: 15.0,
          ),
        )
      ],
    ),
  );
}
