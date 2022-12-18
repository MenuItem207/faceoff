import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:flutter/material.dart';
import 'package:client/src/config.dart/text_styles.dart';

class DeviceStats extends StatelessWidget {
  const DeviceStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'Device Stats',
            style: TextStyles.textMedBold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Text(
                'Humidity: ',
                style: TextStyles.textTiny,
              ),
              ValueListenableBuilder<double?>(
                valueListenable: globalSocketController.humidityNotifier,
                builder: (context, humidity, child) => Text(
                  humidity == null ? '?' : humidity.toString(),
                  style: TextStyles.textTinyBold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Text(
                'Temperature: ',
                style: TextStyles.textTiny,
              ),
              ValueListenableBuilder<double?>(
                valueListenable: globalSocketController.temperatureNotifier,
                builder: (context, temperature, child) => Text(
                  temperature == null ? '?' : temperature.toString(),
                  style: TextStyles.textTinyBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
