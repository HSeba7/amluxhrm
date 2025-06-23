import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_reader/core/utils/size_utils.dart';
import 'package:work_reader/presentation/homeScreen/controller/home_screen_controller.dart';
import '../../core/utils/image_constants.dart';
import '../../theme/custom_text_style.dart';
import '../../theme/theme_helper.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.isRegistered<HomeScreenController>()
        ? Get.find<HomeScreenController>()
        : Get.put(HomeScreenController());
    return GetBuilder<HomeScreenController>(
      builder: (controller) => Scaffold(
        body: Column(
          children: [
            Container(
              height: 140.v,
              width: double.infinity,
              color: theme.colorScheme.primary,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "lbl_work_time_reader".tr,
                        style: CustomTextStyles.appBarText.copyWith(),
                      ),
                      Builder(
                        builder: (context) {
                          final textDirection = Directionality.of(context);
                          final textWidth = (TextPainter(
                            text: TextSpan(
                              text: "lbl_work_time_reader".tr,
                              style: CustomTextStyles.appBarText,
                            ),
                            maxLines: 1,
                            textDirection: textDirection,
                          )..layout())
                              .size
                              .width;
                          return SizedBox(
                            width: textWidth,
                            child: Divider(
                              color: appTheme.appWhite,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: clockInOutButton(),
              ),
            ),
            Image(
              image: const AssetImage(ImageConstants.ambluxIcon),
              height: 100.v,
            ),
            SizedBox(
              height: 30.v,
            )
          ],
        ),
      ),
    );
  }

  Widget clockInOutButton() {
    return GetBuilder<HomeScreenController>(
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  scanBottomSheet('clock_in');
                },
                child: Container(
                  height: 100.v,
                  color: appTheme.appGreen,
                  child: Center(
                    child: Text("lbl_entry".tr,
                        style: CustomTextStyles.appBarText),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.h),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  scanBottomSheet('clock_out');
                },
                child: Container(
                  height: 100.v,
                  color: theme.colorScheme.primary,
                  child: Center(
                    child:
                        Text("lbl_exit".tr, style: CustomTextStyles.appBarText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future scanBottomSheet(String actionType) {
    return showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        controller.setDialogContext(context);
        Future.delayed(const Duration(milliseconds: 0), () {
          final controller = Get.find<HomeScreenController>();
          controller.startNFC(actionType);
          // controller.simulateNfcScan(actionType);
        });

        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: const AssetImage(ImageConstants.scanNfcImage),
                    height: 128.v,
                    width: 123.59.h,
                  ),
                  SizedBox(height: 20.v),
                  Text("lbl_ready_to_scan".tr,
                      style: CustomTextStyles.buttonText),
                  SizedBox(height: 15.v),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Container(
                        height: 46.v,
                        width: 310.h,
                        decoration: BoxDecoration(
                          color: appTheme.greyEF,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            "lbl_cancel".tr,
                            style: CustomTextStyles.poppinsText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.v),
                  Text(
                    "lbl_hold_the_nfc".tr,
                    style: CustomTextStyles.buttonText.copyWith(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
