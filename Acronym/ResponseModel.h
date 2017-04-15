//
//  ResponseModel.h
//  Acronym
//
//  Created by Tarun Gupta on 2/24/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseModel : NSObject

@property(nonatomic,strong)NSMutableArray *contentArray;


/*!
 * This method set properties values from given dictionary
 */
-(void)setParametersValueFromDict:(NSDictionary *)tagInfoDict;
    
@end
