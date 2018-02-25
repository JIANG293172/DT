//
//  TestViewController.m
//  DT
//
//  Created by tao on 18/2/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TestViewController.h"
#import "TextModel.h"
#import "JHLocalDataManager.h"

@interface TestViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIImageView  *iv;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        TextModel *model = [[TextModel alloc] init];
        [self.dataArray addObject:model];
    }
    
    UIImageView *iv = [[UIImageView alloc] init];
    [self.view addSubview:iv];
    iv.frame = CGRectMake(100, 200, 100, 100);
    _iv = iv;
    /** data */
    NSData *data = [@"datastring" dataUsingEncoding:NSUTF8StringEncoding];
    [[JHLocalDataManager shareJHLocalDataManager] saveData:data withDataType:JHLocalDataDocuments WithKey:@"datastring" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);
    }];
    
    /** sting */
    [[JHLocalDataManager shareJHLocalDataManager] saveString:@"string" withDataType:JHLocalDataDocuments WithKey:@"string" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);
    }];
    
    /** array */
    NSArray *array = @[@"array1", @"array2"];
    [[JHLocalDataManager shareJHLocalDataManager] saveArray:array withDataType:JHLocalDataDocuments WithKey:@"array" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);

    }];
    
    /** dictionary */
    NSDictionary *dic = @{@"1": @"dictonary1", @"2": @"dictonary2"};
    [[JHLocalDataManager shareJHLocalDataManager] saveDictionary:dic withDataType:JHLocalDataDocuments WithKey:@"dictionary" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);
    }];
    
    /** image */
    UIImage *image = [UIImage imageNamed:@"tao"];
    [[JHLocalDataManager shareJHLocalDataManager] saveImage:image withDataType:JHLocalDataDocuments WithKey:@"image" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);
    }];
    
    /** object */
    [[JHLocalDataManager shareJHLocalDataManager] saveObject:self.dataArray withDataType:JHLocalDataDocuments WithKey:@"data" withisSucess:^(BOOL isSucess) {
        NSLog(@"isSucess %d", isSucess);
    }];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSData *data = [[JHLocalDataManager shareJHLocalDataManager] getDataWithDataType:JHLocalDataDocuments andKey:@"datastring"];
    NSString *dataSting = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"dataSring: %@", dataSting);
    
    NSString *string = [[JHLocalDataManager shareJHLocalDataManager] getStringWithDataType:JHLocalDataDocuments andKey:@"string"];
    NSLog(@"string: %@", string);
    
    NSArray *array = [[JHLocalDataManager shareJHLocalDataManager] getArrayWithDataType:JHLocalDataDocuments andKey:@"array"];
    NSLog(@"array: %@",array);
    
    NSDictionary *dic = [[JHLocalDataManager shareJHLocalDataManager] getDictionaryWithDataType:JHLocalDataDocuments andKey:@"dictionary"];
    NSLog(@"%@", dic);
    
    UIImage *image = [[JHLocalDataManager shareJHLocalDataManager] getImageWithDataType:JHLocalDataDocuments andKey:@"image"];
    _iv.image = image;
    
    
    id object = [[JHLocalDataManager shareJHLocalDataManager] getObjectWithDataType:JHLocalDataDocuments andKey:@"data"];
    NSLog(@"%@", object);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
