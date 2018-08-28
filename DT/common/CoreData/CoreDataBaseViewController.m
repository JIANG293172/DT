//
//  CoreDataBaseViewController.m
//  DT
//
//  Created by tao on 2018/8/11.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "CoreDataBaseViewController.h"
#import "CoreDataManager.h"

@interface CoreDataBaseViewController ()

@end

@implementation CoreDataBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self
                                                            action:@selector(changeObject)];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"增加" style:UIBarButtonItemStylePlain target:self
                                                             action:@selector(addTextData)];
    self.navigationItem.rightBarButtonItems = @[item, item1];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeObject{
}

- (NSManagedObjectContext *)manageMOCWithmXCDataName:(NSString *)xcname andObejctName:(NSString *)objectName andSortName:(NSString *)sortName andSectionName:(NSString *)sectionName {
    if(!_manageMOC) {
        _manageMOC = [CoreDataManager contextWithModelName:xcname];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:objectName];
        NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:sortName ascending:YES];
        request.sortDescriptors = @[ageSort];
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_manageMOC sectionNameKeyPath:sectionName cacheName:nil];
        _fetchedResultController .delegate = self;
        NSError *error = nil;
        [self.fetchedResultController performFetch:&error];
    }
    return _manageMOC;
}

- (void)sortDataWithPropertyName:(NSString *)name {
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:name ascending:YES];
    self.fetchedResultController.fetchRequest.sortDescriptors = @[ageSort];
    NSError *error = nil;
    [self.fetchedResultController performFetch:&error];
    if (error) {
        NSLog(@"NSFetchedResultsController init error : %@", error);
    }
}

- (void)deleteEntityWithNSIndexPath:(NSIndexPath *)indexPath andError:(void(^)(NSError *error))callback {
    id obj = [self.fetchedResultController objectAtIndexPath:indexPath];
    if (obj) {
        [self.manageMOC deleteObject:obj];
        NSError *error = nil;
        if (![self.manageMOC save:&error]) {
            callback(error);
        }
    }
}

-(void)deleteEntityWithPropertyKey:(NSString *)key andValue:(NSString *)value andError:(void (^)(NSError *))failure {
    if (!key || !value) return;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ = %@", key, value];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray<NSManagedObject *> *students = [self.manageMOC executeFetchRequest:request error:&error];
    [students enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[NSManagedObject class]]) {
            [self.manageMOC deleteObject:obj];
        }
    }];
    if (self.manageMOC.hasChanges) {
        [self.manageMOC save:nil];
    }
    if (error) {
        failure(error);
    }
}

- (void)changeEntityWithFetchName:(NSString *)fetchName PropertyKey:(NSString *)key andValue:(NSString *)value andChangeObjec:(void(^)(NSManagedObject *object))changeObject andError:(void(^)(NSError *error))failure {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:fetchName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@", key, value];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray<NSManagedObject *> *students = [self.manageMOC executeFetchRequest:request error:&error];
    [students enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) changeObject(obj);
        //        obj.age = @(24);
    }];
    if (self.manageMOC.hasChanges) {
        [self.manageMOC save:nil];
    }
    if (error) {
        failure(error);
    }
    /**
     在上面简单的设置了NSPredicate的过滤条件，对于比较复杂的业务需求，还可以设置复合过滤条件，例如下面的例子
     [NSPredicate predicateWithFormat:@"(age < 25) AND (firstName = XiaoZhuang)"]
     
     也可以通过NSCompoundPredicate对象来设置复合过滤条件
     [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[predicate1, predicate2]]
     */
}



@end
