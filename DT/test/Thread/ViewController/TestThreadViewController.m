//
//  TestThreadViewController.m
//  DT
//
//  Created by tao on 18/3/16.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TestThreadViewController.h"

@interface TestThreadViewController ()

@end

@implementation TestThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * 同步串行：不开启线程
     * 同步并行：不开启线程
     * 异步串行：开启线程
     * 异步并行：最多开启一个线程
     - 同步：不开启线程，并将添加信号锁。同步会阻塞当前线程
     - 异步：开启线程
     - 串行：任务一个一个执行6
     - 并行：任务不用一个一个执行
     */
    
    /** 串行队列 */
    dispatch_queue_t queueSerial = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    
    /** 在一个线程中一个串行队列中两个同步任务相互等待出现线程死锁，信号量的++被压到了最下面  */
//    dispatch_async(queue, ^{
//        dispatch_semaphore_signal(semaphore);
//    });
    



    /** 并行队列 */
    dispatch_queue_t queueConcurrent = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);

}

/** 线程死锁 */
- (void)test1{
    dispatch_queue_t queueSerial = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    /** 同步队列中两个任务相互等待 */
        dispatch_sync(queueSerial, ^{
            dispatch_sync(queueSerial, ^{
            });
        });
}
- (void)test2{
    /** 主队列中两个任务相互等待 */
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"22");
        });
}
- (void)test3{
    /** 两个队列中任务相互等待 */
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
