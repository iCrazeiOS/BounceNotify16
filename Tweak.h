#import <UIKit/UIKit.h>

@interface SBIconView : UIView
@property (nonatomic, retain) NSTimer *bouncenotify_timer;
-(void)bouncenotify_setupIfNeeded;
-(void)bouncenotify_bounce;
-(id)badgeString;
-(id)_viewControllerForAncestor;
@end
