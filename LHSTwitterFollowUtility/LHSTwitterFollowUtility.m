//
//  LHSTwitterFollowUtility.m
//  LHSTwitterFollowUtility
//
//  Created by Daniel Loewenherz on 4/7/15.
//  Copyright (c) 2015 Lionheart Software LLC. All rights reserved.
//

#import "LHSTwitterFollowUtility.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <LHSCategoryCollection/UIApplication+LHSAdditions.h>
#import <LHSCategoryCollection/UIAlertController+LHSAdditions.h>
#import <LHSCategoryCollection/UIViewController+LHSAdditions.h>

@interface LHSTwitterFollowUtility ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation LHSTwitterFollowUtility

+ (instancetype)sharedInstance {
    static LHSTwitterFollowUtility *twitter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        twitter = [[LHSTwitterFollowUtility alloc] init];
    });
    return twitter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)followScreenName:(NSString *)screenName withAccountScreenName:(NSString *)accountScreenName callback:(void (^)())callback {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSString *identifier;
    for (ACAccount *account in [accountStore accountsWithAccountType:twitter]) {
        if ([account.username isEqualToString:accountScreenName]) {
            identifier = account.identifier;
            break;
        }
    }
    
    if (identifier) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ACAccount *account = [accountStore accountWithIdentifier:identifier];
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"]
                                                       parameters:@{@"screen_name": screenName, @"follow": @"true"}];
            [request setAccount:account];
            
            [UIApplication lhs_setNetworkActivityIndicatorVisible:YES];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                [UIApplication lhs_setNetworkActivityIndicatorVisible:NO];
                
                NSError *jsonError;
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert;

                    if (jsonError) {
                        alert = [UIAlertController lhs_alertViewWithTitle:NSLocalizedString(@"Error", nil)
                                                                  message:@"There was an unknown error."];
                    }
                    else if (response[@"errors"]) {
                        NSString *code = [NSString stringWithFormat:@"Twitter Error #%@", response[@"errors"][0][@"code"]];
                        NSString *message = [NSString stringWithFormat:@"%@", response[@"errors"][0][@"message"]];
                        
                        alert = [UIAlertController lhs_alertViewWithTitle:code
                                                                  message:message];
                    }
                    else {
                        alert = [UIAlertController lhs_alertViewWithTitle:NSLocalizedString(@"Success", nil)
                                                                  message:[NSString stringWithFormat:@"You are now following @%@!", screenName]];
                    }
                    
                    [alert lhs_addActionWithTitle:NSLocalizedString(@"OK", nil)
                                            style:UIAlertActionStyleDefault
                                          handler:nil];
                    
                    [[UIViewController lhs_topViewController] presentViewController:alert
                                                                           animated:YES
                                                                         completion:nil];
                });
                
                if (callback) {
                    callback();
                }
                
                self.actionSheet = nil;
            }];
        });
    }
}

- (void)followScreenName:(NSString *)screenName
                   point:(CGPoint)point
                    view:(UIView *)view
                callback:(void (^)())callback {
    
    self.username = screenName;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        void (^AccessGrantedBlock)(UIAlertController *) = ^(UIAlertController *loadingAlertController) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Twitter Account:", nil)
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:nil];
                
                NSMutableDictionary *accounts = [NSMutableDictionary dictionary];
                NSString *accountScreenName;
                for (ACAccount *account in [accountStore accountsWithAccountType:twitter]) {
                    accountScreenName = account.username;
                    [self.actionSheet addButtonWithTitle:accountScreenName];
                    [accounts setObject:account.identifier forKey:accountScreenName];
                }
                
                if (loadingAlertController) {
                    [loadingAlertController.parentViewController dismissViewControllerAnimated:YES completion:nil];
                }
                
                // Properly set the cancel button index
                [self.actionSheet addButtonWithTitle:@"Cancel"];
                self.actionSheet.cancelButtonIndex = self.actionSheet.numberOfButtons - 1;
                
                if ([accounts count] > 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.actionSheet showFromRect:(CGRect){point, {1, 1}}
                                                inView:view
                                              animated:YES];
                    });
                }
                else if ([accounts count] == 1) {
                    [self followScreenName:screenName withAccountScreenName:accountScreenName callback:callback];
                }
            });
        };
        
        if (twitter.accessGranted) {
            AccessGrantedBlock(nil);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *loadingAlertController = [UIAlertController lhs_alertViewWithTitle:@"Loading"
                                                                                              message:@"Requesting access to your Twitter accounts."];
                
                self.activityIndicator.center = CGPointMake(CGRectGetWidth(loadingAlertController.view.bounds)/2, CGRectGetHeight(loadingAlertController.view.bounds)-45);
                [self.activityIndicator startAnimating];
                [loadingAlertController.view addSubview:self.activityIndicator];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [accountStore requestAccessToAccountsWithType:twitter
                                                          options:nil
                                                       completion:^(BOOL granted, NSError *error) {
                                                           if (granted) {
                                                               AccessGrantedBlock(loadingAlertController);
                                                           }
                                                           else {
                                                               [loadingAlertController.parentViewController dismissViewControllerAnimated:YES completion:nil];

                                                               UIAlertController *alert = [UIAlertController lhs_alertViewWithTitle:NSLocalizedString(@"Error.", nil)
                                                                                                                            message:@"There was an error connecting to Twitter."];
                                                               [alert lhs_addActionWithTitle:@"OK"
                                                                                       style:UIAlertActionStyleDefault
                                                                                     handler:nil];
                                                               
                                                               [[UIViewController lhs_topViewController] presentViewController:alert animated:YES completion:nil];
                                                           }
                                                       }];
                });
            });
        }
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    self.actionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet && buttonIndex >= 0) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([[actionSheet title] isEqualToString:NSLocalizedString(@"Select Twitter Account:", nil)]) {
            [[LHSTwitterFollowUtility sharedInstance] followScreenName:self.username withAccountScreenName:buttonTitle callback:^{
                self.actionSheet = nil;
            }];
        }
    }
    self.actionSheet = nil;
}

@end
