//
//  BinPackingFactory2D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import "BinPackingFactory2D.h"

@implementation BinPackingFactory2D
{
    @private NSUInteger numberOfUsedShelves;
    
    @private CGFloat storageWidth;
    @private CGFloat storageHeight;
    @private CGFloat storageOccupacy;
    
    @private NSMutableArray *rectangles;
    @private NSMutableArray *shelvesHeight;
    @private NSMutableArray *numberOfRectanglesOnShelf;
    @private NSMutableArray *currentlyUsedShelfWidth;
}

- (id) initWithStorageWidth:(CGFloat)width 
                storageHeight:(CGFloat)height

{
    if (self = [super init]) 
    {        
        // Initialize class fields
        self->rectangles = [NSMutableArray new];
        self->shelvesHeight = [NSMutableArray new];
        self->currentlyUsedShelfWidth = [NSMutableArray new];
        self->numberOfRectanglesOnShelf = [NSMutableArray new];
        
        self->storageWidth = width;
        self->storageHeight = height;
        
        self->storageOccupacy = 0.0f;
        self->numberOfUsedShelves = 0;
    }
    
    return self;
}

// PUBLIC: First Fit Bin Packing Algorithm
- (void) firstFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles
{
    [self->rectangles removeAllObjects];
    [self->rectangles addObjectsFromArray:givenRectangles];
    
    for (NSValue *wrappedRectangle in givenRectangles)
    {
        NSRect rectangle = [wrappedRectangle rectValue];
        
        // Check if there's any open shelf
        if (0 == [self->shelvesHeight count])
        {
            // Place rectangle so that shorter side is height (flip it if needed)
            
            // Storage is empty, assign first item height to be 
            [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
            
            // Add rectangle to first shelf
            [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
        }
        else
        {
            BOOL foundFittingShelf = NO;
            NSUInteger iterator = -1;
            NSUInteger fittingShelfId = -1;
            
            for (NSNumber *shelfHeight in self->shelvesHeight)
            {
                if (rectangle.size.height <= [shelfHeight floatValue])
                {
                    iterator += 1;
                    fittingShelfId = iterator;
                    // At this moment we found shelf where current rectangle fits by height
                    // We should now check if adding this rectangle to that shelf will exceede shelf width
                    if ((rectangle.size.width + [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue]) <= self->storageWidth)
                    {
                        foundFittingShelf = YES;
                        
                        break;
                    }
                }
            }
            
            if (YES == foundFittingShelf)
            {
                // Add rectangle to fitting shelf
                CGFloat currentShelfWidth = [[self->currentlyUsedShelfWidth objectAtIndex:fittingShelfId] floatValue];
                [self->currentlyUsedShelfWidth replaceObjectAtIndex:fittingShelfId 
                                                         withObject:[NSNumber numberWithFloat:(currentShelfWidth + rectangle.size.width)]];
            }
            else
            {
                // Fitting shelf not found, must add new one
                // NOTE: Should be aware of storage height, for v1 we won't pay attention to that
                [self->shelvesHeight addObject:[NSNumber numberWithFloat:rectangle.size.height]];
                
                // Add rectangle to first shelf
                [self->currentlyUsedShelfWidth addObject:[NSNumber numberWithFloat:rectangle.size.width]];
            }
        }
    }
    
    [self showStorageUsageDetails];
}

// PRIVATE (FOR NOW): Calculate storage occupacy
- (void) showStorageUsageDetails
{
    CGFloat storageUsedArea = 0.0f;
    CGFloat storageUsedHeight = 0.0f;
    CGFloat storageArea = self->storageWidth * self->storageHeight;
    
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
    NSLog(@"Used storage height: %.2f%%", storageUsedHeight / self->storageHeight * 100.0f);
    NSLog(@"Number of shelves used: %lu", [self->shelvesHeight count]);
}

// PRIVATE: 

@end
