# 短书JSSDK API v2.3说明

## 变更内容
- 新增DuanshuSDK初始化验证功能


---
## 初始化

1. 从[短书](http://www.duanshu.com/)注册并获取DuanshuSdk的appkey、appsecret
2. 参照[Android](https://github.com/hogeclould/DuanshuH5MobileSDK-ANDROID)、[IOS](https://github.com/hogeclould/DuanshuH5MobileSDK-iOS)进行初始化操作

## 获取用户信息
**方法名**
```
duanshu.getUserInfo(params, function callback)
```

**请求示例**
```
duanshu.getUserInfo(
    function(res)
    {
        //res.data {} 为用户的基本信息
    }
);
```

**参数说明**

  参数名称: callback
- 参数类型: 回调函数 `callback(data)`
- 回调结果: 如下
- 是否必传: 必传

**回调结果**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
      "userName": "用户名",
      "userId": "用户id",
      "avatarUrl": "用户头像链接",
      "telephone": "绑定手机号"
  }
}
```

**返回结果字段说明**

| key         | 名称     | 类型     | 默认值       | 说明             |
| ----------- | ------ | ------ | --------- | -------------- |
| code        | 状态码    | int    | 0         | 0: 成功 、 1：失败   |
| msg         | 状态说明   | string | "success" | success 、error |
| data        | 实际返回数据 | {}     |           |                |
| --userName  | 用户名    | string |           |                |
| --userId    | 用户id   | string |           |                |
| --avatarUrl | 用户头像链接 | string |           |                |
| --telephone | 绑定手机号  | string |           |                |

---
## 录音相关
> 限定录音最大时长`建议120秒`，如果超过最大时长，用户未触发停止录音`stopRecord`。代码须自动停止录音，并且回调js`OnVoiceRecordEnd`监听方法

## 开始录音
**方法名**
```
duanshu.startRecord(params, callback)
```

**请求示例**
```
var params = {"base64_enabled":1}
duanshu.startRecord(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数类型: {}
  - 具体字段: {"base64_enabled":1} `base64_enabled` 当此字段开启后，录制自动结束或手动停止录音后，返回值会带有`base64字段 二进制数据base64编码`
  - 是否必传: 可选

- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 是否必传: 必选

  **回调结果**

  ```json
  {
    "code": 0,
    "msg": "success"
  }
  ```

  **返回结果字段说明**

  | key       | 名称         | 类型   | 默认值    | 说明                         |
  | --------- | ------------ | ------ | --------- | ---------------------------- |
  | code      | 状态码       | int    | 0         | 0: 成功 、 1：失败           |
  | msg       | 状态说明     | string | "success" | success 、error              |

****


## 停止录音
**方法名**
```
duanshu.stopRecord(callback)
```

**请求示例**
```
duanshu.stopRecord(function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数类型: {}
  - 是否必传: 可选
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 必选

**回调结果**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "localPath": "录音文件的本地暂存文件路径",
    "base64":"录音二进制文件的base64字符串",
    "type":"mp3"
  }
}
```

**返回结果字段说明**

| key       | 名称     | 类型     | 默认值       | 说明             |
| --------- | ------ | ------ | --------- | -------------- |
| code      | 状态码    | int    | 0         | 0: 成功 、 1：失败   |
| msg       | 状态说明   | string | "success" | success 、error |
| data      | 实际返回数据 | {}     |           |                |
| localPath | 文件路径   | string | ""         | 录音文件的本地暂存文件路径  |
| base64 | 文件路径   | string | ""         | 录音二进制文件的base64字符串  |
| type | 文件类型   | string | "mp3"         | 当前仅支持mp3  |

## 录音自动结束监听
> 特别说明：registerEvents方法需一次将全部需要的监听注册，暂时不支持单个注册
> **方法名**
```
duanshu.registerEvents({
        OnVoiceRecordEnd: function(response){
            alert(JSON.stringify(response)); // 用户自身逻辑
        }
  });

```
**回调结果**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "localPath": "录音文件的本地暂存文件路径",
    "base64":"录音二进制文件的base64字符串",
    "type":"mp3"
  }
}
```

**返回结果字段说明**

| key       | 名称     | 类型     | 默认值       | 说明                                |
| --------- | ------ | ------ | --------- | --------------------------------- |
| code      | 状态码    | int    | 0         | 0: 录音成功                   1: 录音失败 |
| msg       | 状态说明   | string | "success" | success 、error                    |
| data      | 实际返回数据 | {}     |           |                                   |
| localPath | 文件路径   | string | 0         | 录音文件的本地暂存文件路径                     |
| base64 | 文件路径   | string | ""         | 录音二进制文件的base64字符串  |
| type | 文件类型   | string | "mp3"         | 当前仅支持mp3  |


## 播放相关
## 播放语音
**方法名**
```
duanshu.playVoice(params, callback)
```

**请求示例**
```
var params = {"record_url":"http://xxx.mp3",
}
duanshu.playVoice(params,function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
  ```
  {
    "record_url":"http://xxx.mp3"
  }
  ```
  - 字段说明:
    - record_url: 音频地址
  - 是否必传: 必传
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 必选


**回调结果**

```json
{
  "code": 0,
  "msg": "success"
}
```

**返回结果字段说明**

| key  | 名称     | 类型   | 默认值    | 说明               |
| ---- | -------- | ------ | --------- | ------------------ |
| code | 状态码   | int    | 0         | 0: 成功 、 1：失败 |
| msg  | 状态说明 | string | "success" | success 、error    |

***特别说明***
```
如果用户调用暂停`pauseVoice`后，又继续调用播放方法，并且URL相同，则原音频继续播放，不重新开始
```

## 暂停语音
**方法名**
```
duanshu.pauseVoice(params, callback)
```

**请求示例**
```
duanshu.pauseVoice(params,function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**

参数名称: callback

- 参数类型: 回调函数 `callback(data)`

- 回调结果: 如下

- 是否必传: 必选

  **回调结果**

  ```json
  {
    "code": 0,
    "msg": "success"
  }
  ```

  **返回结果字段说明**

  | key  | 名称     | 类型   | 默认值    | 说明               |
  | ---- | -------- | ------ | --------- | ------------------ |
  | code | 状态码   | int    | 0         | 0: 成功 、 1：失败 |
  | msg  | 状态说明 | string | "success" | success 、error    |


## 停止语音
**方法名**
```
duanshu.stopVoice(params, callback)
```

**请求示例**
```
duanshu.stopVoice(params,function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 必选


**回调结果**

```json
{
  "code": 0,
  "msg": "success"
}
```

**返回结果字段说明**

| key  | 名称     | 类型   | 默认值    | 说明               |
| ---- | -------- | ------ | --------- | ------------------ |
| code | 状态码   | int    | 0         | 0: 成功 、 1：失败 |
| msg  | 状态说明 | string | "success" | success 、error    |

## 播放状态监听
> 特别说明：registerEvents方法需一次将全部需要的监听注册，暂时不支持单个注册
> **方法名**
```
duanshu.registerEvents({
        onVoicePlayEnd: function(response){
            alert(JSON.stringify(response)); // 用户自身逻辑
        }
  });

```
**回调结果**
```json
{
  "code": 0,
  "msg": "success"
}
```

**返回结果字段说明**

| key  | 名称   | 类型     | 默认值       | 说明                                       |
| ---- | ---- | ------ | --------- | ---------------------------------------- |
| code | 状态码  | int    | 0         | 0: 播放成功                            1: 播放失败 |
| msg  | 状态说明 | string | "success" | success 、error                           |

---
## 图片相关

## 选择本地图片
**方法名**
```
duanshu.chooseImage(params, callback)
```

**请求示例**
```
var params = {"count":1, "base64_enabled":1};
duanshu.chooseImage(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
    ```
    {
      "count":"最多选取图片张数",
      "base64_enabled":"是否开启二进制数据base64转换"
    }
    ```
  - 是否必传: 必传参数
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 必传

**回调结果（base64_enabled = 0）**
```json
{
  "code": 0,
  "msg": "success",
  "data": [
    "图片本地路径1",
    "图片本地路径2"
  ]
}
```

**回调结果（base64_enabled = 1）**
```json
{
  "code": 0,
  "msg": "success",
  "data": [
    {"localPath":"图片本地路径1", "type":"png", "base64":"xxxx"},
    {"localPath":"图片本地路径2", "type":"jpg", "base64":"xxxx"}
  ]
}
```

**返回结果字段说明**

| key  | 名称       | 类型     | 默认值       | 说明             |
| ---- | -------- | ------ | --------- | -------------- |
| code | 状态码      | int    | 0         | 0: 成功 、 1：失败   |
| msg  | 状态说明     | string | "success" | success 、error |
| data | 文件本地路径数组 | []     |           |                |

## 单图预览
**方法名**
```
duanshu.previewImage(params, callback)
```

**请求示例**
```
var params = {
      "imgUrl":"http://xxx_1.jpg"
    };
duanshu.previewImage(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
    ```
    imgUrl:单张图片的地址
    ```
  - 是否必传: 必传参数
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 可选


## 多图预览
**方法名**
```
duanshu.previewPic(params, callback)
```

**请求示例**
```
var params = {
      "position":0,
      "pics":[
        "http://xxx_1.jpg",
        "http://xxx_2.jpg"
      ]
    };
duanshu.previewImage(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
    ```
    {
      "position":0, // 默认从哪张图片开始预览 注意：position不得大于图片张数
      "pics":[
        "图片链接1",
        "图片链接2"
      ]
    }
    ```
  - 是否必传: 必传参数
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 可选


---
## 分享相关
## 分享方法
**方法名**
```
duanshu.share(params, callback)
```

**请求示例**
```
var params = {
    "title": “分享标题”,
    "content": “分享描述”,
    "picurl": “分享图片链接”,
    "url": “分享内容链接”,
    "updateShareData": “1”,
    "showShareButton": “1”
};
duanshu.share(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
    ```
    {
    "title": “分享标题”,
    "content": “分享描述”,
    "picurl": “分享图片链接”,
    "url": “分享内容链接”,
    "updateShareData": “1:只更新数据，不弹分享框；0:弹出分享框”,
    "showShareButton": “1:显示分享按钮；0:不显示分享按钮”
    }
    ```
  - 是否必传: 必传参数
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 可选

**回调结果**
```json
{
  "code": 0,
  "msg": "success"
}
```

---
## 其他
## 加载URL
**方法名**
```
duanshu.loadUrl(params, callback)
```

**请求示例**
```
var params = {"url": “内容链接”};
duanshu.loadUrl(params, function(data){
    alert(JSON.stringify(data));
});
```

**参数说明**
- 参数名称: params
  - 参数说明:
    ```
    {
    "url": “内容链接” // 支持http/https  dingdone://tel?phone_number=10086
    }
    ```
  - 是否必传: 必传参数
- 参数名称: callback
  - 参数类型: 回调函数 `callback(data)`
  - 回调结果: 如下
  - 是否必传: 必选

**回调结果**
```json
{
  "code": 0,
  "msg": "success"
}
```

**返回结果字段说明**

| key  | 名称   | 类型     | 默认值       | 说明               |
| ---- | ---- | ------ | --------- | ---------------- |
| code | 状态码  | int    | 0         | 0: 分享成功 、 1：分享失败 |
| msg  | 状态说明 | string | "success" | success 、error   |

## 全局状态码说明 `code`
| key  | 值    | 说明     |
| ---- | ---- | ------ |
| code | 0    | 正常返回   |
| code | 1    | 失败     |
| code | 3    | 用户未登录  |
| code | 10   | 网络异常   |
| code | 11   | 没有权限   |
| code | 13   | 方法未被支持 |
| code | 14   | 方法执行异常 |
