//
//  STDownloaderManager.m
//  0120-URLConnectionDownloader
//
//  Created by 李松涛 on 14-1-20.
//  Copyright (c) 2014年 lst. All rights reserved.
//

#import "STDownloaderManager.h"
#import "STDownloader.h"
@interface STDownloaderManager ()
@property (strong, nonatomic) NSMutableDictionary *downloaderCache;
@property (nonatomic, copy) void(^failedBlock)(NSString *);

@end

@implementation STDownloaderManager

- (NSMutableDictionary *)downloaderCache
{
    if (_downloaderCache == nil) {
        _downloaderCache = [[NSMutableDictionary alloc] init];
    }
    return _downloaderCache;

}

+ (instancetype)sharedSTDownloaderManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)pauseWithURL:(NSURL *)url
{
    STDownloader *downloader = self.downloaderCache[url.path];
    
    if (downloader == nil) {
        self.failedBlock(@"没有任务,无需暂停");
    }
    
    [downloader pause];
    
    [self.downloaderCache removeObjectForKey:url.path];
}

-(void)downloadWithURL:(NSURL *)url Progress:(void (^)(float))progress Completion:(void (^)(NSString *))completion Failed:(void (^)(NSString *))error
{
    self.failedBlock = error;
    STDownloader *downloader = self.downloaderCache[url.path];
    if (downloader) {
        if (error) {
            error(@"下载正在进行......");
        }
        NSLog(@"================%tu", self.downloaderCache.count);
        return;
    }
    downloader = [[STDownloader alloc] init];
    //添加到缓冲池
    [self.downloaderCache setValue:downloader forKey:url.path];
    //开始下载
    [downloader downloadWithURL:url Progress:progress Completion:^(NSString *filePath){
        //移除操作
        [self.downloaderCache removeObjectForKey:url.path];
        if (completion) {
            completion(filePath);
        }
    }Failed:error];
    
    
}
@end
