import 'package:ble_bootstrap_channel/ble_bootstrap_channel.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

/// State of the application.
///
/// An instance of this class is shared throughout app widgets, which allows
/// them to be rebuild when a property of the instance is updated (*i.e.* a new
/// channel is selected): to serve this purpose, all class properties are
/// private, and have setters notifying widgets tree when they're updated.
class AppModel extends ChangeNotifier {
  /// Type of the bootstrap channel. Only one is required by the framework.
  BootstrapChannelType _bootstrapChannelType;

  /// Data channel types. Framework requires at least one of them to be able to
  /// exchange data between peers.
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

  /// Returns a bootstrap channel instance that matches the currently selected
  /// channel, and can be used in data exchanges.
  BootstrapChannel getBootstrapChannel(BuildContext context) {
    BootstrapChannel bootstrapChannel;
    switch(bootstrapChannelType) {
      case BootstrapChannelType.qrCode:
        bootstrapChannel = QrCodeBootstrapChannel(context);
        break;
      case BootstrapChannelType.ble:
        bootstrapChannel = BleBootstrapChannel(context);
        break;
      default:
        throw UnimplementedError("Bootstrap channel not initialized.");
    }
    return bootstrapChannel;
  }

  /// Returns an array of data channels that matches the currently selected
  /// channels, and can be used in data exchanges.
  List<DataChannel> getDataChannels(BuildContext context) {
    List<DataChannel> channels = [];

    for (var type in dataChannelTypes) {
      switch(type) {
        case DataChannelType.wifi:
          channels.add( WifiDataChannel("wifi_data_channel") );
          break;
      }
    }

    return channels;
  }
}