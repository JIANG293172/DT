//
//  CoreDataManager.m
//  DT
//
//  Created by tao on 2018/8/11.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

/** 创建上下文对象 */
+ (NSManagedObjectContext *)contextWithModelName:(NSString *)modelName {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite", modelName];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                        URL:[NSURL fileURLWithPath:dataPath] options:nil
                                      error:nil
     ];
    context.persistentStoreCoordinator = coordinator;
    return context;
}

+ (void)insertDataWith:(NSManagedObjectContext *)context andObjectName:(NSString *)objectName andCallBack:(void (^)(id obj))callback {
    id obj = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    if (obj && [obj isKindOfClass:NSClassFromString(objectName)]) callback(obj);
    NSError *error = nil;
    if (context.hasChanges) {
        [context save:&error];
        NSLog(@"addTextData withError:%@", error);
    }
}

@end
