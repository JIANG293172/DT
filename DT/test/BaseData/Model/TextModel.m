//
//  TextModel.m
//  DT
//
//  Created by tao on 18/2/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TextModel.h"

@implementation TextModel
-(instancetype)init{
    if (self = [super init]) {
        _name = @"jiangtao";
        _age = @"24";
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [self yy_modelEncodeWithCoder:aCoder];
}
@end
