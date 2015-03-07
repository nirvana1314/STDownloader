//
//  ViewController.m
//  0120-URLConnectionDownloader
//
//  Created by 李松涛 on 14-1-20.
//  Copyright (c) 2014年 lst. All rights reserved.
//

#import "ViewController.h"
#import "STDownloader.h"
#import "STDownloaderManager.h"
@interface ViewController ()
@property (strong, nonatomic) STDownloader *downloader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}
- (IBAction)start {
    NSURL *url = [NSURL URLWithString:@"http://localhost/test.mp4"];
    
    [[STDownloaderManager sharedSTDownloaderManager] downloadWithURL:url Progress:^(float progress) {
        NSLog(@"%f", progress);
    } Completion:^(NSString *filePath) {
        NSLog(@"%@", filePath);
    } Failed:^(NSString *errorMessage) {
        NSLog(@"%@", errorMessage);
    }];
    
//    STDownloader *downloader = [[STDownloader alloc] init];
//    self.downloader = downloader;
//    
//    [downloader downloadWithURL:url Progress:^(float progress) {
//        NSLog(@"%f", progress);
//    } Completion:^(NSString *filePath) {
//        NSLog(@"下载完成,下载到:%@", filePath);
//    } Failed:nil];
}
- (IBAction)pause {
    
    [[STDownloaderManager sharedSTDownloaderManager] pauseWithURL:[NSURL URLWithString:@"http://localhost/test.mp4"]];
    
//    [self.downloader pause];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
