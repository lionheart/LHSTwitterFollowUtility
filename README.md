LHSTwitterFollowUtility
=============================

This utility gives you a quick and easy way to let users of your app follow a twitter account.

![image](http://i.imgur.com/NL0Fg5B.png)

Installation
------------

Cocoapods is the recommended installation method. Just add this line to your Podfile.

    pod 'LHSTwitterFollowUtility'

Usage
-----

Integrating LHSTwitterFollowUtility into your project is pretty straightforward. Just import the header file, get the shared instance, and utilize the followScreenName method.

Here's a code snippet for utilizing this in a tableview:

```objc

#import <LHSTwitterFollowUtility/LHSTwitterFollowUtility.h>

...


- (void)handleRowSelectionAtIndexPath:(NSIndexPath *)indexPath {

case TSSettingsSectionMisc:
            switch ((TSSettingsMiscRowType)indexPath.row) {
                case TSSettingsMiscFollowRow: {
                    UIView *view = [self.tableView cellForRowAtIndexPath:indexPath];
                    CGPoint point = view.center;
                    
                    [[LHSTwitterFollowUtility sharedInstance] followScreenName:@"TweetSeekerApp"
                                                                         point:point
                                                                          view:view
                                                                      callback:nil];
                    break;
                }
                    
                case TSSettingsMiscSubscribeRow: {
                    break;
                }

                case TSSettingsMiscFeedbackRow: {
                    break;
                }
                    
                case TSSettingsMiscRateRow: {
                    break;
                }
                    
                case TSSettingsMiscAppsRow: {
                    break;
                }
            }
            break;
}

...

```

The above implementation lets you be flexible in how your implementation of LHSTwitterFollowUtility. Feel free to implement it as you please!
