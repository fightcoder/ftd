## Flutter Dill Transform

提供多个简单实用的注解供Flutter开发、调试，提高开发效率，解决你的烦恼。



### 使用方法：

1. 直接将该项目作为本地库依赖

2. 对`flutter tools`进行patch,在Flutter仓库目录下执行:`git apply --3way [ft-dill-transform-patch.patch]路径`

   - for Windows :

     ![image-20201214145517042](C:\Users\wangziyang\AppData\Roaming\Typora\typora-user-images\image-20201214145517042.png)

   - for Mac:

     ![img](file:///C:/Users/wangziyang/Documents/WXWork/1688853443812878/Cache/Image/2020-12/5c89231c-9717-4cbd-9554-06abcc3193f3.png)



3. 删除`flutter/bin/cache/flutter_tools.stamp`,执行`flutter doctor -v`



### 目前实现的功能：

### 1.ClickShake注解，作用于方法：

实现Flutter防多次点击、防抖动功能。可自己设置有效间隔时间，默认间隔时间是200ms。

```dart
@ClickShake(intervalTime = 300)
testClick()async{
  print('testCost1');
}
```

### 2.FunctionLog注解，作用于方法：

提供更简单的方式打印方法耗时，参数、返回值等。

```dart
@FunctionLog()
void _incrementCounter(String p1,int p2){
  //to do something...
}
//输出
//--> _incrementCounter(String p1 = xx int p2 = xx)
//<-- _incrementCounter cost time(耗时) = xx[ms]
```

### 3.实现中...



因个人精力有限，如果你有好的想法或者期待实现的功能，请提交PR或者联系我，我看到会尽快处理，希望大家能一起发挥想象力，利用Dill Transform实现更多的功能！



**注意：暂时与Aspectd不能两者完全兼容，需要自己下载源码修改兼容。**

**Thanks Aspectd : https://github.com/alibaba-flutter/aspectd**