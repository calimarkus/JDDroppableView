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

@synthesize delegate = _delegate;

- (id)init
{
    return [self initWithFrame: [UIApplication sharedApplication].keyWindow.frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mIsDragging = NO;
        mIsOverTarget = NO;
    }
    return self;
}

- (id) initWithDropTarget: (UIView *) target;
{
	self = [self init];
	if (self != nil) {
		mDropTarget = target;
	}
	return self;
}

#pragma mark touch handling

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

#pragma mark dragging logic

- (void) beginDrag
{
    mIsDragging = YES;
    
    if ([_delegate respondsToSelector: @selector(droppableViewBeganDragging:)]) {
        [_delegate droppableViewBeganDragging: self];
    };
	
	mOriginalPosition = self.center;
	
	[self changeSuperView];
}


- (void) dragAtPosition: (UITouch *) touch
{
	[UIView beginAnimations: @"drag" context: nil];
	self.center = [touch locationInView: self.superview];
	[UIView commitAnimations];
    
    if ([_delegate respondsToSelector: @selector(droppableViewDidMove:)]) {
        [_delegate droppableViewDidMove:self];
    }
	
    if (mDropTarget) {
        CGRect intersect = CGRectIntersection(self.frame, mDropTarget.frame);
        if (intersect.size.width > 10 || intersect.size.height > 10)
        {
            if (!mIsOverTarget)
            {
                mIsOverTarget = YES;
                
                if ([_delegate respondsToSelector: @selector(droppableView:enteredTarget:)]) {
                    [_delegate droppableView: self enteredTarget: mDropTarget];
                }
            }
        }
        else if (mIsOverTarget)
        {
            mIsOverTarget = NO;
            
            if ([_delegate respondsToSelector: @selector(droppableView:leftTarget:)]) {
                [_delegate droppableView: self leftTarget: mDropTarget];
            }
        }
    }
}


- (void) endDrag
{
    mIsOverTarget = NO;
    
    if([_delegate respondsToSelector: @selector(droppableViewEndedDragging:)]) {
        [_delegate droppableViewEndedDragging: self];
    }
	
    if (mDropTarget) {
        CGRect intersect = CGRectIntersection(self.frame, mDropTarget.frame);
        if (intersect.size.width > 10 || intersect.size.height > 10) {
            
            if([self handleDroppedView]) {
                mIsDragging = NO;
                return;
            }
        }
    }

	[self changeSuperView];
    mIsDragging = NO; // this needs to be after superview change
	
	[UIView beginAnimations: @"drag" context: nil];
	self.center = mOriginalPosition;
	[UIView commitAnimations];
}

- (BOOL) handleDroppedView
{
    if (mDropTarget && [_delegate respondsToSelector: @selector(shouldAnimateDroppableViewBack:wasDroppedOnTarget:)]) {
        return ![_delegate shouldAnimateDroppableViewBack: self wasDroppedOnTarget: mDropTarget];
    }
    
    return NO;
}

#pragma mark superview handling

- (void)willMoveToSuperview:(id)newSuperview
{
    if (!mIsDragging && [newSuperview isKindOfClass: [UIScrollView class]]) {
        mScrollView = newSuperview;
        mOuterView = mScrollView.superview;
    }
}

- (void) changeSuperView
{
    if (!mScrollView) {
        [self.superview bringSubviewToFront: self];
        return;
    }
    
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
