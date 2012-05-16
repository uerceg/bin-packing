//
//  BinPackingFactory1D.m
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import "BinPackingFactory1D.h"
#import "GeneticAlgorithmFactory1D.h"

#define MAX_PERMUTATION_COUNT   500000

@implementation BinPackingFactory1D 
{
    float binCapacity;
    NSMutableArray *bins;
    NSMutableArray *items;
    NSMutableArray *itemsBest;
    NSMutableArray *itemsAndItsBins;
    NSMutableArray *itemsAndItsBinsBest;
    NSMutableArray *bestItemsCombination;
}

// Custom Initializator
- (id) initWithBinCapacity:(float)initBinCapacity
{
    if (self = [super init]) 
    {
        // Initialize bin capacity
        self->binCapacity = initBinCapacity;
        
        // Initialize bins and items array
        self->bins = [NSMutableArray new];
        self->items = [NSMutableArray new];
        self->itemsBest = [NSMutableArray new];
        self->itemsAndItsBins = [NSMutableArray new];
        self->itemsAndItsBinsBest = [NSMutableArray new];
        self->bestItemsCombination = [NSMutableArray new];
    }
    
    return self;
}

// PUBLIC: First Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (int) firstFitAlgorithm:(NSMutableArray *)givenItems
{
    float currentBinUsedSpace;
    
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber* item in self->items) 
    {
        float currentItemValue = [item floatValue];
        
        // Check if item fits in current bin
        if (currentBinUsedSpace + currentItemValue <= self->binCapacity) 
        {
            // Add item to bin
            currentBinUsedSpace += currentItemValue;
            
            // Check if we reached last item in array
            // If YES, it needs to be added to bin
            if ([self->items lastObject] == item) 
            {
                [self->bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
            }
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
        else
        {
            [self->bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
            
            currentBinUsedSpace = currentItemValue;
            
            // Memorize in which bin that item is stored
            [self->itemsAndItsBins addObject:[NSNumber numberWithInt:[self->bins count]]];
        }
    }
    
    // Write down items combination as the best one
    //[self showHowItemsArePackedInBins];
    
    return [self->bins count];
}

// PRIVATE: Fitness function first fit
// Used as "delegate" method which is being sent to GA as fitness function
int (^ffFirstFitAlgorithm) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    float currentBinUsedSpace = 0.0f;
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Check if item fits in current bin
        if (currentBinUsedSpace + currentItemValue <= 1.0f) 
        {
            // Add item to bin
            currentBinUsedSpace += currentItemValue;
            
            // Check if we reached last item in array
            // If YES, it needs to be added to bin
            if ([givenItems lastObject] == item) 
            {
                [bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
            }
        }
        else
        {
            [bins addObject:[NSNumber numberWithFloat:currentBinUsedSpace]];
            
            currentBinUsedSpace = currentItemValue;
        }
    }
    
    return (int)[bins count];
};

// PUBLIC: Best Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (int) bestFitAlgorithm:(NSMutableArray *)givenItems
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
        int itemPlacementIndex = [self getIndexOfBestFitBin:currentItemValue];
        
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
    
    // Write down items combination as the best one
    //[self showHowItemsArePackedInBins];
    
    return [self->bins count];
}

// PRIVATE: Fitness function best fit
// Used as "delegate" method which is being sent to GA as fitness function
int (^ffBestFitAlgorithm) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        float currentItemValue = [item floatValue];
        
        // Get index of bin where current item should be placed
        int itemPlacementIndex = -1;
        float nearestToFill = 0.0f;
        
        // If no bins exist index -1 is returned indicating that new bin should be created
        if (0 == [bins count])
        {

        }
        else
        {
            // Iterate through all current bins and check in which bin current item fits the bes
            for (int i = 0; i < [bins count]; i++)
            {
                float algCurrentItemValue = [[bins objectAtIndex:(NSUInteger)i] floatValue];
                
                if (algCurrentItemValue + currentItemValue > nearestToFill && algCurrentItemValue + currentItemValue <= 1.0f)
                {
                    itemPlacementIndex = i;
                    nearestToFill = algCurrentItemValue + currentItemValue;
                }
            }
        }
        
        if (-1 == itemPlacementIndex)
        {
            [bins addObject:[NSNumber numberWithFloat:currentItemValue]];
        }
        else
        {
            [bins replaceObjectAtIndex:(NSUInteger)itemPlacementIndex withObject:[NSNumber numberWithFloat:(currentItemValue + [[bins objectAtIndex:(NSUInteger)itemPlacementIndex] floatValue])]];
        }
    }
    
    // Write down items combination as the best one
    //[self showHowItemsArePackedInBins];
    
    return (int)[bins count];

};

// PUBLIC: Detail Search Bin Packing Algorithm
// RETURNS: Number of used bins
- (int) detailSearchAlgorithm:(NSMutableArray *)givenItems
{
    int permutationCount = 0;
    int bestBinNumber = INT_MAX;
    int estimatedOptimalBinNumber = 0;
    
    float allItemsValueSum = 0;
    
    for (NSNumber *item in givenItems)
    {
        allItemsValueSum += [item floatValue];
    }
    
    estimatedOptimalBinNumber = (int)allItemsValueSum;
    
    // Sorting items in asceding order
    NSArray *arrayOfGivenItems = [NSArray arrayWithArray:givenItems];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedArrayOfGivenItems = [arrayOfGivenItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    int numberOfItems = [sortedArrayOfGivenItems count];
    
    // Allocating memory for 1 permutation
    float *permutedIndexes = malloc(numberOfItems * sizeof(float));
    
    // Placing indexes in array
    // Indexes are the thing which is going to be permuted
    // and new permutations will be genereted based on them
    for (int index = 0; index < numberOfItems; ++index)
    {
        permutedIndexes[index] = index;
    }
    
    numberOfItems -= 1;
    
    do 
    {
        NSMutableArray *newItemsPermutation = [NSMutableArray array];
        
        for (int i = 0; i <= numberOfItems; ++i)
        {
            // Generating items array based on indexes array
            [newItemsPermutation addObject:[sortedArrayOfGivenItems objectAtIndex:permutedIndexes[i]]];
        }
        
        // Now we need to check for current item order how many bins we need
        int numberOfBins = [self bestFitAlgorithm:newItemsPermutation];
        
        // Locate through all permutations best item combination and save it
        if (numberOfBins < bestBinNumber)
        {
            bestBinNumber = numberOfBins;
            
            // Save best bin fit for items
            [self->itemsBest removeAllObjects];
            [self->itemsAndItsBinsBest removeAllObjects];
            
            [self->itemsBest addObjectsFromArray:newItemsPermutation];
            [self->itemsAndItsBinsBest addObjectsFromArray:self->itemsAndItsBins];
            
            // If estimated otpimal bin number reached, break the algorithm to save CPU usage time
            if (bestBinNumber == estimatedOptimalBinNumber)
            {
                break;
            }
        }
        
        // In while condition permutation of indexes is done
    } while ((permutedIndexes = [self makeIndexPermutation:permutedIndexes:numberOfItems]) && ++permutationCount < MAX_PERMUTATION_COUNT);
    
    // Release allocated memory
    free(permutedIndexes);
    
    // Write down items combination as the best one
    [self showHowItemsArePackedBestInBins];
    
    return bestBinNumber;
}

// PUBLIC: Bin Packing algorithm with usage of Genetic Algorithm
- (int) searchWithUsageOfGeneticAlgorithm:(NSMutableArray *)givenItems:(int)numberOfUnitsInGeneration:(int)numberOfGenerations
{
    int currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory1D *gaFactory = [[GeneticAlgorithmFactory1D alloc] initWithItemArray:givenItems:numberOfUnitsInGeneration];
    
    [gaFactory generateInitialPopulation];
    [gaFactory calculateGenerationCost:ffFirstFitAlgorithm];
    
    do
    {
        currentNumberOfGenerations += 1;
        
        [gaFactory mate];
        [gaFactory mutate:5];
        
        [gaFactory generationSwap];
        [gaFactory calculateGenerationCost:ffFirstFitAlgorithm];
        
    } while (currentNumberOfGenerations < numberOfGenerations);
    
    return gaFactory.lowestCost;
}

// PRIVATE: Make permutation of item indexes
// RETURNS: New combination of indexes
- (float *) makeIndexPermutation:(float *)permutation:(const int)size 
{
    // Slide down the array looking for where we're smaller than the next guy
    int positionOne;
    int positionTwo;
    
    for (positionOne = size - 1; permutation[positionOne] >= permutation[positionOne + 1] && positionOne > -1; --positionOne);
    
    // Uf this doesn't occur, we've finished our permutations
    // the array is reversed: (1, 2, 3, 4) => (4, 3, 2, 1)
    if (positionOne == -1)
    {
        return NULL;
    }
    
    assert(positionOne >= 0 && positionOne <= size);
    
    // Slide down the array looking for a bigger number than what we found before
    for (positionTwo = size; permutation[positionTwo] <= permutation[positionOne] && positionTwo > 0; --positionTwo);
    
    assert(positionTwo >= 0 && positionTwo <= size);
    
    // Swap them
    int temp = permutation[positionOne]; 
    permutation[positionOne] = permutation[positionTwo]; 
    permutation[positionTwo] = temp;
    
    // Now reverse the elements in between by swapping the ends
    for (++positionOne, positionTwo = size; positionOne < positionTwo; ++positionOne, --positionTwo) 
    {
        assert(positionOne >= 0 && positionOne <= size);
        assert(positionTwo >= 0 && positionTwo <= size);
        
        temp = permutation[positionOne]; permutation[positionOne] = permutation[positionTwo]; permutation[positionTwo] = temp;
    }
    
    return permutation;
}

// PRIVATE: Find best fitting bin for given item
// RETURNS: Best fitting bin index
- (int) getIndexOfBestFitBin:(float)newItemValue
{
    int index = -1;
    float nearestToFill = 0.0f;
    
    // If no bins exist index -1 is returned indicating that new bin should be created
    if (0 == [self->bins count])
    {
        return index;
    }
    else
    {
        // Iterate through all current bins and check in which bin current item fits the bes
        for (int i = 0; i < [self->bins count]; i++)
        {
            float currentItemValue = [[self->bins objectAtIndex:(NSUInteger)i] floatValue];
            
            if (currentItemValue + newItemValue > nearestToFill && currentItemValue + newItemValue <= self->binCapacity)
            {
                index = i;
                nearestToFill = currentItemValue + newItemValue;
            }
        }
    }
    
    return index;
}

// PRIVATE: Write how items are packed in bins
- (void) showHowItemsArePackedInBins
{
    for (int i = 0; i < [self->itemsAndItsBins count]; i++)
    {
        NSLog(@"Item %.2f is placed in bin #%d.", [[self->items objectAtIndex:i] floatValue], [[self->itemsAndItsBins objectAtIndex:i] intValue]);
    }
}

// PRIVATE: Write how items are best packed in bins
- (void) showHowItemsArePackedBestInBins
{
    for (int i = 0; i < [self->itemsAndItsBinsBest count]; i++)
    {
        NSLog(@"Item %.2f is placed in bin #%d.", [[self->itemsBest objectAtIndex:i] floatValue], [[self->itemsAndItsBinsBest objectAtIndex:i] intValue]);
    }
}

@end