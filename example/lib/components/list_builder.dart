// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lan_scanner/lan_scanner.dart';

// Project imports:
import 'status_card.dart';

Padding buildHostsListView(Set<HostModel> hosts) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: hosts.length,
      itemBuilder: (context, index) {
        HostModel currData = hosts.elementAt(index);

        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ListTile(
            leading: const StatusCard(
              color: Colors.greenAccent,
              text: "Online",
            ),
            title: Text(currData.ip),
          ),
        );
      },
    ),
  );
}
