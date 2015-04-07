//
//  LHSTwitterFollowUtility.h
//  LHSTwitterFollowUtility
//
//  Created by Daniel Loewenherz on 4/7/15.
//  Copyright (c) 2015 Lionheart Software LLC. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface LHSTwitterFollowUtility : NSObject <UIActionSheetDelegate>

+ (instancetype)sharedInstance;

- (void)followScreenName:(NSString *)screenName
   withAccountScreenName:(NSString *)accountScreenName
                callback:(void (^)())callback;

- (void)followScreenName:(NSString *)screenName
                   point:(CGPoint)point
                    view:(UIView *)view
                callback:(void (^)())callback;

@end
