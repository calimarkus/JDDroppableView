//
//  JDDroppableView.m
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "JDDroppableView.h"


#define DROPPABLEVIEW_ANIMATION_DURATION 0.33

@interface JDDroppableView ()
@property (nonatomic, weak) UIView *outerView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL didInitalizeReturnPosition;

@property (nonatomic, assign) UIView *activeDropTarget;

- (void) beginDrag;
- (void) dragAtPosition: (UITouch *) touch;
- (void) endDrag;

- (void) changeSuperView;
@end



@implementation JDDroppableView

- (id)initWithDropTarget:(UIView*)target;
{
	self = [super init];
	if (self != nil) {
		self.dropTarget = target;
        self.shouldUpdateReturnPosition = YES;
	}
	return self;
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    self.shouldUpdateReturnPosition = YES;
}

#pragma mark UIResponder (touch handling)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	[self beginDrag];
	[self dragAtPosition: [touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self dragAtPosition: [touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
	[self endDrag];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
	[self endDrag];
}

#pragma mark dragging logic

- (void) beginDrag
{
    // remember state
    self.isDragging = YES;
    
    // inform delegate
    if ([self.delegate respondsToSelector: @selector(droppableViewBeganDragging:)]) {
        [self.delegate droppableViewBeganDragging: self];
    };
	
    // update return position
    if (!self.didInitalizeReturnPosition || self.shouldUpdateReturnPosition) {
        self.returnPosition = self.center;
        self.didInitalizeReturnPosition = YES;
    }
	
    // swap out of scrollView if needed
	[self changeSuperView];
}


- (void) dragAtPosition: (UITouch *) touch
{
    // animate into new position
	[UIView animateWithDuration:DROPPABLEVIEW_ANIMATION_DURATION animations:^{
        self.center = [touch locationInView: self.superview];
    }];
    
    // inform delegate
    if ([self.delegate respondsToSelector: @selector(droppableViewDidMove:)]) {
        [self.delegate droppableViewDidMove:self];
    }
	
    // check target contact
    if (self.dropTarget) {
        CGRect intersect = CGRectIntersection(self.frame, self.dropTarget.frame);
        BOOL didHitTarget = intersect.size.width > 10 || intersect.size.height > 10;
        
        // target was hit
        if (didHitTarget) {
            if (self.activeDropTarget != self.dropTarget)
            {
                self.activeDropTarget = self.dropTarget;
                
                // inform delegate
                if ([self.delegate respondsToSelector:@selector(droppableView:enteredTarget:)]) {
                    [self.delegate droppableView:self enteredTarget:self.activeDropTarget];
                }
            }
            
        // currently not over any target
        } else {
            if (self.activeDropTarget != nil)
            {
                // inform delegate
                if ([self.delegate respondsToSelector:@selector(droppableView:leftTarget:)]) {
                    [self.delegate droppableView:self leftTarget:self.activeDropTarget];
                }
                
                // reset active target
                self.activeDropTarget = nil;
            }
        }
    }
}


- (void) endDrag
{
    // inform delegate
    if([self.delegate respondsToSelector: @selector(droppableViewEndedDragging:)]) {
        [self.delegate droppableViewEndedDragging: self];
    }
	
    // check target drop
    BOOL shouldAnimateBack = YES;
    if (self.dropTarget && self.activeDropTarget != nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldAnimateDroppableViewBack:wasDroppedOnTarget:)]) {
            shouldAnimateBack = [self.delegate shouldAnimateDroppableViewBack:self wasDroppedOnTarget:self.activeDropTarget];
        }
    }

    // insert in scrollview again, if needed
    if (shouldAnimateBack) {
        [self changeSuperView];
    }
    
    // update state
    // this needs to be after superview change
    self.isDragging = NO;
    self.activeDropTarget = nil;
	
    // animate back to original position
    if (shouldAnimateBack) {
        [UIView animateWithDuration:DROPPABLEVIEW_ANIMATION_DURATION animations:^{
            self.center = self.returnPosition;
        }];
    }
}

#pragma mark superview handling

- (void)willMoveToSuperview:(id)newSuperview
{
    if (!self.isDragging && [newSuperview isKindOfClass: [UIScrollView class]]) {
        self.scrollView = newSuperview;
        self.outerView = self.scrollView.superview;
    }
}

- (void) changeSuperView
{
    if (!self.scrollView) {
        [self.superview bringSubviewToFront: self];
        return;
    }
    
	UIView * tmp = self.superview;
	
	[self removeFromSuperview];
	[self.outerView addSubview: self];
	
	self.outerView = tmp;
	
	// set new position
	
	CGPoint ctr = self.center;
	
	if (self.outerView == self.scrollView) {
		ctr.x += self.scrollView.frame.origin.x - self.scrollView.contentOffset.x;
		ctr.y += self.scrollView.frame.origin.y - self.scrollView.contentOffset.y;
	} else {
		ctr.x -= self.scrollView.frame.origin.x - self.scrollView.contentOffset.x;
		ctr.y -= self.scrollView.frame.origin.y - self.scrollView.contentOffset.y;
	}

	self.center = ctr;
}


@end
