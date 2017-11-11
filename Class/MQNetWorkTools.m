//
//  MQNetWorkTools.m
//  01-单文件上传
//
//  Created by mac on 16/1/22.
//  Copyright © 2016年 apple. All rights reserved.
//
#define KBoundary @"boundary"
#import "MQNetWorkTools.h"
@interface MQNetWorkTools()

@end
@implementation MQNetWorkTools

//多文件上传
- (void)postRequestWithServerAddress:(NSString *)serverAddress localFiles:(NSDictionary *)fileDict FileKey:(NSString *)fileKey Parameters:(NSDictionary *)parameters Success:(Success)success andFailed:(Failed)failed {
    
    NSURL *url = [NSURL URLWithString:serverAddress];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
       
//    request.HTTPBody = [self getHTTPBodyWith:fileDict FileKey:@"userfile[]" Parameters:@{@"username" : @"smith", @"password" : @"123456"}];
    
    request.HTTPBody = [self getHTTPBodyWith:fileDict FileKey:fileKey   Parameters:parameters];
    
    request.HTTPMethod = @"POST";
    
    NSString *ContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", KBoundary];
    
    //设置请求头
    [request setValue:ContentType forHTTPHeaderField:@"Content-Type"];
    
    //创建网络会话
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
            success(data, response);
        } else {
            failed(error);
        }
        
    }] resume];
    

}

- (NSData *)getHTTPBodyWith:(NSDictionary *)dict FileKey:(NSString *)fileKey Parameters:(NSDictionary *)parameters {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *fileName = key;
        
        NSString *filePath = obj;
        
        //获取文件类型
        NSURLResponse *response = [self getFileTypeWithFilePath:filePath];
        
        //文件1
        NSMutableString *heardingString1 = [NSMutableString stringWithFormat:@"\r\n--%@\r\n", KBoundary];
        
        [heardingString1 appendFormat:@"content-Disposition: form-data; name=%@; filename=%@\r\n", fileKey, fileName];
        
        NSString *contentType = response.MIMEType;
        [heardingString1 appendFormat:@"Content-Type:%@", contentType];
        
        [data appendData:[heardingString1 dataUsingEncoding:NSUTF8StringEncoding]];
        
        [data appendData:[NSData dataWithContentsOfFile:filePath]];
        
    }];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *messageKey = key;
        
        NSString *messageValue = obj;
        
        NSMutableString *textString = [NSMutableString stringWithFormat:@"\r\n--%@\r\n", KBoundary];
        
        [textString appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", messageKey];
        
        [data appendData:[textString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [data appendData:[messageValue dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
       NSString *footerString = [NSString stringWithFormat:@"\r\n--%@--\r\n", KBoundary];
    
    [data appendData:[footerString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

//单文件上传
- (void)postRequestWithServerAddress:(NSString *)serverAddress localFilePath:(NSString *)filePath FileKey:(NSString *)fileKey FileName:(NSString *)fileName Success:(Success)success andFailed:(Failed)failed {
    
    NSURL *url = [NSURL URLWithString:serverAddress];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    //设置请求头,
    NSString *ContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", KBoundary];
    
    [request setValue:ContentType forHTTPHeaderField:@"Content-Type"];
    
    //请求体
    request.HTTPBody = [self getHTTPBodyWithFileName:fileName AndUserfileKey:fileKey withFilePath:filePath];
    
    
    //发送请求
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
             success(data, response);
        } else {
            failed(error);
        }
        
    }] resume];
    

}

- (NSData *)getHTTPBodyWithFileName:(NSString *)filename AndUserfileKey:(NSString *)userfileKey withFilePath:(NSString *)filepath {
    
    NSURLResponse *response = [self getFileTypeWithFilePath:filepath];
    
    //将要上传的文件的格式都转换成二进制数据
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //1.上传文件的上边界Content-Type
    //    multipart/form-data; boundary=---------------------------14668937309706525501471625238
    //                                -----------------------------14668937309706525501471625238
    //    Content-Disposition: form-data; name="userfile"; filename="b.jpg"
    //    Content-Type: image/jpeg
    //                                -----------------------------14668937309706525501471625238--
    NSMutableString *headString = [NSMutableString stringWithFormat:@"--%@\r\n", KBoundary];
    
    if (filename == nil) {
        //如果filename为空就使用原来的名字
        filename = response.suggestedFilename;
    }
    //userfile 服务器接受文件参数key值, filename 文件保存的名称
    [headString appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", userfileKey, filename];
    
    // Content-Type:所上传文件的文件类型! application/octet-stream:数据流格式!如果不知道文件类型,可以直接用这个数据流的格式写!
    //Content-Type:image/jpeg 所上传文件的文件类型
    [headString appendFormat:@"Content-Type: %@\r\n\r\n", response.MIMEType];
    
    [data appendData: [headString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //2.上传文件的内容
    NSData *filedata = [NSData dataWithContentsOfFile:filepath];
    
    [data appendData:filedata];
    
    //3.上传文件的下边界
    NSString *footerString = [NSString stringWithFormat:@"\r\n--%@--", KBoundary];
    [data appendData:[footerString dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

- (NSURLResponse *)getFileTypeWithFilePath:(NSString *)filepath {
    
    //通过发送一个同步请求, 来获得文件类型
    
    //根据本地文件路径, 设置一个本地的url
    NSString *urlString = [NSString stringWithFormat:@"file://%@", filepath];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //1.创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    NSLog(@"response: %@ %@ %lld", response.MIMEType, response.suggestedFilename, response.expectedContentLength);
    
    return response;
}

@end
