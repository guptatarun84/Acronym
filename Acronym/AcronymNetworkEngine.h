//
//  AcronymNetworkEngine.h
//  Acronym
//
//  Created by Tarun Gupta on 2/22/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ANetworkCompletionBlock)(NSArray* data, NSError* error);

@interface AcronymNetworkEngine : NSObject

/** Method returning network engine instance */
+ (AcronymNetworkEngine *) sharedInstance;
    
/** Method for fetching search content acronym meaning */
-(void)initiateNetworkRequest:(NSString *)searchString completion:(ANetworkCompletionBlock)callback;
    
/** Cancel all the operations that are in queue */
- (void) cancelAllOperations;
    
@end
