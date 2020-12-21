## Flutter Transform  Dill

提供多个简单实用的注解供Flutter开发、调试，提高开发效率，也是学习dill操作的经典案例。

**目前支持Flutter版本：v1.22.3/v1.22.4**

### 使用方法：

1. 直接将该项目作为本地库依赖

2. 对`flutter tools`进行patch,在Flutter仓库目录下执行:`git apply --3way [ft-dill-transform-patch.patch]路径`

   - for Windows :

     ![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/423dc89c0f354017b89ea405b28f765a~tplv-k3u1fbpfcp-watermark.image)

   - for Mac:

     ![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e15e7275de5f4bd08c08252c4a9ac975~tplv-k3u1fbpfcp-watermark.image)



3. 删除`flutter/bin/cache/flutter_tools.stamp`,执行`flutter doctor -v`

之所以是需要以上的步骤是因为Flutter本身没有提供对Flutter tools构建的hook接口，也没有开放其内部transform的流程，不过在flutter的官网issue中有提到这部分的讨论，我相信官方不久的将来也会支持这个功能，那个时候肯定也能以很低的成本将目前的dill转换功能迁移适配。

另外，接入的过程主要耗时估计在对Flutter版本的升级，以及对Dart sdk完整源码的依赖上，第一次最好在网络好的情况下进行。



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

### 3.更多实现中(模块化的方法统计打印？代码生成支持支持获取修改私有属性？)...



因个人精力有限，如果你有好的想法或者期待实现的功能，又或者你能花费自己宝贵的时间提供更优秀的代码，请提交PR或者联系我，我看到会尽快处理，希望大家能一起发挥想象力，利用Dill Transform实现更多的功能！

### 如何调试验证：

如果你需要调试本项目的代码，又或者是想自己调试验证开发自己的transform是否正确，可通过以下两步骤：

- 在`start.dart`中Debug `start.dart`，此处需要自行补充`args`参数
- 生成的dill文件验证与否符合预期，在完整的Dart SDK目录下，进入`pkg/vm/bin`,通过命令`dart dump_kernel.dart [已经生成的dill文件路径] [转化后的.txt文件]`

在调试验证过程中，也可能会遇到一些莫名的问题，如果你**仔细思考与实践**后还无法解决，可在`issue`区讨论或者联系我：`coderwangzi@163.com`。

**注：暂时与Aspectd不能两者完全兼容，需要自己下载源码修改兼容。**

**Thanks Aspectd:https://github.com/alibaba-flutter/aspectd**
