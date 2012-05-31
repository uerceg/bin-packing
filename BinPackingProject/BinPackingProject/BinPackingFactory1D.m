//
//  BinPackingFactory1D.m
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import "BinPackingFactory1D.h"
#import "PSOAlgorithmFactory1D.h"
#import "GeneticAlgorithmFactory1D.h"

#define FF_BIN_CAPACITY         1.0f
#define MAX_PERMUTATION_COUNT   500000

@implementation BinPackingFactory1D 
{
    @private BOOL binsLimited;
    
    @private float binCapacity;
    
    @private NSUInteger bestBinNumber;
    @private NSUInteger maxNumberOfBins;
    @private NSUInteger permutationCount;
    @private NSUInteger numberOfUsedBins;
    
    @private NSMutableArray *bins;
    @private NSMutableArray *items;
    @private NSMutableArray *itemsBest;
    @private NSMutableArray *itemsAndItsBins;
    @private NSMutableArray *itemsAndItsBinsBest;
    @private NSMutableArray *bestItemsCombination;
}

@synthesize permutationCount;

// INIT: Custom Initializator
- (id) initWithBinCapacity:(float)initBinCapacity 
                  binLimit:(NSUInteger)binLimit 
                 isLimited:(BOOL)isLimited
{
    if (self = [super init]) 
    {        
        // Initialize bins and items array
        self->binsLimited = isLimited;
        self->maxNumberOfBins = binLimit;
        self->binCapacity = initBinCapacity;
        
        self->bins = [NSMutableArray new];
        self->items = [NSMutableArray new];
        self->itemsBest = [NSMutableArray new];
        self->itemsAndItsBins = [NSMutableArray new];
        self->itemsAndItsBinsBest = [NSMutableArray new];
        self->bestItemsCombination = [NSMutableArray new];
    }
    
    return self;
}

// PUBLIC: Next Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) nextFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    float currentBinUsedSpace = 0.0f;
    NSUInteger currentBinUsedIndex = 0;
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber *item in self->items)
    {
        // If no item has been added to bin, add it
        if (0 == [self->bins count])
        {
            currentBinUsedSpace = [item floatValue];
            [self->bins addObject:[NSNumber numberWithFloat:[item floatValue]]];
            currentBinUsedIndex = [self->bins count] - 1;
        }
        else
        {
            // Check if current item fits to currently opened bin
            // If yes, add it to that bin
            // If not, close current bin, open new one and add current item to it
            float currentItemValue = [item floatValue];
            
            if (currentItemValue + currentBinUsedSpace <= self->binCapacity)
            {
                [self->bins replaceObjectAtIndex:currentBinUsedIndex withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinUsedSpace)]];
                currentBinUsedSpace += currentItemValue;
            }
            else
            {
                currentBinUsedSpace = currentItemValue;
                [self->bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
                currentBinUsedIndex = [self->bins count] - 1;
            }
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PRIVATE: Block implementation of Next Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Previously used in GA, currenly not being used
NSUInteger (^ffNextFitAlgorithm1DFF1) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    float currentBinUsedSpace = 0.0f;
    NSUInteger currentBinUsedIndex = 0;
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber *item in givenItems)
    {
        if (0 == [bins count])
        {
            currentBinUsedSpace = [item floatValue];
            [bins addObject:[NSNumber numberWithFloat:[item floatValue]]];
            currentBinUsedIndex = [bins count] - 1;
        }
        else
        {
            float currentItemValue = [item floatValue];
            
            if (currentItemValue + currentBinUsedSpace <= (float)FF_BIN_CAPACITY)
            {
                [bins replaceObjectAtIndex:currentBinUsedIndex withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinUsedSpace)]];
                currentBinUsedSpace += currentItemValue;
            }
            else
            {
                currentBinUsedSpace = currentItemValue;
                [bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
                currentBinUsedIndex = [bins count] - 1;
            }
        }
    }
    
    return [bins count];
};

// PRIVATE: Block implementation of Next Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Currently used in GA
NSUInteger (^ffNextFitAlgorithm1DFF2) (NSMutableArray *, NSMutableArray *) = ^(NSMutableArray * givenItems, NSMutableArray * bins)
{
    float currentBinUsedSpace = 0.0f;
    NSUInteger currentBinUsedIndex = 0;
    
    [bins removeAllObjects];
    
    for (NSNumber *item in givenItems)
    {
        if (0 == [bins count])
        {
            currentBinUsedSpace = [item floatValue];
            [bins addObject:[NSNumber numberWithFloat:[item floatValue]]];
            currentBinUsedIndex = [bins count] - 1;
        }
        else
        {
            float currentItemValue = [item floatValue];
            
            if (currentItemValue + currentBinUsedSpace <= (float)FF_BIN_CAPACITY)
            {
                [bins replaceObjectAtIndex:currentBinUsedIndex withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinUsedSpace)]];
                currentBinUsedSpace += currentItemValue;
            }
            else
            {
                currentBinUsedSpace = currentItemValue;
                [bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
                currentBinUsedIndex = [bins count] - 1;
            }
        }
    }
    
    return [bins count];
};

// PUBLIC: Next Fit Decreasing Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) nextFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    float currentBinUsedSpace = 0.0f;
    NSUInteger currentBinUsedIndex = 0;
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *sortedArray = [self->items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:sortedArray];
    
    for (NSNumber *item in sortedItems)
    {
        // If no item has been added to bin, add it
        if (0 == [self->bins count])
        {
            currentBinUsedSpace = [item floatValue];
            [self->bins addObject:[NSNumber numberWithFloat:[item floatValue]]];
            currentBinUsedIndex = [self->bins count] - 1;
        }
        else
        {
            // Check if current item fits to currently opened bin
            // If yes, add it to that bin
            // If not, close current bin, open new one and add current item to it
            float currentItemValue = [item floatValue];
            
            if (currentItemValue + currentBinUsedSpace <= self->binCapacity)
            {
                [self->bins replaceObjectAtIndex:currentBinUsedIndex withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinUsedSpace)]];
                currentBinUsedSpace += currentItemValue;
            }
            else
            {
                currentBinUsedSpace = currentItemValue;
                [self->bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
                currentBinUsedIndex = [self->bins count] - 1;
            }
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PUBLIC: First Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) firstFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    float currentItemValue;
    float currentBinCapacity;
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber* item in self->items) 
    {
        BOOL foundPlaceForItem = NO;
        currentItemValue = [item floatValue];
        
        // If there's no bins, add new one and place item in it
        if (0 == [self->bins count])
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            // Find from all existing bins first bin where current item fits
            for (NSUInteger i = 0; i < [self->bins count]; i++)
            {
                currentBinCapacity = [[self->bins objectAtIndex:i] floatValue];
                
                if (currentItemValue + currentBinCapacity <= self->binCapacity)
                {
                    [self->bins replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinCapacity)]];
                    foundPlaceForItem = YES;
                    break;
                }
            }
            
            // If item fits nowhere, open new bin and add item to it
            if (NO == foundPlaceForItem)
            {
                [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            }
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Previously used in GA, currenly not being used
NSUInteger (^ffFirstFitAlgorithm1DFF1) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    float currentItemValue;
    float currentBinCapacity;
    
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber *item in givenItems) 
    {
        BOOL foundPlaceForItem = NO;
        currentItemValue = [item floatValue];
        
        if (0 == [bins count])
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            for (NSUInteger i = 0; i < [bins count]; i++)
            {
                currentBinCapacity = [[bins objectAtIndex:i] floatValue];
                
                if (currentItemValue + currentBinCapacity <= (float)FF_BIN_CAPACITY)
                {
                    [bins replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinCapacity)]];
                    foundPlaceForItem = YES;
                    break;
                }
            }
            
            if (NO == foundPlaceForItem)
            {
                [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            }
        }
    }
    
    return [bins count];
};

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Currently used in GA
NSUInteger (^ffFirstFitAlgorithm1DFF2) (NSMutableArray *, NSMutableArray *) = ^(NSMutableArray * givenItems, NSMutableArray * bins)
{
    float currentItemValue;
    float currentBinCapacity;
    
    [bins removeAllObjects];
    
    for (NSNumber *item in givenItems) 
    {
        BOOL foundPlaceForItem = NO;
        currentItemValue = [item floatValue];
        
        if (0 == [bins count])
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            for (NSUInteger i = 0; i < [bins count]; i++)
            {
                currentBinCapacity = [[bins objectAtIndex:i] floatValue];
                
                if (currentItemValue + currentBinCapacity <= (float)FF_BIN_CAPACITY)
                {
                    [bins replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinCapacity)]];
                    foundPlaceForItem = YES;
                    break;
                }
            }
            
            if (NO == foundPlaceForItem)
            {
                [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            }
        }
    }
    
    return [bins count];

};

// PUBLIC: First Fit Decreasing Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) firstFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    float currentItemValue;
    float currentBinCapacity;
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *sortedArray = [self->items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:sortedArray];
    
    for (NSNumber* item in sortedItems) 
    {
        BOOL foundPlaceForItem = NO;
        currentItemValue = [item floatValue];
        
        // If there's no bins, add new one and place item in it
        if (0 == [self->bins count])
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            // Find from all existing bins first bin where current item fits
            for (NSUInteger i = 0; i < [self->bins count]; i++)
            {
                currentBinCapacity = [[self->bins objectAtIndex:i] floatValue];
                
                if (currentItemValue + currentBinCapacity <= self->binCapacity)
                {
                    [self->bins replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinCapacity)]];
                    foundPlaceForItem = YES;
                    break;
                }
            }
            
            // If item fits nowhere, open new bin and add item to it
            if (NO == foundPlaceForItem)
            {
                [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            }
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Usles for GA, because it makes no sence to use this as fitness function for same input array of items (/slap)
NSUInteger (^ffFirstFitDecreasingAlgorithm1D) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    float currentItemValue;
    float currentBinCapacity;
    
    NSMutableArray *bins = [NSMutableArray new];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *sortedArray = [givenItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:sortedArray];

    for (NSNumber *item in sortedItems) 
    {
        BOOL foundPlaceForItem = NO;
        currentItemValue = [item floatValue];
        
        if (0 == [bins count])
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            for (NSUInteger i = 0; i < [bins count]; i++)
            {
                currentBinCapacity = [[bins objectAtIndex:i] floatValue];
                
                if (currentItemValue + currentBinCapacity <= (float)FF_BIN_CAPACITY)
                {
                    [bins replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:(currentItemValue + currentBinCapacity)]];
                    foundPlaceForItem = YES;
                    break;
                }
            }
            
            if (NO == foundPlaceForItem)
            {
                [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            }
        }
    }
    
    return [bins count];
};

// PUBLIC: Best Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) bestFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber* item in self->items) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = [self getIndexOfBestFitBin:currentItemValue];
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
        else
        {
            [self->bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[self->bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:(itemPlacementIndex + 1)]];
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PRIVATE: Block implementation of Best Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Previously used in GA, currenly not being used
NSUInteger (^ffBestFitAlgorithm1DFF1) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        float nearestToFill = 0.0f;
        float currentItemValue = [item floatValue];
        NSInteger itemPlacementIndex = -1;
        
        // Get index of bin where current item should be placed
        
        // If no bins exist index -1 is returned indicating that new bin should be created
        if (0 == [bins count])
        {

        }
        else
        {
            // Iterate through all current bins and check in which bin current item fits the bes
            for (NSInteger i = 0; i < [bins count]; i++)
            {
                float algCurrentItemValue = [[bins objectAtIndex:i] floatValue];
                
                if (algCurrentItemValue + currentItemValue > nearestToFill && algCurrentItemValue + currentItemValue <= (float)FF_BIN_CAPACITY)
                {
                    itemPlacementIndex = i;
                    nearestToFill = algCurrentItemValue + currentItemValue;
                }
            }
        }
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            [bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
        }
    }
    
    return [bins count];

};

// PRIVATE: Block implementation of Best Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Currently used in GA
NSUInteger (^ffBestFitAlgorithm1DFF2) (NSMutableArray *, NSMutableArray *) = ^(NSMutableArray * givenItems, NSMutableArray * bins)
{
    [bins removeAllObjects];
    
    for (NSNumber* item in givenItems) 
    {
        float nearestToFill = 0.0f;
        float currentItemValue = [item floatValue];
        NSInteger itemPlacementIndex = -1;
        
        // Get index of bin where current item should be placed
        
        // If no bins exist index -1 is returned indicating that new bin should be created
        if (0 == [bins count])
        {
            
        }
        else
        {
            // Iterate through all current bins and check in which bin current item fits the bes
            for (NSInteger i = 0; i < [bins count]; i++)
            {
                float algCurrentItemValue = [[bins objectAtIndex:i] floatValue];
                
                if (algCurrentItemValue + currentItemValue > nearestToFill && algCurrentItemValue + currentItemValue <= (float)FF_BIN_CAPACITY)
                {
                    itemPlacementIndex = i;
                    nearestToFill = algCurrentItemValue + currentItemValue;
                }
            }
        }
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            [bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
        }
    }
    
    return [bins count];
    
};

// PUBLIC: Best Fit Decreasing Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) bestFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *sortedArray = [self->items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:sortedArray];
    
    for (NSNumber* item in sortedItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = [self getIndexOfBestFitBin:currentItemValue];
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
        else
        {
            [self->bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[self->bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:(itemPlacementIndex + 1)]];
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PUBLIC: Worst Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) worstFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber* item in self->items) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = [self getIndexOfWorstFitBin:currentItemValue];
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
        else
        {
            [self->bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[self->bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:(itemPlacementIndex + 1)]];
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;
}

// PRIVATE: Block implementation of Worst Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Previously used in GA, currenly not being used
NSUInteger (^ffWorstFitAlgorithm1DFF1) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = -1; // = [self getIndexOfWorstFitBin:currentItemValue];
        
        // Determine worst bin index
        float nearestToFill = 1.0f;
        
        // If no bins exist index -1 is returned indicating that new bin should be created
        if (0 == [bins count])
        {
            
        }
        else
        {
            // Iterate through all current bins and check in which bin current item fits the bes
            for (NSUInteger i = 0; i < [bins count]; i++)
            {
                float algCurrentItemValue = [[bins objectAtIndex:i] floatValue];
                
                if (algCurrentItemValue + currentItemValue < nearestToFill && algCurrentItemValue + currentItemValue <= (float)FF_BIN_CAPACITY)
                {
                    itemPlacementIndex = i;
                    nearestToFill = algCurrentItemValue + currentItemValue;
                }
            }
        }
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            [bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
        }
    }
    
    return [bins count];
};

// PRIVATE: Block implementation of Worst Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
// NOTE: Currently used in GA
NSUInteger (^ffWorstFitAlgorithm1DFF2) (NSMutableArray *, NSMutableArray *) = ^(NSMutableArray * givenItems, NSMutableArray * bins)
{
    [bins removeAllObjects];
    
    for (NSNumber* item in givenItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = -1; // = [self getIndexOfWorstFitBin:currentItemValue];
        
        // Determine worst bin index
        float nearestToFill = 1.0f;
        
        // If no bins exist index -1 is returned indicating that new bin should be created
        if (0 == [bins count])
        {
            
        }
        else
        {
            // Iterate through all current bins and check in which bin current item fits the bes
            for (NSUInteger i = 0; i < [bins count]; i++)
            {
                float algCurrentItemValue = [[bins objectAtIndex:i] floatValue];
                
                if (algCurrentItemValue + currentItemValue < nearestToFill && algCurrentItemValue + currentItemValue <= (float)FF_BIN_CAPACITY)
                {
                    itemPlacementIndex = i;
                    nearestToFill = algCurrentItemValue + currentItemValue;
                }
            }
        }
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            [bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
        }
    }
    
    return [bins count];
};

// PUBLIC: Worst Fit Decreasing Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) worstFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *sortedArray = [self->items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:sortedArray];
    
    for (NSNumber* item in sortedItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        NSInteger itemPlacementIndex = [self getIndexOfWorstFitBin:currentItemValue];
        
        // If index remained -1, add new item
        // If not, there's space in some bin and add current item to that existing bin
        if (-1 == itemPlacementIndex)
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentItemValue]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
        else
        {
            [self->bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[self->bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:(itemPlacementIndex + 1)]];
        }
    }
    
    self->numberOfUsedBins = [self->bins count];
    
    return self->numberOfUsedBins;

}

// PUBLIC: Harmonics Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) harmonicAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
                         algorithmGranulation:(NSUInteger)granularity
{
    NSUInteger usedBins = 0;
    NSMutableArray *harmonics = [NSMutableArray new];
    NSMutableArray *harmonicsMultiplier = [NSMutableArray new];
    NSMutableArray *itemsInHarmonics = [NSMutableArray new];
    
    [harmonics addObject:[NSNumber numberWithFloat:1.0f]];
    
    // Initialize harmonics structures
    for (NSUInteger i = 0; i < granularity; i++)
    {
        [harmonics addObject:[NSNumber numberWithFloat:((float)1/(2+i))]];
        [harmonicsMultiplier addObject:[NSNumber numberWithInteger:(i+1)]];
        [itemsInHarmonics addObject:[NSNumber numberWithInteger:0]];
    }
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    // Determine which item belongs to which harmonic
    for (NSNumber *item in self->items)
    {
        for (NSUInteger i = 0; i < granularity; i++)
        {
            if ([item floatValue] <= [[harmonics objectAtIndex:i] floatValue] && [item floatValue] > [[harmonics objectAtIndex:(i+1)] floatValue])
            {
                NSUInteger currentNumberOfTheseHarmonics = [[itemsInHarmonics objectAtIndex:i] intValue];
                currentNumberOfTheseHarmonics += 1;
                [itemsInHarmonics replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:currentNumberOfTheseHarmonics]];
                
                break;
            }
        }
    }
    
    // Calculate number of used bins
    for (NSUInteger i = 0; i < [itemsInHarmonics count]; i++)
    {
        NSUInteger itemsInThisHarmonic = [[itemsInHarmonics objectAtIndex:i] intValue];
        
        usedBins += ceilf((float)(itemsInThisHarmonic) / [[harmonicsMultiplier objectAtIndex:i] floatValue]);
    }
    
    self->numberOfUsedBins = usedBins;
    
    return usedBins;
}

// PUBLIC: Detail Search Bin Packing Algorithm
// RETURNS: Number of used bins
// NOTE: For number of items > 11, CPU is cursing this application
- (NSUInteger) detailSearchAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
{
    NSInteger size = [givenItems count];
    
    self->bestBinNumber = INT_MAX;
    self->permutationCount = 0;
    
    int indexes[size];
    
    for (NSUInteger i = 0; i < size; i++)
    {
        indexes[i] = i;
    }
    
    [self permutationArray1D:indexes 
           initialPosition:0 
               sizeOfArray:size 
                givenItems:givenItems 
           initBinCapacity:self->binCapacity];
    
    // Stored only for display informations
    self->permutationCount = permutationCount;
    
    self->numberOfUsedBins = self->bestBinNumber;
    
    return self->numberOfUsedBins;
}

// PUBLIC: Bin Packing algorithm with usage of Genetic Algorithm
// RETURNS: Number of bins found in optimal item scheduling
// NOTE: Fitness function choice: 0 - Next Fit
//                                1 - First Fit
//                                2 - Best Fit
//                                3 - Worst Fit
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor 
                                           elitismFactor:(NSUInteger)elitismFactor 
                                 numberOfCrossoverPoints:(NSUInteger)crossoverPoints 
                                fitnessFunctionSelection:(NSUInteger)choice
{
    // Initialize GA factory object
    NSUInteger currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory1D *gaFactory = [[GeneticAlgorithmFactory1D alloc] initWithNumberOfUnitsInGeneration:unitNumber 
                                                                                                     itemsArray:bpItems 
                                                                                                  elitismFactor:elitismFactor];
    // Create initial population and calculate costs
    [gaFactory generateInitialPopulation];
    
    switch (choice)
    {
        case 0: [gaFactory calculateGenerationCostWithFitnessFunction:ffNextFitAlgorithm1DFF2];
            break;
        case 1: [gaFactory calculateGenerationCostWithFitnessFunction:ffFirstFitAlgorithm1DFF2];
            break;
        case 2: [gaFactory calculateGenerationCostWithFitnessFunction:ffBestFitAlgorithm1DFF2];
            break;
        case 3: [gaFactory calculateGenerationCostWithFitnessFunction:ffWorstFitAlgorithm1DFF2];
            break;
        default: [gaFactory calculateGenerationCostWithFitnessFunction:ffBestFitAlgorithm1DFF2];
            break;
    }
    
    // GA loop
    do
    {
        currentNumberOfGenerations += 1;
        
        // Do mating and mutation
        [gaFactory mate:crossoverPoints];
        [gaFactory mutate:mutationFactor];
        
        // Swap generations and calculate costs
        [gaFactory generationSwap];
        
        switch (choice)
        {
            case 0: [gaFactory calculateGenerationCostWithFitnessFunction:ffNextFitAlgorithm1DFF2];
                break;
            case 1: [gaFactory calculateGenerationCostWithFitnessFunction:ffFirstFitAlgorithm1DFF2];
                break;
            case 2: [gaFactory calculateGenerationCostWithFitnessFunction:ffBestFitAlgorithm1DFF2];
                break;
            case 3: [gaFactory calculateGenerationCostWithFitnessFunction:ffWorstFitAlgorithm1DFF2];
                break;
            default: [gaFactory calculateGenerationCostWithFitnessFunction:ffBestFitAlgorithm1DFF2];
                break;
        }
        
    } while (currentNumberOfGenerations < generationsNumber);
    
    [self->bins removeAllObjects];
    [self->bins addObjectsFromArray:gaFactory.bins];
    
    self->numberOfUsedBins = [self->bins count];
    return gaFactory.lowestCost;
}

// PRIVATE: Recursive method which generates permutations with usage of backstepping algorithm
//          and calculates number of used bins with usage of FF
- (void) permutationArray1D:(int *) array 
          initialPosition:(int) position 
              sizeOfArray:(int) size 
               givenItems:(NSMutableArray *)givenItems 
          initBinCapacity:(NSUInteger)initBinCapacity

{
    
    if (position == size - 1)
        
    {
        NSMutableArray *newItemsPermutation = [NSMutableArray array];
        self->permutationCount += 1;
        
        for (NSUInteger i = 0; i < size; ++i)
        {
            // Generating items array based on indexes array
            [newItemsPermutation addObject:[givenItems objectAtIndex:array[i]]];
        }
        
        // Now we need to check for current item order how many bins we need
        NSUInteger numberOfBins = [self firstFitAlgorithm1DForGivenItems:newItemsPermutation];
        
        // Locate through all permutations best item combination and save it
        if (numberOfBins < self->bestBinNumber)
        {
            self->bestBinNumber = numberOfBins;
            
            // Save best bin fit for items
            [self->itemsBest removeAllObjects];
            [self->itemsAndItsBinsBest removeAllObjects];
            
            [self->itemsBest addObjectsFromArray:newItemsPermutation];
            [self->itemsAndItsBinsBest addObjectsFromArray:self->itemsAndItsBins];
        }
    }
    else
    {
        for (int i = position; i < size; i++)
        {
            swap1D(&array[position], &array[i]);
            
            [self permutationArray1D:array 
                   initialPosition:position+1 
                       sizeOfArray:size 
                        givenItems:givenItems 
                   initBinCapacity:initBinCapacity];
            
            swap1D(&array[position], &array[i]);
        }
    }
}

// PRIVATE: Used for permutation generation
void swap1D(int *first, int *second)
{
    int temp = *first;
    *first = *second;
    *second = temp;
}

// PRIVATE: Find best fitting bin for given item
// RETURNS: Best fitting bin index
- (NSInteger) getIndexOfBestFitBin:(float)newItemValue
{
    NSInteger index = -1;
    float nearestToFill = 0.0f;
    
    // If no bins exist index -1 is returned indicating that new bin should be created
    if (0 == [self->bins count])
    {
        return index;
    }
    else
    {
        // Iterate through all current bins and check in which bin current item fits the bes
        for (NSUInteger i = 0; i < [self->bins count]; i++)
        {
            float currentItemValue = [[self->bins objectAtIndex:i] floatValue];
            
            if (currentItemValue + newItemValue > nearestToFill && currentItemValue + newItemValue <= self->binCapacity)
            {
                index = i;
                nearestToFill = currentItemValue + newItemValue;
            }
        }
    }
    
    return index;
}

// PRIVATE: Find worst fitting bin for given item
// RETURNS: Worst fitting bin index
- (NSInteger) getIndexOfWorstFitBin:(float)newItemValue
{
    NSInteger index = -1;
    float nearestToFill = 1.0f;
    
    // If no bins exist index -1 is returned indicating that new bin should be created
    if (0 == [self->bins count])
    {
        return index;
    }
    else
    {
        // Iterate through all current bins and check in which bin current item fits the bes
        for (NSUInteger i = 0; i < [self->bins count]; i++)
        {
            float currentItemValue = [[self->bins objectAtIndex:i] floatValue];
            
            if (currentItemValue + newItemValue < nearestToFill && currentItemValue + newItemValue <= self->binCapacity)
            {
                index = i;
                nearestToFill = currentItemValue + newItemValue;
            }
        }
    }
    
    return index;
}

// PUBLIC: Calculate storage occupacy
- (void) showStorageUsageDetails
{
    float wastedLenght = 0.0f;
    
    for (NSNumber *binContent in self->bins)
    {
        wastedLenght += self->binCapacity - [binContent floatValue];
    }
    
    float totalLength = self->binCapacity * self->maxNumberOfBins;
    
    // Print report if there are bins information (in harmonics case there isn't, fix maybe)
    if (0 != [self->bins count])
    {
        NSLog(@"Used storage: %.2f%%", self->numberOfUsedBins * self->binCapacity / totalLength * 100.0f);
        NSLog(@"Wasted length of bins: %.2f/%.2f [%.2f%%]", wastedLenght, self->numberOfUsedBins * self->binCapacity, wastedLenght / (self->numberOfUsedBins * self->binCapacity) * 100.0f);
    }
    
    NSLog(@"Number of bins used: %lu", self->numberOfUsedBins);
}

// PRIVATE: Write how items are packed in bins
- (void) showHowItemsArePackedInBins
{
    for (NSUInteger i = 0; i < [self->itemsAndItsBins count]; i++)
    {
        NSLog(@"Item %.2f is placed in bin #%d.", [[self->items objectAtIndex:i] floatValue], [[self->itemsAndItsBins objectAtIndex:i] intValue]);
    }
}

// PRIVATE: Write how items are best packed in bins
- (void) showHowItemsArePackedBestInBins
{
    for (NSUInteger i = 0; i < [self->itemsAndItsBinsBest count]; i++)
    {
        NSLog(@"Item %.2f is placed in bin #%d.", [[self->itemsBest objectAtIndex:i] floatValue], [[self->itemsAndItsBinsBest objectAtIndex:i] intValue]);
    }
}

@end