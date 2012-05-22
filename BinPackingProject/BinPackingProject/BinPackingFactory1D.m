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
    @private float binCapacity;
    
    @private NSUInteger bestBinNumber;
    @private NSUInteger permutationCount;
    
    @private NSMutableArray *bins;
    @private NSMutableArray *items;
    @private NSMutableArray *itemsBest;
    @private NSMutableArray *itemsAndItsBins;
    @private NSMutableArray *itemsAndItsBinsBest;
    @private NSMutableArray *bestItemsCombination;
}

@synthesize permutationCount;

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

// PUBLIC: Next Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) nextFitAlgorithmForGivenItems:(NSMutableArray *)givenItems
                             withBinCapacity:(float)initBinCapacity
{
    NSUInteger currentBinUsedIndex = 0;
    float currentBinUsedSpace = 0.0f;
    
    self->binCapacity = initBinCapacity;
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
    
    return [self->bins count];
}

// PRIVATE: Block implementation of Next Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
NSUInteger (^ffNextFitAlgorithm1D) (NSMutableArray *) = ^(NSMutableArray * givenItems)
{
    NSUInteger currentBinUsedIndex = 0;
    float currentBinUsedSpace = 0.0f;
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

// PUBLIC: First Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) firstFitAlgorithmForGivenItems:(NSMutableArray *)givenItems
                       withBinCapacity:(float)initBinCapacity
{
    float currentItemValue;
    float currentBinCapacity;
    
    self->binCapacity = initBinCapacity;
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
    
    return [self->bins count];
}

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
NSUInteger (^ffFirstFitAlgorithm1D) (NSMutableArray *) = ^(NSMutableArray * givenItems)
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

// PUBLIC: Best Fit Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) bestFitAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                             withBinCapacity:(float)initBinCapacity
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
    
    // Write down items combination as the best one
    // [self showHowItemsArePackedInBins];
    
    return [self->bins count];
}

// PRIVATE: Block implementation of Best Fit Bin Packing algorithm (used for GA)
// RETURNS: Number of used bins
NSUInteger (^ffBestFitAlgorithm1D) (NSMutableArray *) = ^(NSMutableArray * givenItems)
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

// PUBLIC: Detail Search Bin Packing Algorithm
// RETURNS: Number of used bins
- (NSUInteger) detailSearchAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                                  withBinCapacity:(float)initBinCapacity
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
           initBinCapacity:initBinCapacity];
    
    // Stored only for display informations
    self->permutationCount = permutationCount;
    
    return self->bestBinNumber;
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
        NSUInteger numberOfBins = [self firstFitAlgorithmForGivenItems:newItemsPermutation 
                                                       withBinCapacity:initBinCapacity];
        
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
void swap1D(int *fir, int *sec)
{
    int temp = *fir;
    *fir = *sec;
    *sec = temp;
}

// PUBLIC: Bin Packing algorithm with usage of Genetic Algorithm
// RETURNS: Number of bins found in optimal item scheduling
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor 
                                           elitismFactor:(NSUInteger)elitismFactor 
                                 numberOfCrossoverPoints:(NSUInteger)crossoverPoints
{
    // Initialize GA factory object
    NSUInteger currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory1D *gaFactory = [[GeneticAlgorithmFactory1D alloc] initWithNumberOfUnitsInGeneration:unitNumber 
                                                                                                     itemsArray:bpItems 
                                                                                                  elitismFactor:elitismFactor];
    // Create initial population and calculate costs
    [gaFactory generateInitialPopulation];
    [gaFactory calculateGenerationCost:ffBestFitAlgorithm1D];
    
    // GA loop
    do
    {
        currentNumberOfGenerations += 1;
        
        // Do mating and mutation
        [gaFactory mate:crossoverPoints];
        [gaFactory mutate:mutationFactor];
        
        // Swap generations and calculate costs
        [gaFactory generationSwap];
        [gaFactory calculateGenerationCost:ffBestFitAlgorithm1D];
        
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
    [psoFactory calculateBestCandidateFromSwarm:ffFirstFitAlgorithm1D];
    [psoFactory calculateVelocityForNextStep:ffFirstFitAlgorithm1D];
    
    do
    {
        currentNumberOfIterations += 1;
        
        [psoFactory addVelocityToParticlesInSwarm];
        [psoFactory calculateBestCandidateFromSwarm:ffFirstFitAlgorithm1D];
        [psoFactory calculateVelocityForNextStep:ffFirstFitAlgorithm1D];
        
        [psoFactory swarmSwap];
        
    } while (currentNumberOfIterations < iterations);
    
    return psoFactory.allTimeBestParticleFitnessValue;
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