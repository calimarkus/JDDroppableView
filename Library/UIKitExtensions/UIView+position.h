//
//  UIView+position.h
//
//  Created by Tyler Neylon on 3/19/10.
//  Copyleft 2010 Bynomial.
//

@interface UIView (position)

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

// Setting these modifies the origin but not the size.
@property (nonatomic) CGFloat frameRight;
@property (nonatomic) CGFloat frameBottom;

@end
