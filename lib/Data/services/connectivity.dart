import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  late bool _isConnected;
  late bool _showNoInternetMessage;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool get isConnected => _isConnected;

  bool get showNoInternetMessage => _showNoInternetMessage;

  ConnectivityService() {
    _isConnected = true;
    _showNoInternetMessage = false;

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _setDisconnected();
      } else {
        _setConnected();
      }
    });
  }

  void _setDisconnected() {
    _isConnected = false;
    _showNoInternetMessage = false;
    _connectivityController.add(false); // Notify listeners

    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _showNoInternetMessage = true;
        _connectivityController.add(true); // Notify listeners
      }
    });
  }

  void _setConnected() {
    _isConnected = true;
    _showNoInternetMessage = false;
    _connectivityController.add(true); // Notify listeners
  }

  void refresh() {
    _showNoInternetMessage = false;
    _connectivityController.add(_isConnected); // Notify listeners
  }

  void dispose() {
    _connectivityController.close();
  }
}

// class ConnectivityService {
//   late bool _isConnected;
//   late bool _showNoInternetMessage;
//
//   final StreamController<bool> _connectivityController =
//       StreamController<bool>.broadcast();
//
//   Stream<bool> get connectivityStream => _connectivityController.stream;
//
//   bool get isConnected => _isConnected;
//
//   bool get showNoInternetMessage => _showNoInternetMessage;
//
//   ConnectivityService() {
//     _isConnected =
//         true; // Set an initial value, you can set it to false if you prefer
//     _showNoInternetMessage = false;
//
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       if (result == ConnectivityResult.none) {
//         _isConnected = false;
//         _showNoInternetMessage = false;
//         _connectivityController.add(false); // Notify listeners
//         Future.delayed(Duration(seconds: 5), () {
//           if (!_isConnected) {
//             _showNoInternetMessage = true;
//             _connectivityController.add(true); // Notify listeners
//           }
//         });
//       } else {
//         _isConnected = true;
//         _showNoInternetMessage = false;
//         _connectivityController.add(true); // Notify listeners
//       }
//     });
//   }
//
//   void refresh() {
//     _showNoInternetMessage = false;
//     _connectivityController.add(_isConnected); // Notify listeners
//   }
//
//   void dispose() {
//     _connectivityController.close();
//   }
// }
