### WNDocWebViewController

这是一个使用WKWebView读取doc、docx文档的控制器，需要作为子控制器使用。
#### 可以pod install
```
platform :ios, '8.0'

target 'testpoddoc' do

    pod 'WNDocWebViewController'

end
```
#### 代码使用方式
```objectivec
    NSString *path = [[NSBundle mainBundle]pathForResource:@"test5.docx" ofType:nil];
    
    WNDocWebViewController *vc = [[WNDocWebViewController alloc]initWithDocUrl:[NSURL fileURLWithPath:path] viewFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
    [self addChildViewController:vc];
    vc.defaultSizePercent = 2.5;
    [self.view addSubview:vc.view];
```
#### 特点

1. 可以通过手指粘合调整字体大小

2. 去除doc、docx文档上下左右的空白

3. 可以自定义文档字体颜色

4. 可以自定义文档背景

5. 记录并自动恢复上次已调整的字体大小

#### 效果图
![image](https://github.com/WeinanHu/WNDocWebViewController/raw/master/testdoc.gif)
<!-- <img src="https://github.com/WeinanHu/WNDocWebViewController/raw/master/testdoc.gif" width=257 height=459 /> -->
<!-- <iframe height=459 width=257 src="https://github.com/WeinanHu/WNDocWebViewController/testdoc.gif"> -->

