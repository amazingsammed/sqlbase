part of 'package:sqlbase/src/feature/table/sqltable.dart';


// extension SqlTableRead on SqlTable{
//   Future<SqlBaseResponse> get() async {
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'key': key,
//           'action': 'TABLE-GET',
//           'table': tableName,
//           'conditions': jsonEncode(_filterList),
//         },
//       );
//       return phpResponse(response);
//     } catch (e) {
//       Exception(e);
//       return SqlBaseResponse(statusCode: 0, error: "Something went wrong");
//     }
//   }
// }

extension SqlTableRead on SqlTable {
  Future<SqlBaseResponse> get() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'key': key,
          'action': 'TABLE-GET',
          'table': tableName,
          'conditions': jsonEncode(_filterList.isEmpty ? null : _filterList),
        },
      );

      return phpResponse(response);
    } catch (e, stackTrace) {
      // Optional: Print or log the error and stackTrace
      debugPrint('SqlTable.get() error: $e');
      debugPrintStack(stackTrace: stackTrace);

      return SqlBaseResponse(
        statusCode: 0,
        error: "Something went wrong while fetching data",
      );
    }
  }
}