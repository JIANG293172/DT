//
//  CoreDataBaseViewController.h
//  DT
//
//  Created by tao on 2018/8/11.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"

@interface CoreDataBaseViewController : UIViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
@property (nonatomic, strong) NSManagedObjectContext *manageMOC;

/** 环境创建 */
- (NSManagedObjectContext *)manageMOCWithmXCDataName:(NSString *)xcname andObejctName:(NSString *)objectName andSortName:(NSString *)sortName andSectionName:(NSString *)sectionName;
/** 通过属性排序 */
- (void)sortDataWithPropertyName:(NSString *)name;
/** 删除数据NSIndexPath */
- (void)deleteEntityWithNSIndexPath:(NSIndexPath *)indexPath andError:(void(^)(NSError *error))callback;
/** 删除某个属性数据 */
-(void)deleteEntityWithPropertyKey:(NSString *)key andValue:(NSString *)value andError:(void (^)(NSError *))failure;
/** 修改某个属性数据 */
- (void)changeEntityWithFetchName:(NSString *)fetchName PropertyKey:(NSString *)key andValue:(NSString *)value andChangeObjec:(void(^)(NSManagedObject *object))changeObject andError:(void(^)(NSError *error))failure;

@end
