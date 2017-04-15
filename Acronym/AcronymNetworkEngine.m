//
//  AcronymNetworkEngine.m
//  Acronym
//
//  Created by Tarun Gupta on 2/22/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import "AcronymNetworkEngine.h"

#import "ANetworkOperation.h"

/** Private category of the AcronymNetworkEngine class */
@interface AcronymNetworkEngine ()
    
/** Operation queue object */
@property(nonatomic, retain) NSOperationQueue *operationQueue;

@end

#pragma mark -
@implementation AcronymNetworkEngine
    
+ (AcronymNetworkEngine *) sharedInstance {
    static dispatch_once_t onceToken;
    static AcronymNetworkEngine* networkEngineInstance;
    dispatch_once(&onceToken, ^{
        networkEngineInstance = [[self alloc] init];
    });
    return networkEngineInstance;
}
    
-(instancetype)init {
    self = [super init];
    if(self)
    {
        self.operationQueue = [NSOperationQueue new];
    }
    return self;
}
	
-(void)initiateNetworkRequest:(NSString *)searchString completion:(ANetworkCompletionBlock)callback {
    @autoreleasepool
    {
        ANetworkOperation *contentInfoOperation = [[ANetworkOperation alloc] initNetworkRequestOperation:searchString];
        
        [contentInfoOperation onCompletion:^(NSArray *data,NSError *error)
         {
             if(!contentInfoOperation.isCancelled)
             {
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     callback(data,error);
                 });
             }
         }];
        
        [self enqueueOperation:contentInfoOperation];
    }
}
    
    
#pragma mark - Operation Queue methods
-(void) cancelOperation:(ARequestType)requestType {
    for(ANetworkOperation *operation in self.operationQueue.operations)
    {
		if(operation.requestType ==  requestType){
            if (![operation isCancelled] || ![operation isFinished]) {
                [operation cancel];
                [operation endSessionAndCancelTasks];
            }
        }
    }
}
    
- (void) enqueueOperation:(ANetworkOperation *)operation {
    [self.operationQueue addOperation:operation];
}
    
- (void) cancelAllOperations {
    [self.operationQueue cancelAllOperations];
}
    
-(void)dealloc {
    self.operationQueue = nil;
}
    
    
@end
