import 'package:example/status_card.dart';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';

Padding buildHostsListView(Set<DeviceAddress> hosts) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: hosts.length,
      itemBuilder: (context, index) {
        DeviceAddress currData = hosts.elementAt(index);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ListTile(
              leading: StatusCard(
                color: currData.exists ? Colors.greenAccent : Colors.redAccent,
                text: currData.exists ? "Online" : "Offline",
              ),
              title: Text(currData.ip ?? "N/A")),
        );
      },
    ),
  );
}
