import 'package:flutter_test/flutter_test.dart';
import 'package:movie_vault/core/constants/app_colors.dart';

void main() {
  test('AppColors expose les couleurs de statut', () {
    expect(AppColors.primary.value, isNot(0));
    expect(AppColors.success.value, isNot(0));
    expect(AppColors.error.value, isNot(0));
    expect(AppColors.offline.value, isNot(0));
  });
}
