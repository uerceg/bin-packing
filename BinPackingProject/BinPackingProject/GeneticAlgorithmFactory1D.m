//
//  GeneticAlgorithmFactory1D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import "GeneticAlgorithmFactory1D.h"

@implementation GeneticAlgorithmFactory1D
{
    @private NSUInteger elitismFactor;
    @private NSUInteger numberOfItemsInUnit;
    @private NSUInteger numberOfUnitsInGeneration;
    
    @private NSUInteger lowestCost;
    @private NSUInteger indexOfLowestCostItem;
    
    @private NSMutableArray *bins;
    @private NSMutableArray *items;
    @private NSMutableArray *itemsElite;
    @private NSMutableArray *dummyItems;
    @private NSMutableArray *newGeneration;
    @private NSMutableArray *currentGeneration;
    @private NSMutableArray *currentGenerationCost;
    @private NSMutableArray *currentGenerationBins;
}

@synthesize lowestCost, bins;

// INIT: Custom initializator which takes item array and 
- (id) initWithNumberOfUnitsInGeneration:(NSUInteger)numberOfUnits 
                              itemsArray:(NSMutableArray *)itemsArray 
                           elitismFactor:(NSUInteger)elitism
{
    if (self = [super init]) 
    {
        self->lowestCost = INT_MAX;
        self->elitismFactor = elitism;
        
        // Save original array of items
        self->bins = [NSMutableArray new];
        self->items = [NSMutableArray new];
        [self->items addObjectsFromArray:itemsArray];
        
        self->itemsElite = [NSMutableArray array];
        self->newGeneration = [NSMutableArray array];
        self->currentGeneration = [NSMutableArray array];
        self->currentGenerationCost = [NSMutableArray new];
        self->currentGenerationBins = [NSMutableArray array];
        
        // Initialize GA fields
        self->numberOfItemsInUnit = [self->items count];
        self->numberOfUnitsInGeneration = numberOfUnits;
        
        self->dummyItems = [NSMutableArray new];
        for (NSUInteger i = 0; i < self->numberOfItemsInUnit; i++)
        {
            [self->dummyItems addObject:[NSNumber numberWithFloat:0.0f]];
        }
    }
    
    return self;
}

// PUBLIC: Generate initial population of units
- (void) generateInitialPopulation
{
    // Generate numberOfUnitsInGeneration units in to start algorithm
    for (NSUInteger i = 0; i < self->numberOfUnitsInGeneration; i++)
    {
        [self shuffleItems];
        
        NSMutableArray *newUnit = [NSMutableArray new];
        [newUnit addObjectsFromArray:self->items];
        
        [self->currentGeneration addObject:newUnit];
    }
}

// PUBLIC: Method where selection + crossing is done
- (void) mate:(NSUInteger)crossingPointsNumber
{
    // Place elite units in new generation
    [self->newGeneration removeAllObjects];
    
    for (NSNumber *eliteUnit in self->itemsElite)
    {
        [self->newGeneration addObject:eliteUnit];
    }
    
    // 2 parents make 1 new unit
    for (NSUInteger i = 0; i < (self->numberOfUnitsInGeneration - self->elitismFactor); i++)
    {
        NSUInteger parentIndexOne;
        NSUInteger parentIndexTwo;
        
        do
        {
            parentIndexOne = arc4random_uniform(self->numberOfUnitsInGeneration);
            parentIndexTwo = arc4random_uniform(self->numberOfUnitsInGeneration);
            
        } while (parentIndexOne == parentIndexTwo);
        
        // At this point we have chosen 2 different parents
        // Now we should do the crossover
        
        NSInteger randomIndexes[[self->items count]];
        
        for (NSUInteger i = 0; i < [self->items count]; i++)
        {
            randomIndexes[i] = i;
        }
        
        NSUInteger maximum = [self->items count] - 1;
        
        do
        {
            NSUInteger randomPosition = arc4random_uniform(maximum);
            NSInteger temp;
            
            temp = randomIndexes[maximum];
            randomIndexes[maximum] = randomIndexes[randomPosition];
            randomIndexes[randomPosition] = temp;
            
            maximum -= 1;
        } while (maximum != -1);
        
        // At this point we have indexes, we should now mix parents to create child
        NSMutableArray *parentOne = [NSMutableArray new];
        NSMutableArray *parentTwo = [NSMutableArray new];
        
        [parentOne addObjectsFromArray:[self->currentGeneration objectAtIndex:parentIndexOne]];
        [parentTwo addObjectsFromArray:[self->currentGeneration objectAtIndex:parentIndexTwo]];
        
        // Initialize child array with dummy values, since all need to be REPLACED
        NSUInteger parentChoice = arc4random_uniform(2);
        NSMutableArray *child = [NSMutableArray new];
        [child addObjectsFromArray:self->dummyItems];
        
        if (parentChoice == 0)
        {
            // Items will be taken from second parent            
            for (NSUInteger i = 0; i < crossingPointsNumber; i++)
            {
                [child replaceObjectAtIndex:randomIndexes[i] withObject:[parentOne objectAtIndex:randomIndexes[i]]];
            }
            
            // Fill the rest of the fields with remaining items from parent two
            // In sequential order from left to right
            NSUInteger remainedIndexes[self->numberOfItemsInUnit - crossingPointsNumber];
            NSUInteger remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger j = 0; j < self->numberOfItemsInUnit; j++)
            {
                BOOL indexContained = NO;
                
                for (NSUInteger k = 0; k < crossingPointsNumber; k++)
                {
                    if (j == randomIndexes[k])
                    {
                        indexContained = YES;
                        break;
                    }
                }
                
                if (NO == indexContained)
                {
                    remainedIndexes[remainedIndexesCount] = j;
                    remainedIndexesCount += 1;
                }
            }
            
            // Determine unfilled items
            NSMutableArray *remainedItems = [NSMutableArray new];
            [remainedItems addObjectsFromArray:parentTwo];
            
            // Determine items which should be removed and which are taken from firstly selected parent
            NSMutableArray *itemsToRemoveFromRemained = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < crossingPointsNumber; j++)
            {
                [itemsToRemoveFromRemained addObject:[parentOne objectAtIndex:randomIndexes[j]]];
            }
            
            // Remove those items from secondly selected parent
            for (NSNumber *item in itemsToRemoveFromRemained)
            {
                NSUInteger j;
                
                for (j = 0; j < [remainedItems count]; j++)
                {
                    if ([item floatValue] == [[remainedItems objectAtIndex:j] floatValue])
                    {
                        break;
                    }
                }
                
                [remainedItems removeObjectAtIndex:j];
            }
            
            // Now place unfilled items to unfilled indexes in child
            for (NSInteger j = 0; j < [remainedItems count]; j++)
            {
                [child replaceObjectAtIndex:remainedIndexes[j] withObject:[remainedItems objectAtIndex:j]];
            }
        }
        else
        {
            // Items will be taken from second parent            
            for (NSUInteger i = 0; i < crossingPointsNumber; i++)
            {
                [child replaceObjectAtIndex:randomIndexes[i] withObject:[parentTwo objectAtIndex:randomIndexes[i]]];
            }
            
            // Fill the rest of the fields with remaining items from parent two
            // In sequential order from left to right
            NSUInteger remainedIndexes[self->numberOfItemsInUnit - crossingPointsNumber];
            NSUInteger remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger j = 0; j < self->numberOfItemsInUnit; j++)
            {
                BOOL indexContained = NO;
                
                for (NSUInteger k = 0; k < crossingPointsNumber; k++)
                {
                    if (j == randomIndexes[k])
                    {
                        indexContained = YES;
                        break;
                    }
                }
                
                if (NO == indexContained)
                {
                    remainedIndexes[remainedIndexesCount] = j;
                    remainedIndexesCount += 1;
                }
            }
            
            // Determine unfilled items
            NSMutableArray *remainedItems = [NSMutableArray new];
            [remainedItems addObjectsFromArray:parentOne];
            
            // Determine items which should be removed and which are taken from firstly selected parent
            NSMutableArray *itemsToRemoveFromRemained = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < crossingPointsNumber; j++)
            {
                [itemsToRemoveFromRemained addObject:[parentTwo objectAtIndex:randomIndexes[j]]];
            }
            
            // Remove those items from secondly selected parent
            for (NSNumber *item in itemsToRemoveFromRemained)
            {
                NSUInteger j;
                
                for (j = 0; j < [remainedItems count]; j++)
                {
                    if ([item floatValue] == [[remainedItems objectAtIndex:j] floatValue])
                    {
                        break;
                    }
                }
                
                [remainedItems removeObjectAtIndex:j];
            }

            // Now place unfilled items to unfilled indexes in child
            for (NSInteger j = 0; j < [remainedItems count]; j++)
            {
                [child replaceObjectAtIndex:remainedIndexes[j] withObject:[remainedItems objectAtIndex:j]];
            }
        }
        
        // At this moment we have child and we will add it to next generation
        [self->newGeneration addObject:child];
    }
}

// PUBLIC: Method which mutates unit with certain percentage of probability
- (void) mutate:(NSUInteger)mutationFactorPercentage
{
    for (NSMutableArray *unit in self->newGeneration)
    {
        NSUInteger randomNumber = arc4random_uniform(100);
        
        if (randomNumber < mutationFactorPercentage)
        {
            // Do the mutation
            NSUInteger randomIndexOne;
            NSUInteger randomIndexTwo;
            
            do
            {
                randomIndexOne = arc4random_uniform(self->numberOfItemsInUnit);
                randomIndexTwo = arc4random_uniform(self->numberOfItemsInUnit);
                
            } while (randomIndexOne == randomIndexTwo);
            
            NSNumber *firstItem = [unit objectAtIndex:(NSUInteger)randomIndexOne];
            NSNumber *secondItem = [unit objectAtIndex:(NSUInteger)randomIndexTwo];
            
            [unit replaceObjectAtIndex:(NSUInteger)randomIndexOne withObject:secondItem];
            [unit replaceObjectAtIndex:(NSUInteger)randomIndexTwo withObject:firstItem];
        }
    }
}

// PUBLIC: Method which swaps newly created generation to become current generation
- (void) generationSwap
{
    [self->currentGeneration removeAllObjects];
    [self->currentGeneration addObjectsFromArray:self->newGeneration];
    [self->newGeneration removeAllObjects];
}

// PUBLIC: Method which calculates cost per each unit in generation based on fitness function
- (void) calculateGenerationCostWithFitnessFunction:(NSUInteger (^) (NSMutableArray *, NSMutableArray *)) ffunction
{
    NSMutableArray *currentBins = [NSMutableArray new];
    NSMutableArray *bestCurrentBins = [NSMutableArray new];
    
    [self->itemsElite removeAllObjects];
    [self->currentGenerationCost removeAllObjects];
    [self->currentGenerationBins removeAllObjects];
    
    // Run fitness function on all items and calculate cost for each item
    for (NSMutableArray *item in self->currentGeneration)
    {
        NSUInteger itemCost = ffunction(item, currentBins);
        
        [self->currentGenerationCost addObject:[NSNumber numberWithInteger:itemCost]];
        [self->currentGenerationBins addObject:[NSMutableArray arrayWithArray:currentBins]];
    }
    
    // Find out which units are elite one and save them
    NSMutableArray *specArray = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [self->currentGenerationCost count]; i++)
    {
        [specArray addObject:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:[[self->currentGenerationCost objectAtIndex:i] floatValue]], [NSNumber numberWithInteger:i], nil]];
    }
    
    NSArray *sortedArray = [specArray sortedArrayUsingFunction:customCompareFunction1D context:NULL];
    
    for (NSUInteger i = 0; i < self->elitismFactor; i++)
    {
        [self->itemsElite addObject:[self->currentGeneration objectAtIndex:[[[sortedArray objectAtIndex:i] objectAtIndex:1] intValue]]];
    }
    
    [bestCurrentBins addObjectsFromArray:[self->currentGenerationBins objectAtIndex:[[[sortedArray objectAtIndex:0] objectAtIndex:1]intValue]]];
    
    int currentLowestCost = [[[sortedArray objectAtIndex:0] objectAtIndex:0] intValue];
    
    if (self->lowestCost > currentLowestCost)
    {
        self->lowestCost = currentLowestCost;
        [self->bins removeAllObjects];
        [self->bins addObjectsFromArray:bestCurrentBins];
    }
}

// PRIVATE: Sorting method
NSComparisonResult customCompareFunction1D(NSArray* first, NSArray* second, void* context)
{
    id firstValue = [first objectAtIndex:0];
    id secondValue = [second objectAtIndex:0];
    return [firstValue compare:secondValue];
}

// PRIVATE: Shuffle items in array in order to generate new combination of items
- (void) shuffleItems
{    
    NSUInteger count = [self->items count];
    
    for (NSUInteger i = 0; i < count; ++i) 
    {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        
        // Do the shuffle
        [self->items exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
