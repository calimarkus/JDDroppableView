//
//  JDDroppableView.h
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//


@protocol JDDroppableViewDelegate;

@interface JDDroppableView : UIView

@property (nonatomic, weak) UIView *dropTarget;
@property (nonatomic, weak) id<JDDroppableViewDelegate> delegate;

@property (nonatomic, assign) CGPoint returnPosition;
@property (nonatomic, assign) BOOL shouldUpdateReturnPosition;

- (id)initWithDropTarget:(UIView*)target;

@end


// JDDroppableViewDelegate

@protocol JDDroppableViewDelegate <NSObject>
@optional
// track dragging state
- (void)droppableViewBeganDragging:(JDDroppableView*)view;
- (void)droppableViewDidMove:(JDDroppableView*)view;
- (void)droppableViewEndedDragging:(JDDroppableView*)view;

// track target recognition
- (void)droppableView:(JDDroppableView*)view enteredTarget:(UIView*)target;
- (void)droppableView:(JDDroppableView*)view leftTarget:(UIView*)target;
- (BOOL)shouldAnimateDroppableViewBack:(JDDroppableView*)view wasDroppedOnTarget:(UIView*)target;
@end