

class SqlMap {
  final String type;
  final String field;
  final String function;
  dynamic value;

//<editor-fold desc="Data Methods">
  SqlMap({
     this.type = 'where',
    required this.field,
    required this.function,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SqlMap &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          field == other.field &&
          function == other.function &&
          value == other.value);

  @override
  int get hashCode =>
      type.hashCode ^ field.hashCode ^ function.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'SqlMap{' +
        ' type: $type,' +
        ' field: $field,' +
        ' function: $function,' +
        ' value: $value,' +
        '}';
  }

  SqlMap copyWith({
    String? type,
    String? field,
    String? function,
    dynamic? value,
  }) {
    return SqlMap(
      type: type ?? this.type,
      field: field ?? this.field,
      function: function ?? this.function,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'field': field,
      'function': function,
      'value': value,
    };
  }

  factory SqlMap.fromMap(Map<String, dynamic> map) {
    return SqlMap(
      type: map['type'] as String,
      field: map['field'] as String,
      function: map['function'] as String,
      value: map['value'] as dynamic,
    );
  }

//</editor-fold>
}