//
//  CoreDataViewController.m
//  DT
//
//  Created by tao on 2018/8/9.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "CoreDataViewController.h"
#import "User.h"
#import "CoreDataManager.h"

@interface CoreDataViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CoreDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tableView];
    /** 初始化数据 */
    [self manageMOCWithmXCDataName:@"Chat" andObejctName:@"User" andSortName:@"sectionName" andSectionName:@"sectionName"];
}

#pragma search data
- (void)sortDataWithPropertyName:(NSString *)name {
    [super sortDataWithPropertyName:@"name"];
    [self.tableView reloadData];
}


#pragma change data
- (void)addTextData {
    for (int i = 0; i < 2; i++) {
        [CoreDataManager insertDataWith:self.manageMOC andObjectName:@"User" andCallBack:^(id obj) {
            User *user = (User *)obj;
            user.name = [NSString stringWithFormat:@"tao"];
            user.age = [NSString stringWithFormat:@"age1"];
            user.sectionName = [NSString stringWithFormat:@"sectionName %d", i];
        }];
    }
}

- (void)changeObject {
    [self changeEntityWithFetchName:@"User" PropertyKey:@"name" andValue:@"tao" andChangeObjec:^(NSManagedObject *object) {
        if ([object isKindOfClass:[User class]]) {
            User *user = (User *)object;
            user.age = @"22";
            user.name = @"33";
            user.sectionName = @"tao";
        }
    } andError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedResultController.sections[section].numberOfObjects;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@", user.name, user.age]);
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.name, user.age];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.fetchedResultController.sections[section].indexTitle;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteEntityWithNSIndexPath:indexPath andError:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

#pragma NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
            case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
           case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            case NSFetchedResultsChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            case NSFetchedResultsChangeUpdate:
        {
            User *user = [self.fetchedResultController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = user.name;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
            case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            
        default:
            break;
    }
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return [NSString stringWithFormat:@"%@", sectionName];
}

#pragma lazyload
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
    }
    return _tableView;
}

@end
