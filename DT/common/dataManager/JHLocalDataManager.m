//
//  JHLocalDataManager.m
//  DT
//
//  Created by tao on 18/2/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "JHLocalDataManager.h"
#define JHLocalDefaultPath @"JHLocalDefaultPath"

@interface JHLocalDataManager ()
@property (nonatomic, strong) NSString *documentDefaultPath;
@property (nonatomic, strong) NSString *cacheDefaultPath;
@property (nonatomic, strong) NSString *tempDefaultPath;
@property (nonatomic, strong) NSString *libraryDefaultPath;
@property (nonatomic, strong) NSString *perferenceDefaultPath;
@property (nonatomic, assign) NSFileManager *fileManager;

@end

@implementation JHLocalDataManager

+(instancetype)shareJHLocalDataManager{
    static JHLocalDataManager *singleInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleInstance = [[self alloc] init];
    });
    return singleInstance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.documentDefaultPath = [self getLocalDataDefaultPathWithOption:JHLocalDataDocuments];
        self.cacheDefaultPath = [self getLocalDataDefaultPathWithOption:JHLocalDataCache];
        self.tempDefaultPath = [self getLocalDataDefaultPathWithOption:JHLocalDataTemp];
        self.libraryDefaultPath = [self getLocalDataDefaultPathWithOption:JHLocalDataLibrary];
        self.perferenceDefaultPath = [self getLocalDataDefaultPathWithOption:JHLocalDataPerferences];
        
    }
    return self;
}

#pragma mark - dataSave
/** data */
-(void)saveData:(NSData *)data withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (data.length == 0 || !type || !key) {
        return;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    BOOL isSucess;
    isSucess = [data writeToFile:path atomically:YES];
    complementBack(isSucess);
}
- (NSData *)getDataWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !key) {
        return nil;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

/** string */
-(void)saveString:(NSString *)string withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (string.length == 0 || !type || !key) {
        return;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self saveData:data withDataType:type WithKey:key withisSucess:^(BOOL isSucess) {
        complementBack(isSucess);
    }];
}

-(NSString *)getStringWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !key) {
        return nil;
    }
    NSData *data = [self getDataWithDataType:type andKey:key];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

/** array */
-(void)saveArray:(NSArray *)array withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (!array || !type || !key) {
        return;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    BOOL isSucess;
    isSucess = [array writeToFile:path atomically:YES];
    complementBack(isSucess);
}

- (NSArray *)getArrayWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !key) {
        return nil;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    return array;
}

/** dictionary */
- (void)saveDictionary:(NSDictionary *)dictionry withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (!dictionry || !type || !key) {
        return;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    BOOL isSucess;
    isSucess = [dictionry writeToFile:path atomically:YES];
    complementBack(isSucess);
}

-(NSDictionary *)getDictionaryWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !key) {
        return nil;
    }
    NSString *path  = [self getDefaultPathWithDataType:type withKey:key];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dic;
}

/** image */
-(void)saveImage:(UIImage *)image withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (!image || !type || !key) {
        return;
    }
    NSData *data = UIImagePNGRepresentation(image);
    [self saveData:data withDataType:JHLocalDataDocuments WithKey:key withisSucess:^(BOOL isSucess) {
        complementBack(isSucess);
    }];
}
-(UIImage *)getImageWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !key) {
        return nil;
    }
    NSData *data = [self getDataWithDataType:type andKey:key];
    UIImage *image = [UIImage imageWithData:data];
        return image;
}
/** object */
-(void)saveObject:(id)object withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL))complementBack{
    if (!object || !type || !key) {
        return;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    BOOL isSucess;
    isSucess = [NSKeyedArchiver archiveRootObject:object toFile:path];
    complementBack(isSucess);
}

- (id)getObjectWithDataType:(JHLocalDataType)type andKey:(NSString *)key{
    if (!type || !type) {
        return nil;
    }
    NSString *path = [self getDefaultPathWithDataType:type withKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return object;
}

#pragma mark - pathManager
- (NSString *)getDefaultPathWithDataType:(JHLocalDataType)type withKey:(NSString *)key{
    NSString *path;
    switch (type) {
        case JHLocalDataDocuments:
        {
            path = self.documentDefaultPath;
        }
            break;
        case JHLocalDataCache:
        {
            path = self.cacheDefaultPath;
        }
            break;
        case JHLocalDataTemp:
        {
            path = self.tempDefaultPath;
        }
            break;
        case JHLocalDataLibrary:
        {
            path = self.libraryDefaultPath;
        }
            break;
        case JHLocalDataPerferences:
        {
            path = self.perferenceDefaultPath;
        }
            break;
        default:
            break;
    }
    [self creatDataPathWith:type];
    return path ? [path stringByAppendingPathComponent:key] : @"";
}

/** makeAndSaveDefaultPath */
- (NSString *)getLocalDataDefaultPathWithOption:(JHLocalDataType)option{
    NSString *path;
    switch (option) {
        case JHLocalDataDocuments:
        {
            path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        }
            break;
        case JHLocalDataCache:
        {
            path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        }
            break;
        case JHLocalDataTemp:
        {
            path = NSTemporaryDirectory();
        }
            break;
        case JHLocalDataLibrary:
        {
            path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        }
            break;
        case JHLocalDataPerferences:
        {
            path = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES).firstObject;
        }
            break;
        default:
            break;
    }
    path ? [path stringByAppendingString:JHLocalDefaultPath] : @"";
    return path;
}

/** makeDocument */
- (void)creatDataPathWith:(JHLocalDataType)type{
    switch (type) {
        case JHLocalDataDocuments:
        {
            BOOL isExist;
            [self.fileManager fileExistsAtPath:self.documentDefaultPath isDirectory:&isExist];
            if (!isExist) {
                [self.fileManager createDirectoryAtPath:self.documentDefaultPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
            break;
            
        case JHLocalDataPerferences:
        {
            BOOL isExist;
            [self.fileManager fileExistsAtPath:self.perferenceDefaultPath isDirectory:&isExist];
            if (!isExist) {
                [self.fileManager createDirectoryAtPath:self.perferenceDefaultPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
            break;
        case JHLocalDataLibrary:
        {
            BOOL isExist;
            [self.fileManager fileExistsAtPath:self.libraryDefaultPath isDirectory:&isExist];
            if (!isExist) {
                [self.fileManager createDirectoryAtPath:self.libraryDefaultPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
            break;
        case JHLocalDataCache:
        {
            BOOL isExist;
            [self.fileManager fileExistsAtPath:self.cacheDefaultPath isDirectory:&isExist];
            if (!isExist) {
                [self.fileManager createDirectoryAtPath:self.cacheDefaultPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
            break;
        case JHLocalDataTemp:
        {
            BOOL isExist;
            [self.fileManager fileExistsAtPath:self.tempDefaultPath isDirectory:&isExist];
            if (!isExist) {
                [self.fileManager createDirectoryAtPath:self.tempDefaultPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - lazyLoad
- (NSFileManager *)fileManager{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end
