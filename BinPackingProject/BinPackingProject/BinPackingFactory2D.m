//
//  BinPackingFactory2D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import "BinPackingFactory2D.h"
#import "GeneticAlgorithmFactory2D.h"

#define FF_STORAGE_WIDTH        10.0f
#define MAX_PERMUTATION_COUNT   500000

@implementation BinPackingFactory2D
{
    @private NSUInteger bestShelfNumber;
    @private NSUInteger permutationCount;
    @private NSUInteger numberOfUsedShelves;
    
    @private float storageWidth;
    @private float storageHeight;
    @private float storageOccupacy;
    @private float bestWidthUsagePercentage;
    
    @private NSMutableArray *rectangles;
    @private NSMutableArray *shelvesHeight;
    @private NSMutableArray *numberOfRectanglesOnShelf;
    @private NSMutableArray *currentlyUsedShelfWidth;
    
    @private NSMutableArray *bestShelvesHeight;
    @private NSMutableArray *bestShelvesUsedWidth;
    @private NSMutableArray *bestRectangleCombination;
}

@synthesize permutationCount;

- (id) initWithStorageWidth:(float)width 
                storageHeight:(float)height

{
    if (self = [super init]) 
    {        
        // Initialize class fields
        self->rectangles = [NSMutableArray new];
        self->shelvesHeight = [NSMutableArray new];
        self->currentlyUsedShelfWidth = [NSMutableArray new];
        self->numberOfRectanglesOnShelf = [NSMutableArray new];
        
        self->bestShelvesHeight = [NSMutableArray new];
        self->bestShelvesUsedWidth = [NSMutableArray new];
        self->bestRectangleCombination = [NSMutableArray new];
        
        self->storageWidth = width;
        self->storageHeight = height;
        
        self->storageOccupacy = 0.0f;
        self->numberOfUsedShelves = 0;
    }
    
    return self;
}

// PUBLIC: Next Fit Bin Packing Algorithm
- (NSUInteger) shelfNextFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles
{
    self->numberOfUsedShelves = 0;
    
    [self->shelvesHeight removeAllObjects];
    [self->currentlyUsedShelfWidth removeAllObjects];
    [self->rectangles removeAllObjects];
    [self->rectangles addObjectsFromArray:givenRectangles];
    
    float usedWidth = 0.0f;
    float currentHeight = 0.0f;
    NSUInteger currentShelfIndex = 0;
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        if (0 == [self->shelvesHeight count])
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            // 0 - width is smaller | 1 - height is smaller
            NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
            
            if (0 == smallerSide)
            {
                // Storage is empty, assign first item height to be
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                
                // Add rectangle to first shelf
                usedWidth += rectangle.size.height;
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:usedWidth]];
                
                currentHeight = rectangle.size.width;
                
                currentShelfIndex = [self->shelvesHeight count] - 1;
            }
            else
            {
                // Storage is empty, assign first item height to be
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                
                // Add rectangle to first shelf
                usedWidth += rectangle.size.width;
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:usedWidth]];
                
                currentHeight = rectangle.size.height;
                
                currentShelfIndex = [self->shelvesHeight count] - 1;
            }
        }
        else
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            // 0 - width is smaller | 1 - height is smaller
            NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
            
            if (0 == smallerSide)
            {
                BOOL foundShelfForRectangle = NO;
                
                if (rectangle.size.height <= currentHeight)
                {
                    if (usedWidth + rectangle.size.width <= self->storageWidth)
                    {
                        usedWidth += rectangle.size.width;
                        [self->currentlyUsedShelfWidth replaceObjectAtIndex:currentShelfIndex withObject:[NSNumber numberWithFloat:usedWidth]];
                        foundShelfForRectangle = YES;
                    }
                }
                else if (rectangle.size.width <= currentHeight)
                {
                    if (usedWidth + rectangle.size.height <= self->storageWidth)
                    {
                        usedWidth += rectangle.size.height;
                        [self->currentlyUsedShelfWidth replaceObjectAtIndex:currentShelfIndex withObject:[NSNumber numberWithFloat:usedWidth]];
                        foundShelfForRectangle = YES;
                    }
                }
                
                if (NO == foundShelfForRectangle)
                {
                    [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:usedWidth]];
                    [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                    
                    currentHeight = rectangle.size.width;
                    usedWidth = rectangle.size.height;
                    
                    currentShelfIndex += 1;
                }
            }
            else
            {
                BOOL foundShelfForRectangle = NO;
                
                if (rectangle.size.width <= currentHeight)
                {
                    if (usedWidth + rectangle.size.height <= self->storageWidth)
                    {
                        usedWidth += rectangle.size.height;
                        [self->currentlyUsedShelfWidth replaceObjectAtIndex:currentShelfIndex withObject:[NSNumber numberWithFloat:usedWidth]];
                        foundShelfForRectangle = YES;
                    }
                }
                else if (rectangle.size.height <= currentHeight)
                {
                    if (usedWidth + rectangle.size.width <= self->storageWidth)
                    {
                        usedWidth += rectangle.size.width;
                        [self->currentlyUsedShelfWidth replaceObjectAtIndex:currentShelfIndex withObject:[NSNumber numberWithFloat:usedWidth]];
                        foundShelfForRectangle = YES;
                    }
                }
                
                if (NO == foundShelfForRectangle)
                {
                    [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:usedWidth]];
                    [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                    
                    currentHeight = rectangle.size.height;
                    usedWidth = rectangle.size.width;
                    
                    currentShelfIndex += 1;
                }
            }
        }
    }
    
    self->numberOfUsedShelves = [self->shelvesHeight count];
    
    return self->numberOfUsedShelves;
}

// PUBLIC: First Fit Bin Packing Algorithm
- (NSUInteger) shelfFirstFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles
{
    self->numberOfUsedShelves = 0;
    
    [self->shelvesHeight removeAllObjects];
    [self->currentlyUsedShelfWidth removeAllObjects];
    [self->rectangles removeAllObjects];
    [self->rectangles addObjectsFromArray:givenRectangles];
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        // Check if there's any open shelf
        if (0 == [self->shelvesHeight count])
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            // 0 - width is smaller | 1 - height is smaller
            NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
            
            if (0 == smallerSide)
            {
                // Storage is empty, assign first item height to be
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                
                // Add rectangle to first shelf
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
            }
            else
            {
                // Storage is empty, assign first item height to be
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                
                // Add rectangle to first shelf
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
            }
        }
        else
        {
            BOOL foundFittingShelf = NO;
            BOOL isRectangleRotated = NO;
            NSInteger iterator = -1;
            NSInteger fittingShelfId = -1;
            
            for (NSNumber *shelfHeight in self->shelvesHeight)
            {
                // Try to determine which rectangle size is smaller
                // That side will be candidate to place it by width in case second side fits height of shelf
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (rectangle.size.height <= [shelfHeight floatValue] || rectangle.size.width <= [shelfHeight floatValue])
                {
                    if (0 == smallerSide)
                    {
                        if (rectangle.size.height <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.width + [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= self->storageWidth)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.height + [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= self->storageWidth)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                    }
                    else
                    {
                        // Rectangle height wasn't fitting to shelf height
                        // ROTATE the rectangle and try to fit it with width-height sides swapped
                        if (rectangle.size.width <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.height + [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= self->storageWidth)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.width + [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= self->storageWidth)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                            
                        }
                    }
                }
            }
            
            if (YES == foundFittingShelf)
            {
                // Add rectangle to fitting shelf
                // BE AWARE on fact that rectangle may be rotated
                float currentShelfWidth = [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue];
                
                if (NO == isRectangleRotated)
                {
                    [self->currentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                             withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.width)]];
                }
                else
                {
                    [self->currentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                             withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.height)]];
                }
            }
            else
            {
                // Fitting shelf not found, must add new one
                // NOTE: Should be aware of storage height, for v1 we won't pay attention to that
                
                // Place rectangle so that shorter side is height (flip it if needed)
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (0 == smallerSide)
                {
                    // Storage is empty, assign first item height to be
                    [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                    
                    // Add rectangle to first shelf
                    [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                }
                else
                {
                    // Storage is empty, assign first item height to be
                    [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                    
                    // Add rectangle to first shelf
                    [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                }

            }
        }
    }
    
    self->numberOfUsedShelves = [self->shelvesHeight count];
    
    return self->numberOfUsedShelves;
}

// PRIVATE: This method is being passed to GA as fitness function
// RETURNS: Number of used bins
NSUInteger (^ffFirstFitAlgorithm2D) (NSMutableArray *) = ^(NSMutableArray * givenRectangles)
{
    NSMutableArray *ffShelvesHeight = [NSMutableArray new];
    NSMutableArray *ffCurrentlyUsedShelfWidth = [NSMutableArray new];
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        // Check if there's any open shelf
        if (0 == [ffShelvesHeight count])
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            // 0 - width is smaller | 1 - height is smaller
            NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
            
            if (0 == smallerSide)
            {
                // Storage is empty, assign first item height to be
                [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                
                // Add rectangle to first shelf
                [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
            }
            else
            {
                // Storage is empty, assign first item height to be
                [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                
                // Add rectangle to first shelf
                [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
            }
        }
        else
        {
            BOOL foundFittingShelf = NO;
            BOOL isRectangleRotated = NO;
            NSInteger iterator = -1;
            NSInteger fittingShelfId = -1;
            
            for (NSNumber *shelfHeight in ffShelvesHeight)
            {
                // Try to determine which rectangle size is smaller
                // That side will be candidate to place it by width in case second side fits height of shelf
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (rectangle.size.height <= [shelfHeight floatValue] || rectangle.size.width <= [shelfHeight floatValue])
                {
                    if (0 == smallerSide)
                    {
                        if (rectangle.size.height <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.width + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.height + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                    }
                    else
                    {
                        // Rectangle height wasn't fitting to shelf height
                        // ROTATE the rectangle and try to fit it with width-height sides swapped
                        if (rectangle.size.width <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.height + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.width + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                            
                        }
                    }
                }
            }
            
            if (YES == foundFittingShelf)
            {
                // Add rectangle to fitting shelf
                // BE AWARE on fact that rectangle may be rotated
                float currentShelfWidth = [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue];
                
                if (NO == isRectangleRotated)
                {
                    [ffCurrentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                         withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.width)]];
                }
                else
                {
                    [ffCurrentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                         withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.height)]];
                }
            }
            else
            {
                // Fitting shelf not found, must add new one
                // NOTE: Should be aware of storage height, for v1 we won't pay attention to that
                
                // Place rectangle so that shorter side is height (flip it if needed)
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (0 == smallerSide)
                {
                    // Storage is empty, assign first item height to be
                    [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                    
                    // Add rectangle to first shelf
                    [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                }
                else
                {
                    // Storage is empty, assign first item height to be
                    [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                    
                    // Add rectangle to first shelf
                    [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                }
                
            }
        }
    }
    
    return [ffShelvesHeight count];
};

// PRIVATE: This method is being passed to GA as fitness function
// RETURNS: Number of used bins
NSUInteger (^ffFirstFitAlgorithm2DHelp) (NSMutableArray *, NSMutableArray *, NSMutableArray *) = ^(NSMutableArray * givenRectangles, NSMutableArray *ffCurrentlyUsedShelfWidth, NSMutableArray *ffShelvesHeight)
{
    //NSMutableArray *ffShelvesHeight = [NSMutableArray new];
    //NSMutableArray *ffCurrentlyUsedShelfWidth = [NSMutableArray new];
    
    [ffShelvesHeight removeAllObjects];
    [ffCurrentlyUsedShelfWidth removeAllObjects];
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        // Check if there's any open shelf
        if (0 == [ffShelvesHeight count])
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            // 0 - width is smaller | 1 - height is smaller
            NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
            
            if (0 == smallerSide)
            {
                // Storage is empty, assign first item height to be
                [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                
                // Add rectangle to first shelf
                [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
            }
            else
            {
                // Storage is empty, assign first item height to be
                [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                
                // Add rectangle to first shelf
                [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
            }
        }
        else
        {
            BOOL foundFittingShelf = NO;
            BOOL isRectangleRotated = NO;
            NSInteger iterator = -1;
            NSInteger fittingShelfId = -1;
            
            for (NSNumber *shelfHeight in ffShelvesHeight)
            {
                // Try to determine which rectangle size is smaller
                // That side will be candidate to place it by width in case second side fits height of shelf
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (rectangle.size.height <= [shelfHeight floatValue] || rectangle.size.width <= [shelfHeight floatValue])
                {
                    if (0 == smallerSide)
                    {
                        if (rectangle.size.height <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.width + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceedes shelf width
                            if ((rectangle.size.height + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                    }
                    else
                    {
                        // Rectangle height wasn't fitting to shelf height
                        // ROTATE the rectangle and try to fit it with width-height sides swapped
                        if (rectangle.size.width <= [shelfHeight floatValue])
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.height + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = YES;
                                
                                break;
                            }
                        }
                        else
                        {
                            iterator += 1;
                            fittingShelfId = iterator;
                            // At this moment we found shelf where current rectangle fits by height
                            // We should now check if adding this rectangle to that shelf will exceede shelf width
                            if ((rectangle.size.width + [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= (float)FF_STORAGE_WIDTH)
                            {
                                foundFittingShelf = YES;
                                isRectangleRotated = NO;
                                
                                break;
                            }
                            
                        }
                    }
                }
            }
            
            if (YES == foundFittingShelf)
            {
                // Add rectangle to fitting shelf
                // BE AWARE on fact that rectangle may be rotated
                float currentShelfWidth = [[ffCurrentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue];
                
                if (NO == isRectangleRotated)
                {
                    [ffCurrentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                             withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.width)]];
                }
                else
                {
                    [ffCurrentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                             withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.height)]];
                }
            }
            else
            {
                // Fitting shelf not found, must add new one
                // NOTE: Should be aware of storage height, for v1 we won't pay attention to that
                
                // Place rectangle so that shorter side is height (flip it if needed)
                // 0 - width is smaller | 1 - height is smaller
                NSUInteger smallerSide = (rectangle.size.width < rectangle.size.height ? 0 : 1);
                
                if (0 == smallerSide)
                {
                    // Storage is empty, assign first item height to be
                    [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                    
                    // Add rectangle to first shelf
                    [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                }
                else
                {
                    // Storage is empty, assign first item height to be
                    [ffShelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                    
                    // Add rectangle to first shelf
                    [ffCurrentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                }
                
            }
        }
    }

    return [ffShelvesHeight count];
};

// PUBLIC: Best Fit Bin Packing Algorithm
- (NSUInteger) shelfBestFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles
{
    self->numberOfUsedShelves = 0;
    
    [self->rectangles removeAllObjects];
    [self->rectangles addObjectsFromArray:givenRectangles];
    [self->shelvesHeight removeAllObjects];
    [self->currentlyUsedShelfWidth removeAllObjects];
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        BOOL shouldRotateRectangle = NO;
        NSRect rectangle = [wrappedRectangle rectValue];

        // Find id of shelf where to put new rectangle
        NSInteger shelfId = [self getIndexOfBestFitBin:rectangle shouldRotate:(&shouldRotateRectangle)];
        
        if (-1 == shelfId)
        {
            if (NO == shouldRotateRectangle)
            {
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
            }
            else
            {
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.width]];
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.height]];
            }
        }
        else
        {
            float currentShelfWidth = [[self->currentlyUsedShelfWidth objectAtIndex:shelfId] floatValue];
            
            if (NO == shouldRotateRectangle)
            {
                [self->currentlyUsedShelfWidth replaceObjectAtIndex:shelfId 
                                                         withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.width)]];
            }
            else
            {
                [self->currentlyUsedShelfWidth replaceObjectAtIndex:shelfId 
                                                         withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.height)]];
            }
        }
    }
    
    self->numberOfUsedShelves = [self->shelvesHeight count];
    
    return self->numberOfUsedShelves;
}

// PUBLIC: Detail Search Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) detailSearchAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles
{
    NSInteger size = [givenRectangles count];
    self->bestShelfNumber = INT_MAX;
    self->bestWidthUsagePercentage = 0.0f;
    self->permutationCount = 0;
    
    int indexes[size];
    
    for (NSUInteger i = 0; i < size; i++)
    {
        indexes[i] = i;
    }

    [self permutationArray2D:indexes 
           initialPosition:0 
               sizeOfArray:size 
                givenItems:givenRectangles];
    
    // Stored only for display informations
    self->permutationCount = permutationCount;
    
    float storageUsedArea = 0.0f;
    float storageUsedHeight = 0.0f;
    float storageArea = self->storageWidth * self->storageHeight;
    
    // Calculate actual area used by added rectangles
    for (NSValue *wrappedRectangle in self->bestRectangleCombination)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        storageUsedArea += rectangle.size.width * rectangle.size.height;
    }
    
    // Calculate storage used height
    for (NSNumber *height in self->bestShelvesHeight)
    {
        storageUsedHeight += [height floatValue];
    }
    
    // Print report
    NSLog(@"Used storage: %.2f%%", storageUsedArea / storageArea * 100.0f);
    NSLog(@"Used storage height: %f [%.2f%%]", storageUsedHeight, storageUsedHeight / self->storageHeight * 100.0f);
    NSLog(@"Number of shelves used: %lu", [self->bestShelvesHeight count]);
    
    self->numberOfUsedShelves = self->bestShelfNumber;
    
    return self->numberOfUsedShelves;
}

// PRIVATE: Recursive method which generates permutations with usage of backstepping algorithm
//          and calculates number of used bins with usage of FF
- (void) permutationArray2D:(int *)array 
          initialPosition:(int)position 
              sizeOfArray:(int)size 
               givenItems:(NSMutableArray *)givenRectangles
{
    
    if (position == size - 1)
        
    {
        NSMutableArray *newRectanglesPermutation = [NSMutableArray new];
        permutationCount += 1;
        
        for (NSUInteger i = 0; i < size; ++i)
        {
            // Generating items array based on indexes array
            [newRectanglesPermutation addObject:[givenRectangles objectAtIndex:array[i]]];
        }
        
        // Now we need to check for current item order how many bins we need
        NSUInteger shelfNumber = [self shelfFirstFitAlgorithmForGivenRectangles:newRectanglesPermutation];
        
        // Locate through all permutations best item combination and save it
        float currentWidthUsagePercentage = [self shelvesWidthUsagePercentage];
        
        if (shelfNumber <= self->bestShelfNumber && currentWidthUsagePercentage > self->bestWidthUsagePercentage)
        {
            [self->bestShelvesHeight removeAllObjects];
            [self->bestShelvesUsedWidth removeAllObjects];
            [self->bestRectangleCombination removeAllObjects];
            
            self->bestShelfNumber = shelfNumber;
            [self->bestShelvesHeight addObjectsFromArray:self->shelvesHeight];
            [self->bestShelvesUsedWidth addObjectsFromArray:self->currentlyUsedShelfWidth];
            [self->bestRectangleCombination addObjectsFromArray:newRectanglesPermutation];
            
            self->bestWidthUsagePercentage = currentWidthUsagePercentage;
        }

    }
    else
    {
        for (int i = position; i < size; i++)
        {
            swap2D(&array[position], &array[i]);
            
            [self permutationArray2D:array 
                   initialPosition:position+1 
                       sizeOfArray:size 
                        givenItems:givenRectangles];
            
            swap2D(&array[position], &array[i]);
        }
    }
}

// PRIVATE: Used for permutation generation
void swap2D(int *first, int *second)
{
    int temp = *first;
    *first = *second;
    *second = temp;
}

// PRIVATE: Calculate current shelves width usage in % in order to help
//          detail search algorithm to locate the best rectangle combination
- (float) shelvesWidthUsagePercentage
{
    float usedShelvesWidth = 0.0f;
    float totalShelvesWidth = [self->shelvesHeight count] * self->storageWidth;
    
    // Calculate total used width on all shelves
    for (NSNumber *usedWidth in self->currentlyUsedShelfWidth)
    {
        usedShelvesWidth += [usedWidth floatValue];
    }
    
    return usedShelvesWidth / totalShelvesWidth;
}

- (NSUInteger) searchWithUsageOfGeneticAlgorithmForRectangles:(NSMutableArray *)bpRectangles
                                    numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                          numberOfGenerations:(NSUInteger)generationsNumber 
                                     mutationFactorPercentage:(NSUInteger)mutationFactor 
                                                elitismFactor:(NSUInteger)elitismFactor 
                                      numberOfCrossoverPoints:(NSUInteger)crossoverPoints
{
    // Initialize GA factory object
    NSUInteger currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory2D *gaFactory = [[GeneticAlgorithmFactory2D alloc] initWithNumberOfUnitsInGeneration:unitNumber 
                                                                                                rectanglesArray:bpRectangles
                                                                                                  elitismFactor:elitismFactor
                                                                                                   storageWidth:self->storageWidth 
                                                                                                  storageHeight:self->storageHeight];
    // Create initial population and calculate costs
    [gaFactory generateInitialPopulation];
    [gaFactory calculateGenerationCost:ffFirstFitAlgorithm2D 
                   helpFitnessFunction:ffFirstFitAlgorithm2DHelp];
    
    // GA loop
    do
    {
        currentNumberOfGenerations += 1;
        
        // Do mating and mutation
        [gaFactory mate:elitismFactor];
        [gaFactory mutate:mutationFactor];
        
        // Swap generations and calculate costs
        [gaFactory generationSwap];
        [gaFactory calculateGenerationCost:ffFirstFitAlgorithm2D 
                       helpFitnessFunction:ffFirstFitAlgorithm2DHelp];
        
    } while (currentNumberOfGenerations < generationsNumber);
    
    self->numberOfUsedShelves = gaFactory.lowestCost;
    
    NSLog(@"Used storage: %.2f%%", gaFactory.usedStorage);
    NSLog(@"Used storage height: %f [%.2f%%]", gaFactory.usedStorageHeight, gaFactory.usedStorageHeightPercent);
    NSLog(@"Number of shelves used: %lu", self->numberOfUsedShelves);

    
    return self->numberOfUsedShelves;
}

// PRIVATE: Find best fitting bin for given item
// RETURNS: Best fitting bin index
- (NSInteger) getIndexOfBestFitBin:(NSRect)newRectangle 
                       shouldRotate:(BOOL *)rotation;
{
    NSInteger index = -1;
    float currentFilledShelfWidth = (float)INT_MAX;
    
    // Check if there's any open shelf
    if (0 == [self->shelvesHeight count])
    {
        // Place rectangle so that shorter side is height (flip it if needed)
        // 0 - width is smaller | 1 - height is smaller
        NSUInteger smallerSide = (newRectangle.size.width < newRectangle.size.height ? 0 : 1);
        
        if (0 == smallerSide)
        {
            *rotation = YES;
        }
        else
        {
            *rotation = NO;
        }
        
        index = -1;
    }
    else
    {
        BOOL foundFittingShelf = NO;
        // 0 - width is smaller | 1 - height is smaller
        NSUInteger smallerSide = (newRectangle.size.width < newRectangle.size.height ? 0 : 1);
        
        // Iterate through each shelf
        for (NSUInteger i = 0; i < [self->shelvesHeight count]; i++)
        {
            float currentShelfHeight = [[self->shelvesHeight objectAtIndex:i] floatValue];
            float currentShelfWidth = [[self->currentlyUsedShelfWidth objectAtIndex:i] floatValue];
            
            // Check if current rectangle's width or height fitts current shelf
            if (newRectangle.size.height <= currentShelfHeight || newRectangle.size.width <= currentShelfHeight)
            {
                if (0 == smallerSide)
                {
                    if (newRectangle.size.height <= currentShelfHeight)
                    {
                        if (currentShelfWidth + newRectangle.size.width <= currentFilledShelfWidth && currentShelfWidth + newRectangle.size.width <= self->storageWidth)
                        {
                            currentFilledShelfWidth = currentShelfWidth + newRectangle.size.width;
                            index = i;
                            
                            *rotation = NO;
                            foundFittingShelf = YES;
                        }
                    }
                    else
                    {
                        if (currentShelfWidth + newRectangle.size.height <= currentFilledShelfWidth && currentShelfWidth + newRectangle.size.height <= self->storageWidth)
                        {
                            currentFilledShelfWidth = currentShelfWidth + newRectangle.size.height;
                            index = i;
                            
                            *rotation = YES;
                            foundFittingShelf = YES;
                        }
                    }
                }
                else
                {
                    if (newRectangle.size.width <= currentShelfHeight)
                    {
                        if (currentShelfWidth + newRectangle.size.height <= currentFilledShelfWidth && currentShelfWidth + newRectangle.size.height <= self->storageWidth)
                        {
                            currentFilledShelfWidth = currentShelfWidth + newRectangle.size.height;
                            index = i;
                            
                            *rotation = YES;
                            foundFittingShelf = YES;
                        }
                    }
                    else
                    {
                        if (currentShelfWidth + newRectangle.size.width <= currentFilledShelfWidth && currentShelfWidth + newRectangle.size.width <= self->storageWidth)
                        {
                            currentFilledShelfWidth = currentShelfWidth + newRectangle.size.width;
                            index = i;
                            
                            *rotation = NO;
                            foundFittingShelf = YES;
                        }
                    }
                }
            }
        }
        
        if (NO == foundFittingShelf)
        {
            // Create new shelf
            if (0 == smallerSide)
            {
                *rotation = YES;
            }
            else
            {
                *rotation = NO;
            }
            
            index = -1;
        }
    }
    
    return index;
}

// PUBLIC: Calculate storage occupacy
- (void) showStorageUsageDetails
{
    float storageUsedArea = 0.0f;
    float storageUsedHeight = 0.0f;
    float storageArea = self->storageWidth * self->storageHeight;
    
    // Calculate actual area used by added rectangles
    for (NSValue *wrappedRectangle in self->rectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        storageUsedArea += rectangle.size.width * rectangle.size.height;
    }
    
    // Calculate storage used height
    for (NSNumber *height in self->shelvesHeight)
    {
        storageUsedHeight += [height floatValue];
    }
    
    // Print report
    NSLog(@"Used storage: %.2f%%", storageUsedArea / storageArea * 100.0f);
    NSLog(@"Used storage height: %f [%.2f%%]", storageUsedHeight, storageUsedHeight / self->storageHeight * 100.0f);
    NSLog(@"Number of shelves used: %lu", self->numberOfUsedShelves);
}

// PRIVATE: 

@end
