

class ReflectUtils{


  dynamic getTargetPrivatePropertyByObject(dynamic obj,{String fieldName}){
    return obj.getPrivateField(fieldName);
  }

  dynamic getAllFields(dynamic obj){
    return obj.getFields();
  }

  void setField(dynamic obj,String fieldName,dynamic newValue){
    obj.setField(fieldName,newValue);
  }
}