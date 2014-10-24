//
//  JDDroppableView.m
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "JDDroppableView.h"


const CGFloat JDDroppableViewDefaultAnimationDuration = 0.33;

@interface JDDroppableView ()
@property (nonatomic, strong) NSMutableArray *dropTargets;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *activeDropTarget;
@property (nonatomic, weak) UIView *outerView;

@property (nonatomic, assign) BOOL didInitalizeReturnPosition;
@property (nonatomic, assign) BOOL isDragging;
@end


@implementation JDDroppableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithDropTarget:(UIView*)target;
{
	self = [super init];
	if (self != nil) {
        [self commonInit];
        [self addDropTarget:target];
	}
	return self;
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit;
{
    self.shouldUpdateReturnPosition = YES;
}

#pragma mark UIResponder (touch handling)

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesBegan:touches withEvent:event];
	[self beginDrag];
    [self dragAtPosition:[[touches anyObject] locationInView:self.superview]
                animated:YES];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesMoved:touches withEvent:event];
    [self dragAtPosition:[[touches anyObject] locationInView:self.superview]
                animated:NO];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];
	[self endDrag];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches withEvent:event];
	[self endDrag];
}

#pragma mark target managment

- (void)addDropTarget:(UIView*)target;
{
    // lazy initialization
    if (!self.dropTargets) {
        self.dropTargets = [NSMutableArray array];
    }
    
    // add target
    if ([target isKindOfClass:[UIView class]]) {
        [self.dropTargets addObject:target];
    }
}

- (void)removeDropTarget:(UIView*)target;
{
    [self.dropTargets removeObject:target];
}

- (void)replaceDropTargets:(NSArray*)targets;
{
    self.dropTargets = [[targets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[UIView class]];
    }]] mutableCopy];
}

#pragma mark dragging logic

- (void)beginDrag;
{
    // don't do anything, if scrollview is actively tracking atm
    for (UIGestureRecognizer *recognizer in self.scrollView.gestureRecognizers) {
        if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
            return;
        }
    }
    
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


- (void)dragAtPosition:(CGPoint)point animated:(BOOL)animated;
{
    if (!self.isDragging) return;
    
    // animate into new position
    [UIView animateWithDuration:animated?JDDroppableViewDefaultAnimationDuration:0.0 animations:^{
        self.center = point;
    }];
    
    // inform delegate
    if ([self.delegate respondsToSelector: @selector(droppableViewDidMove:)]) {
        [self.delegate droppableViewDidMove:self];
    }
	
    // check target contact
    if (self.dropTargets.count > 0) {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect viewRectInWindow = [self convertRect:self.bounds toView:rootView];
        for (UIView *dropTarget in self.dropTargets) {
            CGRect dropTargetRectInWindow = [dropTarget convertRect:dropTarget.bounds toView:rootView];
            CGRect intersect = CGRectIntersection(viewRectInWindow, dropTargetRectInWindow);
            BOOL didHitTarget = intersect.size.width > 10 || intersect.size.height > 10;
            
            // target was hit
            if (didHitTarget) {
                if (self.activeDropTarget != dropTarget)
                {
                    // inform delegate about leaving old target
                    if (self.activeDropTarget != nil) {
                        // inform delegate
                        if ([self.delegate respondsToSelector:@selector(droppableView:leftTarget:)]) {
                            [self.delegate droppableView:self leftTarget:self.activeDropTarget];
                        }
                    }
                    
                    // set new active target
                    self.activeDropTarget = dropTarget;
                    
                    // inform delegate about new target hit
                    if ([self.delegate respondsToSelector:@selector(droppableView:enteredTarget:)]) {
                        [self.delegate droppableView:self enteredTarget:self.activeDropTarget];
                    }
                    return;
                }
                
                // currently not over any target
            } else {
                if (self.activeDropTarget == dropTarget)
                {
                    // inform delegate
                    if ([self.delegate respondsToSelector:@selector(droppableView:leftTarget:)]) {
                        [self.delegate droppableView:self leftTarget:self.activeDropTarget];
                    }
                    
                    // reset active target
                    self.activeDropTarget = nil;
                    return;
                }
            }
        }
    }
}

- (void)endDrag
{
    if (!self.isDragging) return;
    
    // inform delegate
    if([self.delegate respondsToSelector: @selector(droppableViewEndedDragging:onTarget:)]) {
        [self.delegate droppableViewEndedDragging: self onTarget:self.activeDropTarget];
    }
	
    // check target drop
    BOOL shouldAnimateBack = YES;
    if (self.activeDropTarget != nil) {
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
        [UIView animateWithDuration:JDDroppableViewDefaultAnimationDuration animations:^{
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
