// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  test('Can set value during status callback', () {
    WidgetsFlutterBinding.ensureInitialized();
    AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100)
    );
    bool didComplete = false;
    bool didDismiss = false;
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        didComplete = true;
        controller.value = 0.0;
        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        didDismiss = true;
        controller.value = 0.0;
        controller.forward();
      }
    });

    controller.forward();
    expect(didComplete, isFalse);
    expect(didDismiss, isFalse);
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 1));
    expect(didComplete, isFalse);
    expect(didDismiss, isFalse);
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 2));
    expect(didComplete, isTrue);
    expect(didDismiss, isTrue);

    controller.stop();
  });

  test('Receives status callbacks for forward and reverse', () {
    WidgetsFlutterBinding.ensureInitialized();
    AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100)
    );
    List<double> valueLog = <double>[];
    List<AnimationStatus> log = <AnimationStatus>[];
    controller
      ..addStatusListener((AnimationStatus status) {
        log.add(status);
      })
      ..addListener(() {
        valueLog.add(controller.value);
      });

    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward, AnimationStatus.dismissed]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward, AnimationStatus.dismissed]));
    expect(valueLog, equals(<AnimationStatus>[]));

    log.clear();
    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();
    log.clear();

    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 10));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 20));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 30));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 40));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.stop();
  });

  test('Forward and reverse from values', () {
    WidgetsFlutterBinding.ensureInitialized();
    AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100)
    );
    List<double> valueLog = <double>[];
    List<AnimationStatus> statusLog = <AnimationStatus>[];
    controller
      ..addStatusListener((AnimationStatus status) {
        statusLog.add(status);
      })
      ..addListener(() {
        valueLog.add(controller.value);
      });

    controller.reverse(from: 0.2);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse ]));
    expect(valueLog, equals(<double>[ 0.2 ]));
    expect(controller.value, equals(0.2));
    statusLog.clear();
    valueLog.clear();

    controller.forward(from: 0.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.dismissed, AnimationStatus.forward ]));
    expect(valueLog, equals(<double>[ 0.0 ]));
    expect(controller.value, equals(0.0));
  });

  test('Can fling to upper and lower bounds', () {
    WidgetsFlutterBinding.ensureInitialized();
    AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100)
    );

    controller.fling();
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 1));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 2));
    expect(controller.value, 1.0);
    controller.stop();

    AnimationController largeRangeController = new AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: -30.0,
      upperBound: 45.0
    );

    largeRangeController.fling();
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 3));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 4));
    expect(largeRangeController.value, 45.0);
    largeRangeController.fling(velocity: -1.0);
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 5));
    WidgetsBinding.instance.handleBeginFrame(const Duration(seconds: 6));
    expect(largeRangeController.value, -30.0);
    largeRangeController.stop();
  });
}
