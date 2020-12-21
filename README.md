## Flutter Dill Transform

提供多个简单实用的注解供Flutter开发、调试，提高开发效率，解决你的烦恼。



### 使用方法：

1. 直接将该项目作为本地库依赖

2. 对`flutter tools`进行patch,在Flutter仓库目录下执行:`git apply --3way [ft-dill-transform-patch.patch]路径`

   - for Windows :

     ![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/423dc89c0f354017b89ea405b28f765a~tplv-k3u1fbpfcp-watermark.image)

   - for Mac:

     ![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e15e7275de5f4bd08c08252c4a9ac975~tplv-k3u1fbpfcp-watermark.image)



3. 删除`flutter/bin/cache/flutter_tools.stamp`,执行`flutter doctor -v`



### 目前实现的功能：

### 1.ClickShake注解，作用于方法：

实现Flutter防多次点击、防抖动功能。可自己设置有效间隔时间，默认间隔时间是200ms。

如果依赖了该库且执行了以上1-3步，那么默认情况下是支持所有通过`GestureRecognizer`实现的可点击的组件的，并且只会对其中的`onTap`、`onTapDown`、`onDown`这三个行为单击行为做防多次点击处理，不会影响其他点击行为。

```dart
GestureDetector(
  onTapDown:(_){
      print('onTapDown');//快速点击只会调用一次
  }
)

```

另外，为了补充上述情况的其他行为操作（例如Listener、自定义的行为），提供`ClickShake`注解，能对特定的方法进行处理。

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

### 3.更多实现中...



因个人精力有限，如果你有好的想法或者期待实现的功能，又或者你能花费自己宝贵的时间提供更优秀的代码，请提交PR或者联系我，我看到会尽快处理，希望大家能一起发挥想象力，利用Dill Transform实现更多的功能！



**注意：暂时与Aspectd不能两者完全兼容，需要自己下载源码修改兼容。**

**Thanks Aspectd : **

**https://github.com/alibaba-flutter/aspectd**