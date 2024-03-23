#import "Tweak.h"

#define BOUNCE_HEIGHT 15

NSMutableArray <SBIconView *> *iconViews = [NSMutableArray array];

%hook SBIconView
%property (nonatomic, retain) NSTimer *bouncenotify_timer;

// When icon is loaded
-(void)didMoveToSuperview {
	%orig;
	[self bouncenotify_setupIfNeeded];
}

// When icon has moved
-(void)setEditing:(BOOL)editing {
	%orig;
	[self bouncenotify_setupIfNeeded];

	// reset the timers of all other icons, so they remain in sync
	if ([self.superview isKindOfClass:%c(SBDockIconListView)]) {
		for (SBIconView *iconView in [iconViews copy]) {
			[iconView bouncenotify_setupIfNeeded];
		}
	}
}

%new
-(void)bouncenotify_setupIfNeeded {
	// remove timer if exists
	if (self.bouncenotify_timer) {
		[self.bouncenotify_timer invalidate];
		self.bouncenotify_timer = nil;
	}

	// if dock icon
	if ([self.superview isKindOfClass:%c(SBDockIconListView)]) {
		// add to array if not already
		if (![iconViews containsObject:self]) [iconViews addObject:self];
		
		// set up timer
		self.bouncenotify_timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(bouncenotify_bounce) userInfo:nil repeats:YES];
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
