//
//  LevelDB.h
//  LevelDB
//
//  Created by evan on 15/4/20.
//  Copyright (c) 2015年 evan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

extern NSString * const CSPLevelDBErrorDomain;

@class CSPLevelDBIterator;
@protocol CSPLevelDBWriteBatch;

@interface LevelDB : NSObject

@property (nonatomic, readonly, strong) NSString *path;

+ (LevelDB *)levelDBWithPath:(NSString *)path error:(NSError **)errorOut;

- (void)close;

- (BOOL)setData:(NSData *)data forKey:(NSString *)key;
- (BOOL)setString:(NSString *)str forKey:(NSString *)key;
- (BOOL)setArray:(NSArray *)data forKey:(NSString *)key;
- (BOOL)setDictionary:(NSDictionary *)data forKey:(NSString *)key;
- (BOOL)setBool:(BOOL)val forKey:(NSString *)key;
- (BOOL)setInt:(int)val forKey:(NSString *)key;
- (BOOL)setLong:(long long)val forKey:(NSString *)key;
- (BOOL)setFloat:(float)val forKey:(NSString *)key;
- (BOOL)setDouble:(double)val forKey:(NSString *)key;
- (BOOL)setNumber:(NSNumber *)val forKey:(NSString *)key;

- (NSData *)dataForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (long long)longForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;

- (BOOL)removeKey:(NSString *)key;

- (NSArray *)allKeys;

- (void)enumerateKeys:(void (^)(NSString *key, BOOL *stop))block;
- (void)enumerateKeysAndValuesAsStrings:(void (^)(NSString *key, NSString *value, BOOL *stop))block;

// Objective-C Subscripting Support:
//   The database object supports subscripting for string-string and string-data key-value access and assignment.
//   Examples:
//     db[@"key"] = @"value";
//     db[@"key"] = [NSData data];
//     NSString *s = db[@"key"];
//   An NSInvalidArgumentException is raised if the key is not an NSString, or if the assigned object is not an
//   instance of NSString or NSData.
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

// Batch write/atomic update support:
- (id<CSPLevelDBWriteBatch>)beginWriteBatch;
- (BOOL)commitWriteBatch:(id<CSPLevelDBWriteBatch>)batch;

@end


@interface CSPLevelDBIterator : NSObject

+ (id)iteratorWithLevelDB:(LevelDB *)db;

// Designated initializer:
- (id)initWithLevelDB:(LevelDB *)db;

- (BOOL)seekToKey:(NSString *)key;
- (NSString *)nextKey;
- (NSString *)key;
- (NSString *)valueAsString;
- (NSData *)valueAsData;

@end


@protocol CSPLevelDBWriteBatch <NSObject>

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)setString:(NSString *)str forKey:(NSString *)key;
- (void)setArray:(NSArray *)data forKey:(NSString *)key;
- (void)setDictionary:(NSDictionary *)data forKey:(NSString *)key;
- (void)setBool:(BOOL)val forKey:(NSString *)key;
- (void)setInt:(int)val forKey:(NSString *)key;
- (void)setLong:(long long)val forKey:(NSString *)key;
- (void)setFloat:(float)val forKey:(NSString *)key;
- (void)setDouble:(double)val forKey:(NSString *)key;
- (void)setNumber:(NSNumber *)val forKey:(NSString *)key;

- (void)removeKey:(NSString *)key;

// Remove all of the buffered sets and removes:
- (void)clear;

@end
