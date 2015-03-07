//
//  STDownloader.m
//  0120-URLConnectionDownloader
//
//  Created by 李松涛 on 14-1-20.
//  Copyright (c) 2014年 lst. All rights reserved.
//

#import "STDownloader.h"

@interface STDownloader ()<NSURLConnectionDataDelegate>
@property (strong, nonatomic) NSURL *downloadURL;

@property (strong, nonatomic) NSString *filePath;

@property (assign, nonatomic) long long expectedContentLength;

@property (assign, nonatomic) long long currentContentLength;

@property (strong, nonatomic) NSOutputStream *stream;

@property (assign, nonatomic) CFRunLoopRef runLoop;

@property (strong, nonatomic) NSURLConnection *downloadConnection;

@property (copy, nonatomic) void (^progressBlock)(float);
@property (copy, nonatomic) void (^completionBlock)(NSString *);
@property (copy, nonatomic) void (^errorBlock)(NSString *);

@end

@implementation STDownloader


- (void)pause
{
    [self.downloadConnection cancel];
}

//下载的主方法
- (void)downloadWithURL:(NSURL *)url Progress:(void (^)(float))progress Completion:(void (^)(NSString *))completion Failed:(void (^)(NSString *))error
{
    self.completionBlock = completion;
    self.progressBlock = progress;
    self.errorBlock = error;
    
    self.downloadURL = url;
    
    [self serverFileInfo];
    //文件已存在
    if (![self checkLocalInfo]) {
        if (completion) {
            completion(self.filePath);
        }
        return;
    }
    //开始下载
    [self download];
}

- (void)download
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downloadURL cachePolicy:1 timeoutInterval:10];
        
        NSString *str = [NSString stringWithFormat:@"bytes=%lld-", self.currentContentLength];
        
        [request setValue:str forHTTPHeaderField:@"Range"];
        
        self.downloadConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        //开启子线程运行循环
        self.runLoop = CFRunLoopGetCurrent();
        
        CFRunLoopRun();
    });

}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    self.stream = stream;
    [stream open];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.currentContentLength += data.length;
    float progress = (float)self.currentContentLength / self.expectedContentLength;
    NSLog(@"%f", progress);
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    [self.stream write:data.bytes maxLength:data.length];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{self.completionBlock(self.filePath);});
    }
    [self.stream close];

    CFRunLoopStop(self.runLoop);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if (self.errorBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{self.errorBlock(error.localizedDescription);});
    }
}

- (BOOL)checkLocalInfo
{
    self.currentContentLength = 0;
    long long fileSize = 0;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    //文件不存在,需要下载
    if (![fm fileExistsAtPath:self.filePath]) {
        return YES;
    }
    //文件存在,判断文件大小
    NSDictionary *dict = [fm attributesOfItemAtPath:self.filePath error:NULL];
    
    fileSize = [dict[NSFileSize] longLongValue];
//    fileSize = [dict fileSize];
    if (fileSize > self.expectedContentLength) {
        //删除源文件
        [fm removeItemAtPath:self.filePath error:NULL];
        return YES;
    }
    
    if (fileSize == self.expectedContentLength) {
        NSLog(@"文件已存在,无需下载");
        self.currentContentLength = self.expectedContentLength;
        return NO;
    }
    //fileSize < self.expectedContentLength
    self.currentContentLength = fileSize;
    
    return YES;
}

/**
 *  服务器信息
 */
- (void)serverFileInfo
{
    //同步请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downloadURL cachePolicy:1 timeoutInterval:15];
    //利用HEAD方法 只获取响应头信息
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", response.suggestedFilename]];
    self.expectedContentLength = response.expectedContentLength;
    
    return;
}

@end
