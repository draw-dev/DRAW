
import 'dart:io';

import 'package:test/test.dart';
import 'package:draw/src/drawConfigContext.dart';
import 'package:draw/src/exceptions.dart';

main(){
  test('Tests Initialization of Constructor', () {
    var configContext = new DRAWConfigContext();
    expect(configContext is Object, equals(true));
  });
}
