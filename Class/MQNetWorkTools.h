//
//  MQNetWorkTools.h
//  01-单文件上传
//
//  Created by mac on 16/1/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^Success)(NSData * _Nullable data, NSURLResponse * _Nullable response);
typedef void (^Failed)(NSError * _Nullable error);
@interface MQNetWorkTools : UIViewController

- (void)postRequestWithServerAddress:(NSString *)serverAddress localFilePath:(NSString *)filePath FileKey:(NSString *)fileKey FileName:(NSString *)fileName Success:(Success)success andFailed:(Failed)failed;

- (void)postRequestWithServerAddress:(NSString *)serverAddress localFiles:(NSDictionary *)fileDict FileKey:(NSString *)fileKey Parameters:(NSDictionary *)parameters Success:(Success)success andFailed:(Failed)failed;

@end
