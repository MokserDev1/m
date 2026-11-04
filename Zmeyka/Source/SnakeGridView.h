//
//  SnakeGridView.h
//  Zmeyka
//

#import <UIKit/UIKit.h>
#import "GameConstants.h"

@interface SnakeGridView : UIView

@property (nonatomic, copy) NSArray *snakeSegments;
@property (nonatomic, assign) GridPoint foodPosition;
@property (nonatomic, assign) Direction currentDirection;
@property (nonatomic, assign) BOOL isDead;

@end
