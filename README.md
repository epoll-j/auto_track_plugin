# Auto_Track_Plugin

> Flutter全埋点插件，支持 Android 和 iOS

低侵入全局自动埋点，自动记录页面进入、退出，点击、滑动等事件，并支持自定义事件。


## Getting Started 使用指南

只需在入口配置`AutoTrack().config()`即可启用全局埋点

目前仅在移动端验证通过，其他平台暂无验证。

### Installation 安装

```dart
flutter pub add auto_track
```

### Usage example 使用示例

可直接运行项目中的 example

#### 主要配置

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AutoTrack()
        .config(AutoTrackConfig( // 其余配置可查看AutoTrackConfig类
            samplingRate: 0.9, // 采样率
            host: 'http://localhost:3000/api/track',
            eventHandler: (model) => {
              // 事件触发会调用此方法，可自行处理
              print('event handler ${model.type}')
            },
            pageConfigs: [
            AutoTrackPageConfig<PageA>(
                pageID: 'page_a', // 配置页面ID，统计时可基于此ID进行统计
            ),
            AutoTrackPageConfig<CupertinoScaffold>( 
                pageID: 'home_tab_page',
                isPageWidget: (page) { // 页面匹配是基于泛型匹配，如果是被其他widget包裹的，需要自行判断
                    if (page.key != null) {
                        if (page.key is ValueKey) {
                            return (page.key! as ValueKey).value == 'home_tab_page';
                        }
                    }
                    return false;
                }
            )
        ]))
        .enable()
        .enableUpload() // 启用数据上传，需设置host
        .enablePageLeave() // 启用页面离开统计
        .enablePageView() // 启用页面进入统计
        .enableClick() // 启用点击统计
        .enableDrag() // 启用滑动统计
        .enableIgnoreNullKey() // 忽略空的key，如果不忽略，没有配置key的页面或事件会基于一定的规则生成一个随机的key进行上报统计
        .enableLog(); // 启用日志，建议在debug模式下开启，会打印一些埋点相关的日志

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('auto track example app'),
        ),
        body: const Center(
          child: Home(),
        ),
      ),
      navigatorObservers: AutoTrackNavigationObserver.wrap([]), // 需要使用AutoTrackNavigationObserver.wrap去包裹当前使用的navigatorObservers
    );
  }
}

```
##### 更新采样率
```dart
AutoTrack().updateSampleRate(0.5);
```
##### 登录后更新用户id
```dart
AutoTrack().updateUserId('userId'); 
```
##### 采样错误信息
```dart
FlutterError.onError = (details) {
  Track.instance.reportError(details, details.stack!);
};
```

#### 具体使用
```dart
import 'package:flutter/cupertino.dart';

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 200),
      child: Column(
        children: [
          GestureDetector(  // 如果启用了enableIgnoreNullKey，这里没有配置key的点击事件不会进行记录统计
            onTap: () {
              print("tap page a null key");
            },
            child: const Text('null key'),
          ),
          GestureDetector(
            key: const Key('page-a-click'),
            onTap: () {
              print("tap page a");
              Track.instance.customEvent('custom_event',
                  {'other_param': 'param'}); // 自定义事件发送
            },
            child: const Text('have key'),
          )
        ],
      ),
    );
  }
}

```

### Data upload 数据上报

#### 配置host并启用数据上报后会定时上报数据

##### 数据上报的格式
```
{
    'app_key': config.appKey ?? '',
    'signature': config.signature!(t), // 签名，可自行配置具体实现的签名算法
    't': t, // 时间戳
    'user_id': config.userId ?? '', // 用户id，用户登录后设置，调用AutoTrack().updateUserId('userId');
    'track_id': config.trackId ?? '', // track_id，每次用户重新打开app会重新生成，在同一个周期内（app打开到关闭）track_id是相同的
    'unique_id': config.uniqueId ?? AutoTrackConfigManager.instance.deviceId, // unique_id，可自行配置，如果不配置，会使用设备id
    'device_id': AutoTrackConfigManager.instance.deviceId, // 设备id，根据deviceInfo获取
    'data_list': uploadList.map((e) => e.toMap()).toList(), // TrackModel数据列表，具体格式参考下方
    'app_version': AutoTrackConfigManager.instance.appVersion, // app版本
    'device_info': AutoTrackConfigManager.instance.deviceInfo // 设备信息
}
```

```
// TrackModel
{
    'type': type, //事件类型 page_view | page_leave | click | drag | custom（自定义类型）
    'key': key, // 事件key，如果没有启用enableIgnoreNullKey，没有配置key的地方会基于一定的规则生成一个随机的key
    'time': time, // 事件触发的时间戳
    'params': params, // 事件参数，自定义事件可自行设置参数，页面进入、离开、点击、滑动等事件会自动设置（点击位置、滑动方向、页面停留时间等相关信息）
}

```
