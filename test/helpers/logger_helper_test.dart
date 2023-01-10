import 'package:test/test.dart';
import 'package:x_action_cable/helpers/logger.helper.dart';

void main() {
  test('Should log message', () {
    ActionLoggerHelper.isActivated = true;
    final message = {'test': 'test'};
    final response = ActionLoggerHelper.log(message);
    expect(message.toString(), response);
  });
}
