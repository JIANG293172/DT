//
// Created by luosong on 14-4-22.
// Copyright (c) 2014 Nulayer Inc. All rights reserved.
//

#import "LevelDB.h"
#import "write_batch.h"
#import "db.h"

NSString * const CSPLevelDBErrorDomain = @"CSPLevelDBErrorDomain";

#define SliceFromString(_string_) (leveldb::Slice((char *)[_string_ UTF8String], [_string_ lengthOfBytesUsingEncoding:NSUTF8StringEncoding]))
#define StringFromSlice(_slice_) ([[NSString alloc] initWithBytes:_slice_.data() length:_slice_.size() encoding:NSUTF8StringEncoding])


@interface CSPLevelDBWriteBatch : NSObject <CSPLevelDBWriteBatch> {
@package
    leveldb::WriteBatch _batch;
}
@end


#pragma mark - CSPLevelDB

@interface LevelDB () {
    leveldb::DB *_db;
    leveldb::ReadOptions _readOptions;
    leveldb::WriteOptions _writeOptions;
}
- (id)initWithPath:(NSString *)path error:(NSError **)errorOut;
+ (leveldb::Options)defaultCreateOptions;
@property (nonatomic, readonly) leveldb::DB *db;
@end


@implementation LevelDB

@synthesize path = _path;
@synthesize db = _db;

+ (LevelDB *)levelDBWithPath:(NSString *)path error:(NSError **)errorOut {
    return [[LevelDB alloc] initWithPath:path error:errorOut];
}

- (id)initWithPath:(NSString *)path error:(NSError **)errorOut
{
    if ((self = [super init]))
    {
        _path = [path copy];

        leveldb::Options options = [[self class] defaultCreateOptions];

        leveldb::Status status = leveldb::DB::Open(options, [_path UTF8String], &_db);

        if (!status.ok())
        {
            if (errorOut)
            {
                NSString *statusString = [[NSString alloc] initWithCString:status.ToString().c_str() encoding:NSUTF8StringEncoding];
                *errorOut = [NSError errorWithDomain:CSPLevelDBErrorDomain
                                                code:0
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:statusString, NSLocalizedDescriptionKey, nil]];
            }
            return nil;
        }

        _writeOptions.sync = false;
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

+ (leveldb::Options)defaultCreateOptions
{
    leveldb::Options options;
    options.create_if_missing = true;
    return options;
}

- (void)close {
    if (_db) {
        delete _db;
        _db = NULL;
    }
}

- (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    leveldb::Slice valueSlice = leveldb::Slice((const char *)[data bytes], (size_t)[data length]);
    leveldb::Status status = _db->Put(_writeOptions, keySlice, valueSlice);
    return (status.ok() == true);
}

- (BOOL)setArray:(NSArray *)data forKey:(NSString *)key {
    return [self setData:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:key];
}

- (BOOL)setDictionary:(NSDictionary *)data forKey:(NSString *)key {
    return [self setData:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:key];
}

- (BOOL)setBool:(BOOL)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithBool:val] forKey:key];
}

- (BOOL)setInt:(int)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithInt:val] forKey:key];
}

- (BOOL)setLong:(long long)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithLongLong:val] forKey:key];
}

- (BOOL)setFloat:(float)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithFloat:val] forKey:key];
}

- (BOOL)setDouble:(double)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithDouble:val] forKey:key];
}

- (BOOL)setNumber:(NSNumber *)val forKey:(NSString *)key {
    return [self setString:[val stringValue] forKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSData * data = [self dataForKey:key];
    if (data) {
        return (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    NSData * data = [self dataForKey:key];
    if (data) {
        return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (BOOL)boolForKey:(NSString *)key {
    NSString * val = [self stringForKey:key];
    if (val) {
        return [val boolValue];
    }
    return NO;
}

- (int)intForKey:(NSString *)key {
    NSString * val = [self stringForKey:key];
    if (val) {
        return [val intValue];
    }
    return 0;
}

- (long long)longForKey:(NSString *)key {
    NSString * val = [self stringForKey:key];
    if (val) {
        return [val longLongValue];
    }
    return 0;
}

- (float)floatForKey:(NSString *)key {
    NSString * val = [self stringForKey:key];
    if (val) {
        return [val floatValue];
    }
    return 0;
}

- (double)doubleForKey:(NSString *)key {
    NSString * val = [self stringForKey:key];
    if (val) {
        return [val doubleValue];
    }
    return 0;
}


- (BOOL)setString:(NSString *)str forKey:(NSString *)key
{
    // This could have been based on
    leveldb::Slice keySlice = SliceFromString(key);
    leveldb::Slice valueSlice = SliceFromString(str);
    leveldb::Status status = _db->Put(_writeOptions, keySlice, valueSlice);
    return (status.ok() == true);
}

- (NSData *)dataForKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    std::string valueCPPString;
    leveldb::Status status = _db->Get(_readOptions, keySlice, &valueCPPString);

    if (!status.ok())
        return nil;
    else
        return [NSData dataWithBytes:valueCPPString.data() length:valueCPPString.size()];
}

- (NSString *)stringForKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    std::string valueCPPString;
    leveldb::Status status = _db->Get(_readOptions, keySlice, &valueCPPString);

    // We assume (dangerously?) UTF-8 string encoding:
    if (!status.ok())
        return nil;
    else
        return [[NSString alloc] initWithBytes:valueCPPString.data() length:valueCPPString.size() encoding:NSUTF8StringEncoding];
}

- (BOOL)removeKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    leveldb::Status status = _db->Delete(_writeOptions, keySlice);
    return (status.ok() == true);
}

- (NSArray *)allKeys
{
    NSMutableArray *keys = [NSMutableArray array];
    [self enumerateKeys:^(NSString *key, BOOL *stop) {
        [keys addObject:key];
    }];
    return keys;
}

- (void)enumerateKeysAndValuesAsStrings:(void (^)(NSString *key, NSString *value, BOOL *stop))block
{
    BOOL stop = NO;
    leveldb::Iterator* iter = _db->NewIterator(leveldb::ReadOptions());
    for (iter->SeekToFirst(); iter->Valid(); iter->Next()) {
        leveldb::Slice key = iter->key(), value = iter->value();
        NSString *k = StringFromSlice(key);
        NSString *v = [[NSString alloc] initWithBytes:value.data() length:value.size() encoding:NSUTF8StringEncoding];
        block(k, v, &stop);
        if (stop)
            break;
    }

    delete iter;
}

- (void)enumerateKeys:(void (^)(NSString *key, BOOL *stop))block
{
    BOOL stop = NO;
    leveldb::Iterator* iter = _db->NewIterator(leveldb::ReadOptions());
    for (iter->SeekToFirst(); iter->Valid(); iter->Next()) {
        leveldb::Slice key = iter->key();
        NSString *k = StringFromSlice(key);
        block(k, &stop);
        if (stop)
            break;
    }

    delete iter;
}


#pragma mark - Subscripting Support

- (id)objectForKeyedSubscript:(id)key
{
    if (![key respondsToSelector: @selector(componentsSeparatedByString:)])
    {
        [NSException raise:NSInvalidArgumentException format:@"key must be an NSString"];
    }
    return [self stringForKey:key];
}
- (void)setObject:(id)thing forKeyedSubscript:(id<NSCopying>)key
{
    id idKey = (id) key;
    if (![idKey respondsToSelector: @selector(componentsSeparatedByString:)])
    {
        [NSException raise:NSInvalidArgumentException format:@"key must be NSString or NSData"];
    }

    if ([thing respondsToSelector:@selector(componentsSeparatedByString:)])
        [self setString:thing forKey:(NSString *)key];
    else if ([thing respondsToSelector:@selector(subdataWithRange:)])
        [self setData:thing forKey:(NSString *)key];
    else
        [NSException raise:NSInvalidArgumentException format:@"object must be NSString or NSData"];
}

#pragma mark - Atomic Updates

- (id<CSPLevelDBWriteBatch>)beginWriteBatch
{
    CSPLevelDBWriteBatch *batch = [[CSPLevelDBWriteBatch alloc] init];
    return batch;
}

- (BOOL)commitWriteBatch:(id<CSPLevelDBWriteBatch>)theBatch
{
    if (!theBatch)
        return NO;

    CSPLevelDBWriteBatch *batch = (CSPLevelDBWriteBatch *) theBatch;

    leveldb::Status status;
    status = _db->Write(_writeOptions, &batch->_batch);
    return (status.ok() == true);
}

@end


#pragma mark - CSPLevelDBIterator

@interface CSPLevelDBIterator () {
    leveldb::Iterator *_iter;
}
@end



@implementation CSPLevelDBIterator

+ (id)iteratorWithLevelDB:(LevelDB *)db
{
    CSPLevelDBIterator *iter = [[[self class] alloc] initWithLevelDB:db];
    return iter;
}

- (id)initWithLevelDB:(LevelDB *)db
{
    if ((self = [super init]))
    {
        _iter = db.db->NewIterator(leveldb::ReadOptions());
        _iter->SeekToFirst();
        if (!_iter->Valid())
            return nil;
    }
    return self;
}

- (id)init
{
    [NSException raise:@"BadInitializer" format:@"Use the designated initializer, -initWithLevelDB:, instead."];
    return nil;
}

- (void)dealloc
{
    delete _iter;
    _iter = NULL;
}

- (BOOL)seekToKey:(NSString *)key
{
    leveldb::Slice target = SliceFromString(key);
    _iter->Seek(target);
    return _iter->Valid() == true;
}

- (void)seekToFirst
{
    _iter->SeekToFirst();
}

- (void)seekToLast
{
    _iter->SeekToLast();
}

- (NSString *)nextKey
{
    _iter->Next();
    return [self key];
}

- (NSString *)key
{
    if (_iter->Valid() == false)
        return nil;
    leveldb::Slice value = _iter->key();
    return StringFromSlice(value);
}

- (NSString *)valueAsString
{
    if (_iter->Valid() == false)
        return nil;
    leveldb::Slice value = _iter->value();
    return StringFromSlice(value);
}

- (NSData *)valueAsData
{
    if (_iter->Valid() == false)
        return nil;
    leveldb::Slice value = _iter->value();
    return [NSData dataWithBytes:value.data() length:value.size()];
}

@end



#pragma mark - CSPLevelDBWriteBatch

@implementation CSPLevelDBWriteBatch

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    leveldb::Slice valueSlice = leveldb::Slice((const char *)[data bytes], (size_t)[data length]);
    _batch.Put(keySlice, valueSlice);
}
- (void)setString:(NSString *)str forKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    leveldb::Slice valueSlice = SliceFromString(str);
    _batch.Put(keySlice, valueSlice);
}

- (void)setArray:(NSArray *)data forKey:(NSString *)key {
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:key];
}

- (void)setDictionary:(NSDictionary *)data forKey:(NSString *)key {
    return [self setData:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:key];
}

- (void)setBool:(BOOL)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithBool:val] forKey:key];
}

- (void)setInt:(int)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithInt:val] forKey:key];
}

- (void)setLong:(long long)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithLongLong:val] forKey:key];
}

- (void)setFloat:(float)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithFloat:val] forKey:key];
}

- (void)setDouble:(double)val forKey:(NSString *)key {
    return [self setNumber:[NSNumber numberWithDouble:val] forKey:key];
}

- (void)setNumber:(NSNumber *)val forKey:(NSString *)key {
    return [self setString:[val stringValue] forKey:key];
}

- (void)removeKey:(NSString *)key
{
    leveldb::Slice keySlice = SliceFromString(key);
    _batch.Delete(keySlice);
}

- (void)clear
{
    _batch.Clear();
}

@end
