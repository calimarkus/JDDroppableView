//
//  JDDroppableView.m
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "JDDroppableView.h"


@interface JDDroppableView ()
@property (nonatomic, weak) UIView *outerView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isOverTarget;
@property (nonatomic, assign) CGPoint originalPosition;

- (void) beginDrag;
- (void) dragAtPosition: (UITouch *) touch;
- (void) endDrag;

- (void) changeSuperView;
- (BOOL) handleDroppedView;
@end



@implementation JDDroppableView

- (id)initWithDropTarget:(UIView*)target;
{
	self = [super init];
	if (self != nil) {
		self.dropTarget = target;
	}
	return self;
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
    self.isDragging = YES;
    
    if ([self.delegate respondsToSelector: @selector(droppableViewBeganDragging:)]) {
        [self.delegate droppableViewBeganDragging: self];
    };
	
	self.originalPosition = self.center;
	
	[self changeSuperView];
}


- (void) dragAtPosition: (UITouch *) touch
{
	[UIView beginAnimations: @"drag" context: nil];
	self.center = [touch locationInView: self.superview];
	[UIView commitAnimations];
    
    if ([self.delegate respondsToSelector: @selector(droppableViewDidMove:)]) {
        [self.delegate droppableViewDidMove:self];
    }
	
    if (self.dropTarget) {
        CGRect intersect = CGRectIntersection(self.frame, self.dropTarget.frame);
        if (intersect.size.width > 10 || intersect.size.height > 10)
        {
            if (!self.isOverTarget)
            {
                self.isOverTarget = YES;
                
                if ([self.delegate respondsToSelector: @selector(droppableView:enteredTarget:)]) {
                    [self.delegate droppableView: self enteredTarget: self.dropTarget];
                }
            }
        }
        else if (self.isOverTarget)
        {
            self.isOverTarget = NO;
            
            if ([self.delegate respondsToSelector: @selector(droppableView:leftTarget:)]) {
                [self.delegate droppableView: self leftTarget: self.dropTarget];
            }
        }
    }
}


- (void) endDrag
{
    self.isOverTarget = NO;
    
    if([self.delegate respondsToSelector: @selector(droppableViewEndedDragging:)]) {
        [self.delegate droppableViewEndedDragging: self];
    }
	
    if (self.dropTarget) {
        CGRect intersect = CGRectIntersection(self.frame, self.dropTarget.frame);
        if (intersect.size.width > 10 || intersect.size.height > 10) {
            
            if([self handleDroppedView]) {
                self.isDragging = NO;
                return;
            }
        }
    }

	[self changeSuperView];
    self.isDragging = NO; // this needs to be after superview change
	
	[UIView beginAnimations: @"drag" context: nil];
	self.center = self.originalPosition;
	[UIView commitAnimations];
}

- (BOOL) handleDroppedView
{
    if (self.dropTarget && [self.delegate respondsToSelector: @selector(shouldAnimateDroppableViewBack:wasDroppedOnTarget:)]) {
        return ![self.delegate shouldAnimateDroppableViewBack: self wasDroppedOnTarget: self.dropTarget];
    }
    
    return NO;
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
