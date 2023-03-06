import 'package:async/src/cancelable_operation.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/file/file_chunk.dart';
import 'package:delta_scheduler/scheduler/scheduler.dart';

class SchedulerImplementation extends Scheduler {
  SchedulerImplementation(super.bootstrapChannel);

  @override
  Future<void> sendChunks(List<FileChunk> chunks, List<DataChannel> channels, Map<int, CancelableOperation> resubmissionTimers) async {
    while (chunks.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (chunks.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        sendChunk(chunks.removeAt(0), channels[0]);
      }
    }
  }
}