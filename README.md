### Flutter Dill Transform

提供多个实用的注解以供开发。

#### 1.ClickShake注解，作用于方法：

实现防多次点击、防抖动功能。

```dart
@ClickShake()
testClick()async{
  print('testCost1');
}
```

#### 2.FunctionLog注解，作用于方法：

打印方法耗时，参数等等。

```dart
@FunctionLog()
void _incrementCounter(String p1,int p2){
}
//输出
//--> _incrementCounter(String p1 = p1int p2 = 2)
//<-- _incrementCounter cost time(耗时) = 0[ms]
```

使用方法：

1. 直接将该项目作为本地库依赖
2. 对`flutter tools`进行patch



暂时与Aspectd不能两者完全兼容，需要自己下载源码修改兼容。

Thanks Aspectd : https://github.com/alibaba-flutter/aspectd