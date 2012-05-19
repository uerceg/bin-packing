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
    @private CGFloat binCapacity;
    
    @private NSMutableArray *bins;
    @private NSMutableArray *items;
    @private NSMutableArray *itemsBest;
    @private NSMutableArray *itemsAndItsBins;
    @private NSMutableArray *itemsAndItsBinsBest;
    @private NSMutableArray *bestItemsCombination;
}

// INIT: Custom Initializator
- (id) init
{
    if (self = [super init]) 
    {        
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
- (NSUInteger) firstFitAlgorithmForGivenItems:(NSMutableArray *)givenItems
                       withBinCapacity:(CGFloat)initBinCapacity
{
    CGFloat currentBinUsedSpace;
    
    self->binCapacity = initBinCapacity;
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
    // [self showHowItemsArePackedInBins];
    
    return [self->bins count];
}

// PRIVATE: This method is being passed to GA as fitness function
// RETURNS: Number of used bins
NSUInteger (^ffFirstFitAlgorithm) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    CGFloat currentBinUsedSpace = 0.0f;
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        CGFloat currentItemValue = [item floatValue];
        
        // Check if item fits in current bin
        if (currentBinUsedSpace + currentItemValue <= FF_BIN_CAPACITY) 
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
    
    return [bins count];
};

// PUBLIC: Best Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) bestFitAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                             withBinCapacity:(CGFloat)initBinCapacity
{
    self->binCapacity = initBinCapacity;
    [self->bins removeAllObjects];
    [self->items removeAllObjects];
    [self->itemsAndItsBins removeAllObjects];
    [self->bestItemsCombination removeAllObjects];
    
    // Assign given items to local array
    [self->items addObjectsFromArray:givenItems];
    
    for (NSNumber* item in self->items) 
    {
        CGFloat currentItemValue = [item floatValue];
        
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
    
    // Write down items combination as the best one
    // [self showHowItemsArePackedInBins];
    
    return [self->bins count];
}

// PRIVATE: This method is being passed to GA as fitness function
// RETURNS: Number of used bins
NSUInteger (^ffBestFitAlgorithm) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    NSMutableArray *bins = [NSMutableArray new];
    
    for (NSNumber* item in givenItems) 
    {
        CGFloat nearestToFill = 0.0f;
        CGFloat currentItemValue = [item floatValue];
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
                CGFloat algCurrentItemValue = [[bins objectAtIndex:i] floatValue];
                
                if (algCurrentItemValue + currentItemValue > nearestToFill && algCurrentItemValue + currentItemValue <= FF_BIN_CAPACITY)
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

// PUBLIC: Detail Search Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) detailSearchAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                           withBinCapacity:(CGFloat)initBinCapacity
{
    NSUInteger permutationCount = 0;
    NSUInteger bestBinNumber = INT_MAX;
    NSUInteger estimatedOptimalBinNumber = 0;
    
    CGFloat allItemsValueSum = 0;
    
    for (NSNumber *item in givenItems)
    {
        allItemsValueSum += [item floatValue];
    }
    
    estimatedOptimalBinNumber = (NSUInteger)allItemsValueSum;
    
    // Sorting items in asceding order
    NSArray *arrayOfGivenItems = [NSArray arrayWithArray:givenItems];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedArrayOfGivenItems = [arrayOfGivenItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSUInteger numberOfItems = [sortedArrayOfGivenItems count];
    
    // Allocating memory for 1 permutation
    CGFloat *permutedIndexes = malloc(numberOfItems * sizeof(NSInteger));
    
    // Placing indexes in array
    // Indexes are the thing which is going to be permuted
    // and new permutations will be genereted based on them
    for (NSUInteger index = 0; index < numberOfItems; ++index)
    {
        permutedIndexes[index] = index;
    }
    
    numberOfItems -= 1;
    
    do 
    {
        NSMutableArray *newItemsPermutation = [NSMutableArray array];
        
        for (NSUInteger i = 0; i <= numberOfItems; ++i)
        {
            // Generating items array based on indexes array
            [newItemsPermutation addObject:[sortedArrayOfGivenItems objectAtIndex:permutedIndexes[i]]];
        }
        
        // Now we need to check for current item order how many bins we need
        NSUInteger numberOfBins = [self firstFitAlgorithmForGivenItems:newItemsPermutation 
                                               withBinCapacity:initBinCapacity];
        
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
    } while ((permutedIndexes = [self makeIndexPermutationFromIndexArray:permutedIndexes 
                                                           numberOfItems:numberOfItems]) && ++permutationCount < MAX_PERMUTATION_COUNT);
    
    // Release allocated memory
    free(permutedIndexes);
    
    // Write down items combination as the best one
    // [self showHowItemsArePackedBestInBins];
    
    return bestBinNumber;
}

// PUBLIC: Bin Packing algorithm with usage of Genetic Algorithm
// RETURNS: Number of bins found in optimal item scheduling
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor
{
    // Initialize GA factory object
    NSUInteger currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory1D *gaFactory = [[GeneticAlgorithmFactory1D alloc] initWithNumberOfItemsInGeneration:unitNumber 
                                                                                                     itemsArray:bpItems];
    // Create initial population and calculate costs
    [gaFactory generateInitialPopulation];
    [gaFactory calculateGenerationCost:ffFirstFitAlgorithm];
    
    // GA loop
    do
    {
        currentNumberOfGenerations += 1;
        
        // Do mating and mutation
        [gaFactory mate];
        [gaFactory mutate:mutationFactor];
        
        // Swap generations and calculate costs
        [gaFactory generationSwap];
        [gaFactory calculateGenerationCost:ffFirstFitAlgorithm];
        
    } while (currentNumberOfGenerations < generationsNumber);
    
    return gaFactory.lowestCost;
}

// PUBLIC: Bin Packing algorithm with usage of PSO Algorithm
// RETURNS: Number of bins found in optimal item scheduling
- (NSUInteger) searchWithUsageOfPSOAlgorithmForItems:(NSMutableArray *)bpItems 
                                  numberOfIterations:(NSUInteger)iterations 
                            numberOfParticlesInSwarm:(NSUInteger)numberOfParticles
{
    // Initialize PSO factory object
    NSUInteger currentNumberOfIterations = 0;
    PSOAlgorithmFactory1D *psoFactory = [[PSOAlgorithmFactory1D alloc] initWithNumberOfParticlesInSwarm:numberOfParticles 
                                                                                     numberOfIterations:iterations 
                                                                                         particlesArray:bpItems];
    
    [psoFactory generateInitialSwarm];
    [psoFactory calculateBestCandidateFromSwarm:ffFirstFitAlgorithm];
    [psoFactory calculateVelocityForNextStep:ffFirstFitAlgorithm];
    
    do
    {
        currentNumberOfIterations += 1;
        
        [psoFactory addVelocityToParticlesInSwarm];
        [psoFactory calculateBestCandidateFromSwarm:ffFirstFitAlgorithm];
        [psoFactory calculateVelocityForNextStep:ffFirstFitAlgorithm];
        
        [psoFactory swarmSwap];
        
    } while (currentNumberOfIterations < iterations);
    
    return psoFactory.allTimeBestParticleFitnessValue;
}

// PRIVATE: Make permutation of item indexes
// RETURNS: New combination of indexes
- (CGFloat *) makeIndexPermutationFromIndexArray:(CGFloat *)array 
                                 numberOfItems:(const NSUInteger)size 
{
    // Slide down the array looking for where we're smaller than the next guy
    NSUInteger positionOne;
    NSUInteger positionTwo;
    
    for (positionOne = size - 1; array[positionOne] >= array[positionOne + 1] && positionOne > -1; --positionOne);
    
    // Uf this doesn't occur, we've finished our permutations
    // The array is reversed: (1, 2, 3, 4) => (4, 3, 2, 1)
    if (-1 == positionOne)
    {
        return NULL;
    }
    
    assert(positionOne >= 0 && positionOne <= size);
    
    // Slide down the array looking for a bigger number than what we found before
    for (positionTwo = size; array[positionTwo] <= array[positionOne] && positionTwo > 0; --positionTwo);
    
    assert(positionTwo >= 0 && positionTwo <= size);
    
    // Swap them
    NSUInteger temp = array[positionOne]; 
    array[positionOne] = array[positionTwo]; 
    array[positionTwo] = temp;
    
    // Now reverse the elements in between by swapping the ends
    for (++positionOne, positionTwo = size; positionOne < positionTwo; ++positionOne, --positionTwo) 
    {
        assert(positionOne >= 0 && positionOne <= size);
        assert(positionTwo >= 0 && positionTwo <= size);
        
        temp = array[positionOne]; 
        array[positionOne] = array[positionTwo]; 
        array[positionTwo] = temp;
    }
    
    return array;
}

// PRIVATE: Find best fitting bin for given item
// RETURNS: Best fitting bin index
- (NSUInteger) getIndexOfBestFitBin:(CGFloat)newItemValue
{
    NSUInteger index = -1;
    CGFloat nearestToFill = 0.0f;
    
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
            CGFloat currentItemValue = [[self->bins objectAtIndex:i] floatValue];
            
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