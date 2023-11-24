import 'package:async/src/cancelable_operation.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:delta_scheduler/scheduler/scheduler.dart';
import 'package:venice_core/network/message.dart';

class SchedulerImplementation extends Scheduler {
  SchedulerImplementation(super.bootstrapChannel);

  @override
  Future<void> sendMessages(List<VeniceMessage> messages, List<DataChannel> channels, Map<int, CancelableOperation> resubmissionTimers) async {
    while (messages.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (messages.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        // TODO remove await
        await sendMessage(messages.removeAt(0), channels[0]);
      }
    }
  }
}