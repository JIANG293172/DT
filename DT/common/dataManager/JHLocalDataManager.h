//
//  JHLocalDataManager.h
//  DT
//
//  Created by tao on 18/2/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSInteger, JHLocalDataType) {
    JHLocalDataPerferences = 1,
    JHLocalDataDocuments,
    JHLocalDataLibrary,
    JHLocalDataCache,
    JHLocalDataTemp
};

@interface JHLocalDataManager : NSObject

/** data */
- (void)saveData:(NSData *)data withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL isSucess))complementBack;
- (NSData *)getDataWithDataType:(JHLocalDataType)type andKey:(NSString *)key;
/** string */
- (void)savaSting:(NSString *)string withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL isSucess))complementBack;
- (NSString *)getStingWithDataType:(JHLocalDataType)type andKey:(NSString *)key;
/** array  */
- (void)saveArray:(NSArray *)array withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL isSucess))complementBack;
- (NSArray *)getArrayWithDataType:(JHLocalDataType)type andKey:(NSString *)key;
/** dictionry  */
- (void)saveDictionary:(NSDictionary *)dictionry withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL isSucess))complementBack;
- (NSDictionary *)getDictionaryWithDataType:(JHLocalDataType)type andKey:(NSString *)key;
/** objects  */
- (void)saveObject:(id)object withDataType:(JHLocalDataType)type WithKey:(NSString *)key withisSucess:(void (^)(BOOL isSucess))complementBack;
- (id)getObjectWithDataType:(JHLocalDataType)type andKey:(NSString *)key;

+ (instancetype)shareJHLocalDataManager;
@end
