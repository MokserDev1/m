//
//  SnakeGridView.m
//  Zmeyka
//

#import "SnakeGridView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SnakeGridView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.78 green:0.83 blue:0.71 alpha:1.0]; // Classic LCD greenish tint
        self.layer.borderColor = [UIColor colorWithRed:0.35 green:0.42 blue:0.30 alpha:1.0].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.cornerRadius = 6.0f;
        self.layer.masksToBounds = YES;
        _foodPosition = GridPointMake(-1, -1);
    }
    return self;
}

- (void)setSnakeSegments:(NSArray *)snakeSegments {
    _snakeSegments = [snakeSegments copy];
    [self setNeedsDisplay];
}

- (void)setFoodPosition:(GridPoint)foodPosition {
    _foodPosition = foodPosition;
    [self setNeedsDisplay];
}

- (void)setIsDead:(BOOL)isDead {
    _isDead = isDead;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    // 1. Draw subtle grid lines (iOS 6 retro arcade style)
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.72 green:0.77 blue:0.65 alpha:0.5].CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    for (int col = 0; col <= GRID_COLS; col++) {
        CGFloat x = col * CELL_SIZE;
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, GRID_ROWS * CELL_SIZE);
    }
    for (int row = 0; row <= GRID_ROWS; row++) {
        CGFloat y = row * CELL_SIZE;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, GRID_COLS * CELL_SIZE, y);
    }
    CGContextStrokePath(context);
    
    // 2. Draw Food (Glossy Apple/Berry)
    if (_foodPosition.x >= 0 && _foodPosition.y >= 0) {
        CGRect foodRect = CGRectMake(_foodPosition.x * CELL_SIZE + 2.0f,
                                     _foodPosition.y * CELL_SIZE + 2.0f,
                                     CELL_SIZE - 4.0f,
                                     CELL_SIZE - 4.0f);
        
        CGContextSaveGState(context);
        
        // Drop shadow for food
        CGContextSetShadowWithColor(context, CGSizeMake(1.0f, 1.5f), 2.0f, [UIColor colorWithWhite:0.2f alpha:0.5f].CGColor);
        
        // Red apple base
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0].CGColor);
        CGContextFillEllipseInRect(context, foodRect);
        
        // Food highlight (skeuomorphic sheen)
        CGRect highlightRect = CGRectMake(foodRect.origin.x + 3.0f, foodRect.origin.y + 2.0f, foodRect.size.width * 0.45f, foodRect.size.height * 0.35f);
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.65].CGColor);
        CGContextFillEllipseInRect(context, highlightRect);
        
        // Little leaf
        CGRect leafRect = CGRectMake(foodRect.origin.x + foodRect.size.width * 0.5f, foodRect.origin.y - 1.0f, 4.0f, 3.0f);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.2 green:0.6 blue:0.1 alpha:1.0].CGColor);
        CGContextFillEllipseInRect(context, leafRect);
        
        CGContextRestoreGState(context);
    }
    
    // 3. Draw Snake
    if (_snakeSegments && _snakeSegments.count > 0) {
        for (NSInteger i = _snakeSegments.count - 1; i >= 0; i--) {
            GridPoint pt;
            [[_snakeSegments objectAtIndex:i] getValue:&pt];
            
            CGRect segRect = CGRectMake(pt.x * CELL_SIZE + 1.0f,
                                        pt.y * CELL_SIZE + 1.0f,
                                        CELL_SIZE - 2.0f,
                                        CELL_SIZE - 2.0f);
            
            CGContextSaveGState(context);
            
            if (i == 0) {
                // Snake Head
                CGContextSetShadowWithColor(context, CGSizeMake(1.0f, 1.5f), 2.0f, [UIColor colorWithWhite:0.2 alpha:0.4].CGColor);
                
                UIColor *headColor = _isDead ?
                    [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0] :
                    [UIColor colorWithRed:0.15 green:0.45 blue:0.18 alpha:1.0];
                CGContextSetFillColorWithColor(context, headColor.CGColor);
                
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:segRect cornerRadius:5.0f];
                [path fill];
                
                // Head glossy sheen
                CGRect sheenRect = CGRectMake(segRect.origin.x + 2.0f, segRect.origin.y + 2.0f, segRect.size.width - 4.0f, (segRect.size.height - 4.0f) * 0.4f);
                CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
                [[UIBezierPath bezierPathWithRoundedRect:sheenRect cornerRadius:3.0f] fill];
                
                // Eyes
                CGFloat eyeSize = 3.5f;
                CGFloat eyeOffset = 3.5f;
                CGRect eye1, eye2;
                
                switch (_currentDirection) {
                    case DirectionUp:
                        eye1 = CGRectMake(segRect.origin.x + eyeOffset, segRect.origin.y + eyeOffset, eyeSize, eyeSize);
                        eye2 = CGRectMake(segRect.origin.x + segRect.size.width - eyeOffset - eyeSize, segRect.origin.y + eyeOffset, eyeSize, eyeSize);
                        break;
                    case DirectionDown:
                        eye1 = CGRectMake(segRect.origin.x + eyeOffset, segRect.origin.y + segRect.size.height - eyeOffset - eyeSize, eyeSize, eyeSize);
                        eye2 = CGRectMake(segRect.origin.x + segRect.size.width - eyeOffset - eyeSize, segRect.origin.y + segRect.size.height - eyeOffset - eyeSize, eyeSize, eyeSize);
                        break;
                    case DirectionLeft:
                        eye1 = CGRectMake(segRect.origin.x + eyeOffset, segRect.origin.y + eyeOffset, eyeSize, eyeSize);
                        eye2 = CGRectMake(segRect.origin.x + eyeOffset, segRect.origin.y + segRect.size.height - eyeOffset - eyeSize, eyeSize, eyeSize);
                        break;
                    case DirectionRight:
                    default:
                        eye1 = CGRectMake(segRect.origin.x + segRect.size.width - eyeOffset - eyeSize, segRect.origin.y + eyeOffset, eyeSize, eyeSize);
                        eye2 = CGRectMake(segRect.origin.x + segRect.size.width - eyeOffset - eyeSize, segRect.origin.y + segRect.size.height - eyeOffset - eyeSize, eyeSize, eyeSize);
                        break;
                }
                
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextFillEllipseInRect(context, eye1);
                CGContextFillEllipseInRect(context, eye2);
                
                // Pupils
                CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextFillEllipseInRect(context, CGRectInset(eye1, 1.0f, 1.0f));
                CGContextFillEllipseInRect(context, CGRectInset(eye2, 1.0f, 1.0f));
                
            } else {
                // Snake Body Segments
                CGFloat progress = (CGFloat)i / (CGFloat)_snakeSegments.count;
                // Subtle gradient from vibrant green to slightly yellowish green
                CGFloat r = 0.22 + progress * 0.1;
                CGFloat g = 0.58 - progress * 0.12;
                CGFloat b = 0.22;
                
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:r green:g blue:b alpha:1.0].CGColor);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:segRect cornerRadius:4.0f];
                [path fill];
                
                // Inner segment texture dot
                CGRect dotRect = CGRectInset(segRect, 5.0f, 5.0f);
                CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.25].CGColor);
                CGContextFillEllipseInRect(context, dotRect);
            }
            
            CGContextRestoreGState(context);
        }
    }
}

@end

