 mixin BaseJsonModel<T>{
  Map<String,dynamic> toJson();
}

mixin BaseDbModel{
  bool _exist = true;

  bool exist({bool? exist}){
    if(exist != null){
      _exist = exist;
    }
    return _exist;
  }
}