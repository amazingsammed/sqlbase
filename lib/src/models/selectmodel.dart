

class Select{
  final String name;
  final String? as;
  const Select(this.name,{this.as});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'as': as??name,
    };
  }

  factory Select.fromMap(Map<String, dynamic> map) {
    return Select(
       map['name'] as String,
      as: map['as'] as String,
    );
  }
}

extension Selectmodel on List<Select>{

  List<Map>toMap(){
    var data = <Map>[];
    for (var action in this) {
      data.add(action.toMap());
    }
    return data;
  }
}