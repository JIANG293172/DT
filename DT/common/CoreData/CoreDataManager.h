//
//  CoreDataManager.h
//  DT
//
//  Created by tao on 2018/8/11.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

/** 创建上下文对象 */
+ (NSManagedObjectContext *)contextWithModelName:(NSString *)modelName;
/** 增加数据 */
+ (void)insertDataWith:(NSManagedObjectContext *)context andObjectName:(NSString *)objectName andCallBack:(void (^)(id obj))callback;
@end
