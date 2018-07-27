//
//  WNDocWebViewController.h
//  testdoc
//
//  Created by HuWeinan on 2018/7/24.
//  Copyright © 2018年 perhwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WNDocWebViewController : UIViewController
//由于这个controller最好座位childController使用，所以需要设置frame
-(instancetype)initWithDocUrl:(NSURL *)docUrl viewFrame:(CGRect)frame;

//默认字体大小百分比 作为自控制器时，需要设置在addSubView前，否则无效
@property(nonatomic,assign) CGFloat defaultSizePercent;

//字体颜色，可以是NSString和UIColor类型
@property(nonatomic,strong) id textColor;
//背景颜色，可以是NSString和UIColor类型
@property(nonatomic,strong) id bgColor;
@end
