//
//  ANetworkOperation.h
//  Acronym
//
//  Created by Tarun Gupta on 2/24/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief block for response.
 * @param data for response data.
 * @param error for response error.
 */
typedef void (^AResponseBlock)(NSArray *data, NSError* error);

@interface ANetworkOperation : NSOperation <NSURLSessionDelegate> {
    @public
    BOOL        executing;
    BOOL        finished;
}

/*!
 * @typedef ARequestType
 * @brief A list of ARequestType types
 * @constant kAContentInfoRequest for content info request type.
 */
typedef NS_ENUM(NSUInteger, ARequestType)
{
    kAContentInfoRequest
};
    
/*!
 * @brief for Request type value.
 */
@property ARequestType requestType;
    
/*!
 * @brief for Error when request failed.
 */
@property (nonatomic, strong) NSError *error;

/*!
 * @brief for Response Block.
 */
@property (copy, nonatomic) AResponseBlock responseBlock;

/*!
 * @brief for Parsing the data and hold the object in array.
 */
@property (nonatomic, strong) NSArray *objectArray;


/**
 * @abstract Block return the network operation object with response
 * @param response for block completion.
 */
-(void) onCompletion:(AResponseBlock)response;

/**
 * @abstract return the operation to get network request content for searchString
 * @param searchString NSString for search id.
 * @return return ANetworkOperation object.
 */
- (ANetworkOperation *) initNetworkRequestOperation:(NSString *)searchString;
    
/**
 * @abstract ends the current session
 */
- (void)endSessionAndCancelTasks;
    
@end
