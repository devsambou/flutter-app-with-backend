import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_vault/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    connectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(connectivity);
  });

  test('isConnected retourne false sans connexion', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.none]);

    expect(await networkInfo.isConnected, isFalse);
  });

  test('isConnected retourne true avec une connexion', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);

    expect(await networkInfo.isConnected, isTrue);
  });

  test('onConnectivityChanged traduit les changements', () async {
    when(() => connectivity.onConnectivityChanged).thenAnswer(
      (_) => Stream<List<ConnectivityResult>>.fromIterable([
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
      ]),
    );

    await expectLater(
      networkInfo.onConnectivityChanged,
      emitsInOrder([false, true]),
    );
  });
}
