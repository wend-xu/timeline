 mixin BaseJsonModel<T>{
  Map<String,dynamic> toJson();
}

mixin BaseDbModel<T>{
  final String columnDelStatus = "delStatus";

  bool _exist = true;

  bool exist({bool? exist}){
    if(exist != null){
      _exist = exist;
    }
    return _exist;
  }

  T objNotExistAsT(){
    exist(exist: false);
    return this as T;
  }
}