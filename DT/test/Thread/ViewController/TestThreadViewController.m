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
     - 串行：任务一个一个执行
     - 并行：任务不用一个一个执行
     */
    
    [self performSelector:@selector(test7) withObject:nil];

    /** 并行队列 */
//    dispatch_queue_t queueConcurrent = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);

}

/**
 线程死锁
 在一个线程中一个串行队列中两个同步任务相互等待出现线程死锁，信号量的++被压到了最下面
 dispatch_async(queue, ^{
 dispatch_semaphore_signal(semaphore);
 });
 */
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
    dispatch_queue_t queueSerialOne = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queueSerialTwo = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queueSerialOne, ^{
        dispatch_sync(queueSerialTwo, ^{
            dispatch_sync(queueSerialOne, ^{
                
            });
        });
    });
}
/**
 延迟执行
 默认方式是异步，使用主要队列会在主线程中执行
 使用串行队列会开启线程
 */
- (void)test4{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_queue_t queueSerialOne = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    dispatch_after(time, queueSerialOne, ^{
    });
}

/**
 组
 dispatch_group_t: 可以阻塞当前线程，当所有任务完成时在往下执行
 dispatch_group_notify: 可以不阻塞当前线程
 */
- (void)test5{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)test6{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
    });
    dispatch_group_notify(group, queue, ^{
    });
}
/**
 多次执行
 dispatch_apply: 会阻塞当前线程
 */
- (void)test7{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t i) {
    });
}
/**
 队列特有数据
 */
- (void)test8{
    dispatch_queue_t queueA = dispatch_queue_create("queueA", NULL);
    dispatch_queue_t queueB = dispatch_queue_create("queueB", NULL);
    dispatch_set_target_queue(queueB, queueA);
    
    static int kQeueueSpecific;
    CFStringRef queueSpecificValue = CFSTR("queueA");
    dispatch_queue_set_specific(queueA, &kQeueueSpecific, (void *)queueSpecificValue, (dispatch_function_t)CFRelease);
    dispatch_sync(queueB, ^{
        dispatch_block_t block = ^{
            NSLog(@"2222");
        };
        CFStringRef retrievedValue = dispatch_get_specific(&kQeueueSpecific);
        if (retrievedValue) {
            block();
        }else{
            dispatch_sync(queueA, block);
        }
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
