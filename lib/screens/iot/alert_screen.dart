
import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/alert.dart';
import '../../services/alert_service.dart';
import '../../api/sensor_api.dart';
import '../../services/token_storage.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  late Future<List<AlertModel>> alertsFuture;
  StreamSubscription? sseSubscription;

  Future<void> refreshAlerts() async {
    setState(() {
      alertsFuture = AlertService.getAlerts();
    });
  }

  @override
  void initState() {
    super.initState();

    alertsFuture = AlertService.getAlerts();

    sseSubscription =
        SensorApi().connect('/api/tank/data').listen((event) {
      if (event["type"] == "warning") {
        setState(() {
          alertsFuture = AlertService.getAlerts();
        });
      }
    });
  }

  @override
  void dispose() {
    sseSubscription?.cancel();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "오늘";
    }

    return "${date.year}.${date.month}.${date.day}";
  }

  IconData getIcon(String type) {
    switch (type) {
      case "temp":
        return Icons.thermostat;
      case "waterquality":
        return Icons.water_drop;
      default:
        return Icons.notifications_none;
    }
  }

  Color getIconColor(AlertModel item) {
    if (item.type == "temp") {
      if (item.status == "low") {
        return Colors.lightBlue.shade300;
      }
      if (item.status == "high") {
        return Colors.red.shade300;
      }
    }

    if (item.type == "waterquality") {
      return Colors.orange.shade300;
    }

    return Colors.grey;
  }

  Color getIconBackgroundColor(AlertModel item) {
    if (item.type == "temp") {
      if (item.status == "low") {
        return Colors.lightBlue.shade50;
      }
      if (item.status == "high") {
        return Colors.red.shade50;
      }
    }

    if (item.type == "waterquality") {
      return Colors.orange.shade50;
    }

    return const Color(0xFFF2F3F5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "알림",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: FutureBuilder<List<AlertModel>>(
        future: alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return const Center(
              child: Text("알림이 없습니다."),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 16,
                  bottom: 12,
                ),
                child: Text(
                  "새로운 알림",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshAlerts,
                  child: ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final item = alerts[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    getIconBackgroundColor(item),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: Icon(
                                getIcon(item.type),
                                color: getIconColor(item),
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    formatDate(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
