//
//  TestThreadViewController.m
//  DT
//
//  Created by tao on 18/3/16.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TestThreadViewController.h"
#import "YSCOperation.h"
@interface TestThreadViewController ()
/* 剩余火车票数 */
@property (nonatomic, assign) int ticketSurplusCount;
@property (readwrite, nonatomic, strong) NSLock *lock;
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

/**
 NSOpetation
 */
- (void)opration{
    //    在当前线程使用子类 NSInvocationOperation
    [self useInvocationOperation];
    
    //    在其他线程使用子类 NSInvocationOperation
    //    [NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];
    
    //    在当前线程使用 NSBlockOperation
    //    [self useBlockOperation];
    
    //    使用 NSBlockOperation 的 AddExecutionBlock: 方法
    //    [self useBlockOperationAddExecutionBlock];
    
    //    使用自定义继承自 NSOperation 的子类
    //    [self useCustomOperation];
    
    //    使用addOperation: 添加操作到队列中
    //    [self addOperationToQueue];
    
    //    使用 addOperationWithBlock: 添加操作到队列中
    //    [self addOperationWithBlockToQueue];
    
    //    设置最大并发操作数（MaxConcurrentOperationCount）
    //    [self setMaxConcurrentOperationCount];
    
    //    设置优先级
    //    [self setQueuePriority];
    //    添加依赖
    //    [self addDependency];
    
    //    线程间的通信
    //    [self communication];
    
    //    完成操作
    //    [self completionBlock];
    
    //    不考虑线程安全
    //    [self initTicketStatusNotSave];
    
    //    考虑线程安全
    //    [self initTicketStatusSave];
}

/**
 * 使用子类 NSInvocationOperation
 */
- (void)useInvocationOperation {
    
    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    // 2.调用 start 方法开始执行操作
    [op start];
}

/**
 * 使用子类 NSBlockOperation
 */
- (void)useBlockOperation {
    
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 2.调用 start 方法开始执行操作
    [op start];
}

/**
 * 使用子类 NSBlockOperation
 * 调用方法 AddExecutionBlock:
 */
- (void)useBlockOperationAddExecutionBlock {
    
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 2.添加额外的操作
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"6---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"7---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"8---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.调用 start 方法开始执行操作
    [op start];
}

/**
 * 使用自定义继承自 NSOperation 的子类
 */
- (void)useCustomOperation {
    // 1.创建 YSCOperation 对象
    YSCOperation *op = [[YSCOperation alloc] init];
    // 2.调用 start 方法开始执行操作
    [op start];
}

/**
 * 使用 addOperation: 将操作加入到操作队列中
 */
- (void)addOperationToQueue {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    
    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
}

/**
 * 使用 addOperationWithBlock: 将操作加入到操作队列中
 */
- (void)addOperationWithBlockToQueue {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

/**
 * 设置 MaxConcurrentOperationCount（最大并发操作数）
 */
- (void)setMaxConcurrentOperationCount {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
    //    queue.maxConcurrentOperationCount = 2; // 并发队列
    //    queue.maxConcurrentOperationCount = 8; // 并发队列
    
    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

/**
 * 设置优先级
 * 就绪状态下，优先级高的会优先执行，但是执行时间长短并不是一定的，所以优先级高的并不是一定会先执行完毕
 */
- (void)setQueuePriority
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            NSLog(@"1-----%@", [NSThread currentThread]);
            [NSThread sleepForTimeInterval:2];
        }
    }];
    [op1 setQueuePriority:(NSOperationQueuePriorityVeryLow)];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            NSLog(@"2-----%@", [NSThread currentThread]);
            [NSThread sleepForTimeInterval:2];
        }
    }];
    
    [op2 setQueuePriority:(NSOperationQueuePriorityVeryHigh)];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
}

/**
 * 操作依赖
 * 使用方法：addDependency:
 */
- (void)addDependency {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.添加依赖
    [op2 addDependency:op1];    // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

/**
 * 线程间通信
 */
- (void)communication {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2];      // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}

/**
 * 完成操作 completionBlock
 */
- (void)completionBlock {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.添加完成操作
    op1.completionBlock = ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    };
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
}

#pragma mark - 线程安全
/**
 * 非线程安全：不使用 NSLock
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        
        if (self.ticketSurplusCount > 0) {
            
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 线程安全：使用 NSLock 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    self.lock = [[NSLock alloc] init];
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 加锁
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        // 解锁
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 任务1
 */
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);     // 打印当前线程
    }
}

/**
 * 任务2
 */
- (void)task2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);     // 打印当前线程
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
