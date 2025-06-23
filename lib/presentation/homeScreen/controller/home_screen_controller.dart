import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:work_reader/core/data/apis/api_service.dart';
import '../../../widgets/flutter_toast.dart';

class HomeScreenController extends GetxController {
  bool firstScanDone = false;
  Timer? _nfcTimeoutTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  BuildContext? dialogContext;
  static const platform = MethodChannel('com.example.sebastian/nfc');

  String fixPolishCharacters(String input) {
    return input
        .replaceAll('Å', 'ł')
        .replaceAll('Å', 'Ł')
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ã“', 'Ó')
        .replaceAll('Ä™', 'ę')
        .replaceAll('Ä', 'Ę')
        .replaceAll('Ä…', 'ą')
        .replaceAll('Ä„', 'Ą')
        .replaceAll('Å›', 'ś')
        .replaceAll('Åš', 'Ś')
        .replaceAll('Åº', 'ź')
        .replaceAll('Å¹', 'Ź')
        .replaceAll('Å¼', 'ż')
        .replaceAll('Å»', 'Ż')
        .replaceAll('Å„', 'ń')
        .replaceAll('Åƒ', 'Ń')
        .replaceAll('Ä‡', 'ć')
        .replaceAll('Ä†', 'Ć');
  }

  Future<void> enableNfcReader() async {
    try {
      await platform.invokeMethod('enableNfcReader');
    } on PlatformException catch (e) {
      print("Failed to enable NFC reader: '${e.message}'.");
    }
  }

  Future<void> playSound(String assetPath) async {
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource(assetPath));
  }

  void startNFC(String actionType) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      Get.snackbar(
        'Błąd', // Error
        'NFC jest niedostępne', // NFC not available
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _startNfcSession(actionType);
  }

  void _startNfcSession(String actionType) {
    _nfcTimeoutTimer?.cancel();

    bool scanned = false;

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        if (scanned) return;
        scanned = true;

        _nfcTimeoutTimer?.cancel();

        try {
          final ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            await playSound('images/error_sound.mp3');
            Get.snackbar(
              'Błąd NFC', // NFC Error
              'NDEF jest pusty', // NDEF is null
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            await NfcManager.instance.stopSession();
            _restartSessionLater(actionType);
            return;
          }

          final records = ndef.cachedMessage!.records;
          final parsedData = records.map((record) {
            final payload = record.payload;
            final statusByte = payload[0];
            final langCodeLength = statusByte & 0x3F;
            final textBytes = payload.sublist(1 + langCodeLength);
            return utf8.decode(textBytes);
          }).toList();

          if (parsedData.length < 4) {
            await playSound('images/error_sound.mp3');
            Get.snackbar(
              'Błąd NFC', // NFC Error
              'Niekompletne dane karty', // Incomplete card data
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            await NfcManager.instance.stopSession();
            _restartSessionLater(actionType);
            return;
          }

          final name = parsedData[0];
          final surname = parsedData[1];
          String objectName = fixPolishCharacters(parsedData[2]);
          String birthYear = parsedData[3];
          final cardResponse = parsedData.join(", ");

          var res = await ApiService.postClockInOut(
            name: name,
            surname: surname,
            birthYear: birthYear,
            cardResponse: cardResponse,
            objectName: objectName,
            actionType: actionType,
          );

          // if (res != null && res is Map && res['success'] == true) {
          //   await playSound('images/success_sound.mp3');
          //   Get.snackbar("Success", 'Card scanned successfully',
          //       backgroundColor: Colors.green, colorText: Colors.white);
          // } else if (res != null && res['error'] != null) {
          //   await playSound('images/error_sound.mp3');
          //   Get.snackbar("Error", res['error'],
          //       backgroundColor: Colors.white, colorText: Colors.red);
          // } else {
          //   await playSound('images/error_sound.mp3');
          //   Get.snackbar('Error', 'Something went wrong',
          //       backgroundColor: Colors.white, colorText: Colors.red);
          // }

          if (res != null && res is Map && res['success'] == true) {
            await playSound('images/success_sound.mp3');
            Get.snackbar(
              "Sukces", // Success
              "Czas pracy został poprawnie zarejestrowany",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else if (res != null && res['error'] != null) {
            await playSound('images/error_sound.mp3');
            Get.snackbar(
              "Błąd", // Error
              _translateErrorMessage(res['error']),
              backgroundColor: Colors.white,
              colorText: Colors.red,
            );
          } else {
            await playSound('images/error_sound.mp3');
            Get.snackbar(
              'Błąd', // Error
              'Wystąpił błąd, spróbuj ponownie',
              backgroundColor: Colors.white,
              colorText: Colors.red,
            );
          }
          closeDialogIfOpen();
        } catch (e) {
          await playSound('images/error_sound.mp3');
          print("NFC scan error: $e");
        } finally {
          await NfcManager.instance.stopSession();
          _restartSessionLater(actionType);
        }
      },
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
    );
    // _nfcTimeoutTimer = Timer(const Duration(seconds: 30), () async {
    //   await NfcManager.instance.stopSession();
    //   closeDialogIfOpen();
    //   _restartSessionLater(actionType);
    // });
  }

  void _restartSessionLater(String actionType) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _startNfcSession(actionType);
    });
  }

  postApi(String name, String surname, String birthYear, String cardResponse,
      String objectName, String actionType) async {
    try {
      await ApiService.postClockInOut(
          name: name,
          surname: surname,
          birthYear: birthYear,
          cardResponse: cardResponse,
          objectName: objectName,
          actionType: actionType);
    } catch (e) {
      print("show catch block error----$e");
    } finally {
      print("finally block-----");
    }
  }

  @override
  void onClose() {
    _nfcTimeoutTimer?.cancel();
    super.onClose();
  }

  void simulateNfcScan(String session) async {
    await Future.delayed(const Duration(seconds: 0));

    String name = "SECOND";
    String surname = "CARD";
    String objectName = "Ikea Port";
    String birthYear = '1998';
    String cardResponse = "$name, $surname";

    // Call the API
    var res = await ApiService.postClockInOut(
      name: name,
      surname: surname,
      birthYear: birthYear,
      cardResponse: cardResponse,
      objectName: objectName,
      actionType: session,
    );

    // if (res != null && res is Map && res['success'] == true) {
    //   await playSound('images/success_sound.mp3');
    //   Get.snackbar("Success", 'Card scanned successfully',
    //       backgroundColor: Colors.green, colorText: Colors.white);
    // } else if (res != null && res['error'] != null) {
    //   await playSound('images/error_sound.mp3');
    //   Get.snackbar("Error", res['error'],
    //       backgroundColor: Colors.white, colorText: Colors.red);
    // } else {
    //   await playSound('images/error_sound.mp3');
    //   Get.snackbar('Error', 'Something went wrong',
    //       backgroundColor: Colors.white, colorText: Colors.red);
    // }
    if (res != null && res is Map && res['success'] == true) {
      await playSound('images/success_sound.mp3');
      Get.snackbar(
        "Sukces", // Success
        "Czas pracy został poprawnie zarejestrowany",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else if (res != null && res['error'] != null) {
      await playSound('images/error_sound.mp3');
      Get.snackbar(
        "Błąd", // Error
        _translateErrorMessage(res['error']),
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    } else {
      await playSound('images/error_sound.mp3');
      Get.snackbar(
        'Błąd', // Error
        'Wystąpił błąd, spróbuj ponownie', // Something went wrong
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    }
    closeDialogIfOpen();
  }

  void closeDialogIfOpen() {
    if (dialogContext != null) {
      Navigator.of(dialogContext!).pop();
      dialogContext = null;
    }
    stopAutoCloseTimer();
  }

  void setDialogContext(BuildContext context) {
    dialogContext = context;
    stopAutoCloseTimer();
    _nfcTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
        CustomToast.showToast('Skanowanie przekroczyło czas',
            color: Colors.red);
      }
    });
  }

  void stopAutoCloseTimer() {
    _nfcTimeoutTimer?.cancel();
    _nfcTimeoutTimer = null;
  }

  String _translateErrorMessage(String error) {
    switch (error) {
      case 'You must clock out before clocking in again.':
        return 'Wejście jest już aktywne. Musisz najpierw zgłosić wyjście, by ponownie zarejestrować wejście.';
      case 'You must clock in before clocking out.':
        return 'Wyjście jest już aktywne. Musisz najpierw zgłosić wejście, by ponownie zarejestrować wyjście.';
      default:
        return 'Wystąpił błąd, spróbuj ponownie';
    }
  }
}
