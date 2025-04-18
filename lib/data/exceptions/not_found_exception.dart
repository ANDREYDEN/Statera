class EntityNotFoundException<T> {
  final String? id;
  final String? name;

  EntityNotFoundException(this.id, {this.name}) {
    assert(name != null || T != dynamic, 'Provide either name or type');
  }

  @override
  String toString() {
    return '${name ?? T.toString()} (ID: $id) does not exist';
  }
}
