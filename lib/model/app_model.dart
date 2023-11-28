import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  BootstrapChannelType _bootstrapChannelType;
  final List<DataChannelType> _dataChannelTypes;

  AppModel()
    : _bootstrapChannelType = BootstrapChannelType.qrCode,
      _dataChannelTypes = [];

  set bootstrapChannelType(BootstrapChannelType type) {
    _bootstrapChannelType = type;
    notifyListeners();
  }
  BootstrapChannelType get bootstrapChannelType {
    return _bootstrapChannelType;
  }

  List<DataChannelType> get dataChannelTypes {
    return _dataChannelTypes;
  }
  void addDataChannelType(DataChannelType type) {
    _dataChannelTypes.add(type);
    notifyListeners();
  }
  void removeDataChannelType(DataChannelType type) {
    _dataChannelTypes.remove(type);
    notifyListeners();
  }
}