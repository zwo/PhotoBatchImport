//
//  PBFileManager.m
//  PhotoBatchImport
//
//  Created by zhouweiou on 16/12/5.
//  Copyright © 2016年 R&F Properties. All rights reserved.
//

#import "PBFileManager.h"

@implementation PBFileManager

+ (void)queryAllImageFilesInDocumentCompletion:(void (^)(NSArray *))handler
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:[self documentPath] error:&error];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(pathExtension == 'jpg') OR (pathExtension == 'png') OR (pathExtension == 'jpeg')"];
    handler([fileList filteredArrayUsingPredicate:predicate]);
}

+ (NSString *)documentPath
{
    static NSString *path;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!path) {
            path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        }
    });
    return path;
}

@end
