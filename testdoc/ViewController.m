//
//  ViewController.m
//  testdoc
//
//  Created by HuWeinan on 2018/7/13.
//  Copyright © 2018年 perhwn. All rights reserved.
//

#import "ViewController.h"
#import "WNDocWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)safe = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [safe gotoDoc];
//        vc.bgColor = @"#C7EDCC";
//        vc.textColor = [UIColor blueColor];
//        [safe presentViewController:vc animated:YES completion:nil];
    });
    
}
-(void)gotoDoc{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"test5.docx" ofType:nil];
    
    WNDocWebViewController *vc = [[WNDocWebViewController alloc]initWithDocUrl:[NSURL fileURLWithPath:path] viewFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
    [self addChildViewController:vc];
    vc.defaultSizePercent = 2.5;
    [self.view addSubview:vc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
