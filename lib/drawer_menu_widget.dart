import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.realm,
    required this.selectedSchema,
    required this.onSchemaSelected,
  });

  final Realm realm;
  final ValueNotifier<SchemaObject?> selectedSchema;
  final VoidCallback onSchemaSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('CLASSES'),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: realm.schema.length,
              itemBuilder: (context, index) {
                final schema = realm.schema[index];
                final isSelected = selectedSchema.value == schema;

                return InkWell(
                  onTap: () {
                    selectedSchema.value = schema;
                    onSchemaSelected();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey.shade300 : null,
                      border: isSelected
                          ? const Border(
                              left: BorderSide(
                                color: Colors.deepPurple,
                                width: 10,
                              ),
                            )
                          : null,
                    ),
                    child: Text(schema.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
