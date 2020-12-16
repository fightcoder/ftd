library shake_handle_help;

/////对注解的处理
//Map<String,int> shakeHandleMapData = <String,int> {};
///// 普通事件的处理
//Map<String,int> operateBlackListMap = <String,int> {};


int preCallTime = 0;
///intervalTime 单位毫秒
bool isDoubleClick(int intervalTime,String tips){
  final int now = DateTime.now().millisecondsSinceEpoch;
  final int difTime = now - preCallTime;
  preCallTime = now;
  if(difTime > 100 && difTime < intervalTime){
//    print('使用注解click shake生效');
//    if(tips.isNotEmpty){
//    }
    return true;
  }
  return false;
}
