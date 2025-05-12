import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:realm_studio_manager/drawer_menu_widget.dart';
import 'package:realm_studio_manager/schema_data_tables.dart';
import 'package:realm_studio_manager/search_bar_widget.dart';

class RealmStudioManager extends StatefulWidget {
  const RealmStudioManager({
    super.key,
    required this.realm,
  });
  final Realm realm;

  @override
  State<RealmStudioManager> createState() => _RealmStudioManagerState();
}

class _RealmStudioManagerState extends State<RealmStudioManager> {
  final ValueNotifier<SchemaObject?> selectedSchema = ValueNotifier(null);
  List<Map<String, dynamic>> resultList = [];
  final TextEditingController _searchController = TextEditingController();
  final FSMDataSource _dataSource = FSMDataSource();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  void _findAll() {
    if (selectedSchema.value == null) return;
    final schema = selectedSchema.value!;
    final results = widget.realm.dynamic.all(schema.type.toString());

    final List<Map<String, dynamic>> tempResult = results.map((data) {
      final Map<String, dynamic> item = {};
      for (final property in data.objectSchema) {
        try {
          item[property.name] = data.dynamic.get(property.name);
        } catch (e) {
          try {
            item[property.name] = data.dynamic.getList(property.name);
          } catch (e) {
            item[property.name] = data.dynamic.getMap(property.name).toEJson();
          }
        }
      }
      return item;
    }).toList();

    setState(() {
      resultList = tempResult;
    });

    _updateDataSource(tempResult);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    final filtered = resultList.where((item) {
      return item.values
          .any((value) => value.toString().toLowerCase().contains(query));
    }).toList();

    _updateDataSource(filtered);
  }

  void _updateDataSource(List<Map<String, dynamic>> data) {
    final List<List<String>> formattedData = data.map((row) {
      return row.values.map((value) => value.toString()).toList();
    }).toList();

    _dataSource.addData(formattedData);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SchemaObject?>(
      valueListenable: selectedSchema,
      builder: (context, selected, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: const Text('Realm Studio Manager'),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: DrawerMenu(
            realm: widget.realm,
            selectedSchema: selectedSchema,
            onSchemaSelected: _findAll,
          ),
          backgroundColor: Colors.grey.shade100,
          body: selected == null
              ? const Center(child: Text('No schema selected'))
              : SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SearchBarWidget(controller: _searchController),
                      SchemaDataTable(
                        schema: selected,
                        dataSource: _dataSource,
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
        );
      },
    );
  }
}

class FSMDataSource extends DataTableSource {
  final List<List<String>> _data = [];

  addData(List<List<String>> data) {
    _data.clear();
    _data.addAll(data);
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    return DataRow(
      cells: _data[index].map((cell) {
        return DataCell(Text(cell));
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
