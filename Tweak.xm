// todo: maybe option to make it work in dnd (there is no icon badge)

#import "Tweak.h"

#define BOUNCE_HEIGHT 15
#define BOUNCE_INTERVAL 7.5

NSMutableArray <SBIconView *> *iconViews = [NSMutableArray array];
NSTimer *globalBounceTimer = nil;

BOOL kOnlyDockIcons = NO;

static void setUpGlobalTimer() {
	if (globalBounceTimer) {
		[globalBounceTimer invalidate];
		globalBounceTimer = nil;
	}

	globalBounceTimer = [NSTimer scheduledTimerWithTimeInterval:BOUNCE_INTERVAL repeats:YES block:^(NSTimer *timer) {
		for (SBIconView *iconView in [iconViews copy]) {
			[iconView bouncenotify_bounce];
		}
	}];
}

%hook SBIconView
// When icon has moved
-(void)setEditing:(BOOL)editing {
	%orig;
	[self bouncenotify_setupIfNeeded];
}

%new
-(void)bouncenotify_setupIfNeeded {
	if (!kOnlyDockIcons || [self.superview isKindOfClass:%c(SBDockIconListView)]) {
		// add to array if not already
		if (![iconViews containsObject:self]) {
			[iconViews addObject:self];
		}
	}
}

%new
-(void)bouncenotify_bounce {
	// don't bounce if no badge
	if (![self badgeString]) return;

	// don't bounce if editing
	if ([[[self _viewControllerForAncestor] valueForKey:@"_isEditing"] boolValue]) return;

	CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"];
	[bounce setDuration:0.2];
	[bounce setFromValue:[NSNumber numberWithFloat:self.layer.position.y]];
	[bounce setToValue:[NSNumber numberWithFloat:self.layer.position.y - BOUNCE_HEIGHT]];
	[bounce setAutoreverses:YES];
	[bounce setRepeatCount:1];
	[bounce setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[bounce setRemovedOnCompletion:YES];
	
	[self.layer addAnimation:bounce forKey:@"BounceNotify16"];
}
%end

%ctor {
	setUpGlobalTimer(); // call in future method loadPrefs
}
