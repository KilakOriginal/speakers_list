import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'name_item.dart';
import '../providers/name_provider.dart';

class NameList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NameProvider>(
      builder: (context, nameProvider, child) {
        return ListView.builder(
          itemCount: nameProvider.names.length,
          itemBuilder: (context, index) {
            return NameItem(nameProvider.names[index]);
          },
        );
      },
    );
  }
}