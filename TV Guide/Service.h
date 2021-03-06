//
//  Service.h
//  TV Guide
//
//  Created by Sai Tat Lam on 28/11/12.
//  Copyright (c) 2012 Bilue. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The TV Service object model class.
 * This class represents a service channel that contains a list of episodes.
 */
@interface Service : NSObject {
    NSString*           _serviceId;
    NSString*           _channelImage;
    NSString*           _serviceName;
    NSMutableArray*     _episodes;
}
@property (nonatomic, readonly) NSString*       serviceId;
@property (nonatomic, readonly) NSString*       channelImage;
@property (nonatomic, readonly) NSString*       serviceName;
@property (nonatomic, readonly) NSArray*        episodes;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
