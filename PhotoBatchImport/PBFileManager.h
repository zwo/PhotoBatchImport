//
//  PBFileManager.h
//  PhotoBatchImport
//
//  Created by zhouweiou on 16/12/5.
//  Copyright © 2016年 R&F Properties. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBFileManager : NSObject

+ (void)queryAllImageFilesInDocumentCompletion:(void (^)(NSArray *result))handler;
+ (NSArray *)queryAllImageFilesInPath:(NSString *)path;
+ (NSString *)documentPath;
@end
