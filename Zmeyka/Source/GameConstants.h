//
//  GameConstants.h
//  Zmeyka
//
//  iPhone 4S screen: 320 x 480 pt (640 x 960 px Retina)
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define GRID_COLS 15
#define GRID_ROWS 15
#define CELL_SIZE 18.0f // 15 * 18 = 270 pt width & height

typedef NS_ENUM(NSInteger, Direction) {
    DirectionNone = 0,
    DirectionUp,
    DirectionDown,
    DirectionLeft,
    DirectionRight
};

typedef struct {
    int x;
    int y;
} GridPoint;

static inline GridPoint GridPointMake(int x, int y) {
    GridPoint p;
    p.x = x;
    p.y = y;
    return p;
}

static inline BOOL GridPointEqualToPoint(GridPoint p1, GridPoint p2) {
    return (p1.x == p2.x && p1.y == p2.y);
}
