import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_fishapp/api/api_client.dart';
import 'package:ai_fishapp/services/token_storage.dart';

class TankRegister extends StatefulWidget {
  const TankRegister({super.key});

  @override
  State<TankRegister> createState() =>
      _TankRegisterState();
}

class _TankRegisterState extends State<TankRegister> {
  final tankName = TextEditingController();
  final minTempController = TextEditingController();
  final maxTempController = TextEditingController();
  final minWaterController = TextEditingController();
  final maxWaterController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    tankName.dispose();
    minTempController.dispose();
    maxTempController.dispose();
    minWaterController.dispose();
    maxWaterController.dispose();
    super.dispose();
  }

  Future<void> saveTank() async {
    // 입력하지 않은 항목은 기본값 적용
    final deviceId = tankName.text.trim().isEmpty
        ? 'SS501'
        : tankName.text.trim();

    final minTemp =
        double.tryParse(minTempController.text.trim()) ?? 23.0;

    final maxTemp =
        double.tryParse(maxTempController.text.trim()) ?? 26.0;

    final normalWater =
        int.tryParse(minWaterController.text.trim()) ?? 250;

    final warningWater =
        int.tryParse(maxWaterController.text.trim()) ?? 700;

    // 최저값과 최고값 확인
    if (minTemp >= maxTemp || normalWater >= warningWater) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최저값은 최고값보다 작아야 합니다.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await ApiClient.post(
        '/api/tank/setting',
        jsonEncode({
          'device_id': deviceId,
          'min_temp': minTemp,
          'max_temp': maxTemp,
          'normal_waterquality': normalWater,
          'warning_waterquality': warningWater,
        }),
        token: true,
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        await TokenStorage.savedeviceId(data['device_id']);

        if (!mounted) return;
        Navigator.pop(context, true);
      } /*else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 등록된 기기입니다.'),
          ),
        );
      }*/ else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? '어항 등록에 실패했습니다.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('어항 등록 중 오류가 발생했습니다: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('어항 등록'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tankName,
              decoration: const InputDecoration(
                labelText: '어항 시리얼 넘버',
              ),
            ),
            TextField(
              controller: minTempController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '최저 수온',
                hintText: '기본값: 23.0',
              ),
            ),
            TextField(
              controller: maxTempController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '최고 수온',
                hintText: '기본값: 26.0',
              ),
            ),
            TextField(
              controller: minWaterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '최저 수질',
                hintText: '기본값: 250',
              ),
            ),
            TextField(
              controller: maxWaterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '최고 수질',
                hintText: '기본값: 700',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveTank,
          child: Text(isSaving ? '등록 중...' : '등록'),
        ),
      ],
    );
  }
}