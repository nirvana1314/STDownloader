//
//  STDownloaderManager.h
//  0120-URLConnectionDownloader
//
//  Created by 李松涛 on 14-1-20.
//  Copyright (c) 2014年 lst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDownloaderManager : NSObject

+ (instancetype)sharedSTDownloaderManager;

- (void)downloadWithURL:(NSURL *)url Progress:(void (^)(float progress))progress Completion:(void (^)(NSString *filePath))completion Failed:(void (^)(NSString *errorMessage))error;
- (void)pauseWithURL:(NSURL *)url;
@end
