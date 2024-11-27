import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class SchemaDataTable extends StatelessWidget {
  const SchemaDataTable({
    super.key,
    required this.schema,
    required this.dataSource,
  });

  final SchemaObject schema;
  final DataTableSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: PaginatedDataTable(
            source: dataSource,
            dataRowHeight: 32,
            header: Text(schema.name),
            rowsPerPage: 10,
            columns: schema.map((property) {
              return DataColumn(
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      property.primaryKey
                          ? '${property.propertyType.name} (Primary Key)'
                          : property.optional
                              ? '${property.propertyType.name}?'
                              : property.propertyType.name,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
