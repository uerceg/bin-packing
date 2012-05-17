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
    NSUInteger numberOfItemsInUnit;
    NSUInteger numberOfUnitsInGeneration;
    
    NSUInteger lowestCost;
    NSUInteger indexOfLowestCostItem;
    
    NSMutableArray *items;
    NSMutableArray *dummyItems;
    NSMutableArray *currentGeneration;
    NSMutableArray *currentGenerationCost;
    NSMutableArray *newGeneration;
}

@synthesize lowestCost;

// INIT: Custom initializator which takes item array and 
- (id) initWithNumberOfItemsInGeneration:(NSUInteger)numberOfUnits 
                              itemsArray:(NSMutableArray *)itemsArray
{
    if (self = [super init]) 
    {
        self->lowestCost = INT_MAX;
        
        // Save original array of items
        self->items = [NSMutableArray new];
        [self->items addObjectsFromArray:itemsArray];
        
        self->newGeneration = [NSMutableArray array];
        self->currentGeneration = [NSMutableArray array];
        self->currentGenerationCost = [NSMutableArray new];
        
        // Initialize GA fields
        self->numberOfItemsInUnit = [self->items count];
        self->numberOfUnitsInGeneration = numberOfUnits;
        
        self->dummyItems = [NSMutableArray new];
        for (int i = 0; i < self->numberOfItemsInUnit; i++)
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
- (void) mate
{
    // 2 parents make 1 new unit
    for (NSUInteger i = 0; i < self->numberOfUnitsInGeneration; i++)
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
        
        // Crossover: randomly choose 3 positions in unit and do parent mixing
        NSUInteger randomIndexOne;
        NSUInteger randomIndexTwo;
        NSUInteger randomIndexThree;
        
        do
        {
            randomIndexOne = arc4random_uniform(self->numberOfItemsInUnit);
            randomIndexTwo = arc4random_uniform(self->numberOfItemsInUnit);
            randomIndexThree = arc4random_uniform(self->numberOfItemsInUnit);
            
        } while (randomIndexOne == randomIndexTwo || randomIndexTwo == randomIndexThree || randomIndexOne == randomIndexThree);
        
        // At this point we have indexes, we should now mix parents to create child
        NSMutableArray *parentOne = [NSMutableArray new];
        NSMutableArray *parentTwo = [NSMutableArray new];
        
        [parentOne addObjectsFromArray:[self->currentGeneration objectAtIndex:parentIndexOne]];
        [parentTwo addObjectsFromArray:[self->currentGeneration objectAtIndex:parentIndexTwo]];
        
        NSUInteger parentChoice = arc4random_uniform(2);
        NSMutableArray *child = [NSMutableArray new];
        [child addObjectsFromArray:self->dummyItems];
        
        if (parentChoice == 0)
        {
            // 3 items will be taken from first parent
            [child replaceObjectAtIndex:randomIndexOne withObject:[parentOne objectAtIndex:randomIndexOne]];
            [child replaceObjectAtIndex:randomIndexTwo withObject:[parentOne objectAtIndex:randomIndexTwo]];
            [child replaceObjectAtIndex:randomIndexThree withObject:[parentOne objectAtIndex:randomIndexThree]];
            
            // Fill the rest of the fields with remaining items from parent two
            // In sequential order from left to right
            int remainedIndexes[self->numberOfItemsInUnit - 3];
            int remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger i = 0; i < self->numberOfItemsInUnit; i++)
            {
                if (i != randomIndexOne && i != randomIndexTwo && i != randomIndexThree)
                {
                    remainedIndexes[remainedIndexesCount] = i;
                    remainedIndexesCount += 1;
                }
            }
            
            // Determine unfilled items
            NSMutableArray *remainedItems = [NSMutableArray new];
            [remainedItems addObjectsFromArray:parentTwo];
            
            NSMutableArray *itemsToRemoveFromRemained = [NSMutableArray new];
            [itemsToRemoveFromRemained addObject:[parentOne objectAtIndex:randomIndexOne]];
            [itemsToRemoveFromRemained addObject:[parentOne objectAtIndex:randomIndexTwo]];
            [itemsToRemoveFromRemained addObject:[parentOne objectAtIndex:randomIndexThree]];
            
            for (NSNumber *item in itemsToRemoveFromRemained)
            {
                NSUInteger i;
                
                for (i = 0; i < [remainedItems count]; i++)
                {
                    if ([item floatValue] == [[remainedItems objectAtIndex:i] floatValue])
                    {
                        break;
                    }
                }
            
                [remainedItems removeObjectAtIndex:i];
            }
            
            // Now place unfilled items to unfilled indexes in child
            for (NSInteger i = 0; i < [remainedItems count]; i++)
            {
                [child replaceObjectAtIndex:remainedIndexes[i] withObject:[remainedItems objectAtIndex:i]];
            }
        
        }
        else
        {
            // 3 items will be taken from second parent
            [child replaceObjectAtIndex:randomIndexOne withObject:[parentTwo objectAtIndex:randomIndexOne]];
            [child replaceObjectAtIndex:randomIndexTwo withObject:[parentTwo objectAtIndex:randomIndexTwo]];
            [child replaceObjectAtIndex:randomIndexThree withObject:[parentTwo objectAtIndex:randomIndexThree]];
            
            // Fill the rest of the fields with remaining items from parent two
            // In sequential order from left to right
            NSUInteger remainedIndexes[self->numberOfItemsInUnit - 3];
            NSUInteger remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger i = 0; i < self->numberOfItemsInUnit; i++)
            {
                if (i != randomIndexOne && i != randomIndexTwo && i != randomIndexThree)
                {
                    remainedIndexes[remainedIndexesCount] = i;
                    remainedIndexesCount += 1;
                }
            }
            
            // Determine unfilled items
            NSMutableArray *remainedItems = [NSMutableArray new];
            [remainedItems addObjectsFromArray:parentOne];
            
            NSMutableArray *itemsToRemoveFromRemained = [NSMutableArray new];
            [itemsToRemoveFromRemained addObject:[parentTwo objectAtIndex:randomIndexOne]];
            [itemsToRemoveFromRemained addObject:[parentTwo objectAtIndex:randomIndexTwo]];
            [itemsToRemoveFromRemained addObject:[parentTwo objectAtIndex:randomIndexThree]];
            
            for (NSNumber *item in itemsToRemoveFromRemained)
            {
                NSUInteger i;
                
                for (i = 0; i < [remainedItems count]; i++)
                {
                    if ([item floatValue] == [[remainedItems objectAtIndex:i] floatValue])
                    {
                        break;
                    }
                }
                
                [remainedItems removeObjectAtIndex:i];
            }
            
            // Now place unfilled items to unfilled indexes in child
            for (NSInteger i = 0; i < [remainedItems count]; i++)
            {
                [child replaceObjectAtIndex:remainedIndexes[i] withObject:[remainedItems objectAtIndex:i]];
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
- (void) calculateGenerationCost:(NSUInteger (^) (NSMutableArray*)) fitnessFunction
{
    [self->currentGenerationCost removeAllObjects];
    
    // Run fitness function on all items and calculate cost for each item
    for (NSMutableArray *item in self->currentGeneration)
    {
        NSUInteger itemCost = fitnessFunction(item);
        
        [self->currentGenerationCost addObject:[NSNumber numberWithInt:itemCost]];
    }
    
    [self locateLowestCostItem];
}

// PRIVATE: Method for calculating lowest cost unit and remembering its number of used bins and its index in item array
- (void) locateLowestCostItem
{
    NSUInteger currentItemCost;
    
    for (NSNumber *cost in self->currentGenerationCost)
    {
        currentItemCost = [cost intValue];
        
        if (currentItemCost < self->lowestCost)
        {
            self->lowestCost = currentItemCost;
            self->indexOfLowestCostItem = [self->currentGenerationCost indexOfObject:cost];
        }
    }
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
