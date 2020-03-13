//
//  HTTPTool.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/11.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "HTTPTool.h"

@interface HTTPTool()
@property(nonatomic,strong) NSURLSessionDataTask *currentDataTask;

@end

static HTTPTool *tool = nil;
@implementation HTTPTool

+(instancetype)tool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}


-(void)getData:(NSString *)period  complation:(void(^)(NSArray<KLineModel *> *models))complationBlock  {
    [_currentDataTask cancel];
    NSString *urls = [NSString stringWithFormat:@"%@%@%@",@"https://api.huobi.pro/market/history/kline?period=",period,@"&size=300&symbol=btcusdt"];
    NSURL *url = [[NSURL alloc] initWithString:urls];
    
    NSURLRequest *requst = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSArray *datas = [self getLocalData];
    dispatch_async(dispatch_get_main_queue(), ^{
        complationBlock(datas);
    });
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requst completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(error == nil) {
//           NSDictionary *dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:nil];
//            NSArray<NSDictionary *> *dicts = dict[@"data"];
//            NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
//            for (int i = 0; i < dicts.count; i++) {
//                NSDictionary *item = dicts[i];
//                [array addObject:[[KLineModel alloc] initWithDict:item]];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                complationBlock(array);
//            });
//        } else {
//            NSArray *datas = [self getLocalData];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                complationBlock(datas);
//            });
//        }
//    }];
//    [dataTask resume];
}

-(NSArray<KLineModel *> *)getLocalData {
   NSString *path = [[NSBundle mainBundle] pathForResource:@"kline" ofType:@"json"];
   NSDate *data = [[NSData alloc] initWithContentsOfURL: [[NSURL alloc] initFileURLWithPath:path]];
    NSArray<NSDictionary *> *dicts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:nil];
//   NSArray<NSDictionary *> *dicts = dict[@"data"];
   NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
   for (int i = 10; i < 11; i++) {
       NSDictionary *item = dicts[i];
       [array addObject:[[KLineModel alloc] initWithDict:item]];
    }
    return array;
}



@end
