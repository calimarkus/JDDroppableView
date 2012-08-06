//
//  JDDroppableView.m
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "JDDroppableView.h"


@interface JDDroppableView (hidden)
- (void) beginDrag;
- (void) dragAtPosition: (UITouch *) touch;
- (void) endDrag;

- (void) changeSuperView;
- (BOOL) handleDroppedView;
@end



@implementation JDDroppableView

@synthesize delegate = mDelegate;

- (id) initWithScrollView: (UIScrollView *) aScrollView andDropTarget: (UIView *) target;
{
	self = [super init];
	if (self != nil) {
		
		mOuterView  = aScrollView.superview;
		mScrollView = aScrollView;
		
		mDropTarget = target;
        mIsOverTarget = NO;
	}
	return self;
}

#pragma touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self beginDrag];
	[self dragAtPosition: [touches anyObject]];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dragAtPosition: [touches anyObject]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	[self endDrag];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endDrag];
}

#pragma drag logic

- (void) beginDrag
{
    if ([mDelegate respondsToSelector: @selector(droppableViewBeganDragging:)]) {
        [mDelegate droppableViewBeganDragging: self];
    };
	
	mOriginalPosition = self.center;
	
	[self changeSuperView];
}


- (void) dragAtPosition: (UITouch *) touch
{
	[UIView beginAnimations: @"drag" context: nil];
	self.center = [touch locationInView: self.superview];
	[UIView commitAnimations];
	
	CGRect intersect = CGRectIntersection(self.frame, mDropTarget.frame);
	if (intersect.size.width > 10 || intersect.size.height > 10)
    {
        if (!mIsOverTarget)
        {
            mIsOverTarget = YES;
            
            if ([mDelegate respondsToSelector: @selector(droppableView:enteredTarget:)]) {
                [mDelegate droppableView: self enteredTarget: mDropTarget];
            }
        }
	}
    else if (mIsOverTarget)
    {
        mIsOverTarget = NO;
        
        if ([mDelegate respondsToSelector: @selector(droppableView:leftTarget:)]) {
            [mDelegate droppableView: self leftTarget: mDropTarget];
        }
	}
}


- (void) endDrag
{
    mIsOverTarget = NO;
    
    if([mDelegate respondsToSelector: @selector(droppableViewEndedDragging:)]) {
        [mDelegate droppableViewEndedDragging: self];
    }
	
	CGRect intersect = CGRectIntersection(self.frame, mDropTarget.frame);
	if (intersect.size.width > 10 || intersect.size.height > 10) {
		
        if([self handleDroppedView]) {
            return;
        }
	}

	[self changeSuperView];
	
	[UIView beginAnimations: @"drag" context: nil];
	self.center = mOriginalPosition;
	[UIView commitAnimations];
}

- (BOOL) handleDroppedView
{
	if ([mDelegate respondsToSelector: @selector(shouldAnimateDroppableViewBack:wasDroppedOnTarget:)]) {
        return ![mDelegate shouldAnimateDroppableViewBack: self wasDroppedOnTarget: mDropTarget];
    }
    
    return NO;
}


- (void) changeSuperView
{
	UIView * tmp = self.superview;
	
	[self removeFromSuperview];
	[mOuterView addSubview: self];
	
	mOuterView = tmp;
	
	// set new position
	
	CGPoint ctr = self.center;
	
	if (mOuterView == mScrollView) {
		
		ctr.x += mScrollView.frame.origin.x - mScrollView.contentOffset.x;
		ctr.y += mScrollView.frame.origin.y - mScrollView.contentOffset.y;
	} else {
		
		ctr.x -= mScrollView.frame.origin.x - mScrollView.contentOffset.x;
		ctr.y -= mScrollView.frame.origin.y - mScrollView.contentOffset.y;
	}

	self.center = ctr;
}


@end
