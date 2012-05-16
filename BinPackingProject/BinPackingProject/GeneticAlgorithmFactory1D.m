//
//  GeneticAlgorithmFactory1D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#import "GeneticAlgorithmFactory1D.h"

@implementation GeneticAlgorithmFactory1D
{
    int numberOfItemsInUnit;
    int numberOfUnitsInGeneration;
    
    int lowestCost;
    int indexOfLowestCostItem;
    
    NSMutableArray *items;
    NSMutableArray *currentGeneration;
    NSMutableArray *currentGenerationCost;
    NSMutableArray *newGeneration;
}

@synthesize lowestCost;

// Custom initializator
- (id) initWithItemArray:(NSMutableArray *)itemsArray:(int)numberOfUnits
{
    if (self = [super init]) 
    {
        self->lowestCost = INT_MAX;
        
        // Save original array of items
        self->items = [NSMutableArray new];
        [self->items addObjectsFromArray:itemsArray];
        
        self->newGeneration = [NSMutableArray new];
        self->currentGeneration = [NSMutableArray new];
        self->currentGenerationCost = [NSMutableArray new];
        
        // Initialize GA fields
        self->numberOfItemsInUnit = [self->items count];
        self->numberOfUnitsInGeneration = numberOfUnits;
    }
    
    return self;
}

// PUBLIC: Generate initial population of units
- (void) generateInitialPopulation
{
    // Generate numberOfUnitsInGeneration units in to start algorithm
    for (int i = 0; i < self->numberOfUnitsInGeneration; i++)
    {
        //[self printItemContent:self->items];
        [self shuffleItems];
        //[self printItemContent:self->items];
        [self->currentGeneration addObject:self->items];
    }
}

- (void) printItemContent:(NSMutableArray *)items
{
    NSLog(@"-------------");
    for (NSNumber *item in self->items)
    {
        NSLog(@"%f ", [item floatValue]);
    }
    NSLog(@"-------------");
}

// PUBLIC: Method where selection + crossing is done
- (void) mate
{
    // 2 parents make 1 new unit
    for (int i = 0; i < self->numberOfUnitsInGeneration; i++)
    {
        int parentIndexOne;
        int parentIndexTwo;
        
        do
        {
            parentIndexOne = arc4random_uniform(self->numberOfUnitsInGeneration);
            parentIndexTwo = arc4random_uniform(self->numberOfUnitsInGeneration);

        } while (parentIndexOne == parentIndexTwo);
        
        // At this point we have chosen 2 different parents
        // Now we should do the crossover
        
        // Crossover: randomly choose 3 positions in unit and do parent mixing
        int randomIndexOne;
        int randomIndexTwo;
        int randomIndexThree;
        
        do
        {
            randomIndexOne = arc4random_uniform(self->numberOfItemsInUnit);
            randomIndexTwo = arc4random_uniform(self->numberOfItemsInUnit);
            randomIndexThree = arc4random_uniform(self->numberOfItemsInUnit);
            
        } while (randomIndexOne == randomIndexTwo || randomIndexTwo == randomIndexThree || randomIndexOne == randomIndexThree);
        
        // At this point we have indexes, we should now mix parents to create child
        NSMutableArray *parentOne = [NSMutableArray new];
        NSMutableArray *parentTwo = [NSMutableArray new];
        
        [parentOne addObjectsFromArray:[self->currentGeneration objectAtIndex:(NSUInteger)parentIndexOne]];
        [parentTwo addObjectsFromArray:[self->currentGeneration objectAtIndex:(NSUInteger)parentIndexTwo]];
        
        int parentChoice = arc4random_uniform(2);
        NSMutableArray *child = [NSMutableArray new];
        
        if (parentChoice == 0)
        {
            // 3 items will be taken from first parent
            for (int i = 0; i < self->numberOfItemsInUnit; i++)
            {
                if (i == randomIndexOne)
                {
                    [child addObject:[parentOne objectAtIndex:(NSUInteger)randomIndexOne]];
                }
                else if (i == randomIndexTwo)
                {
                    [child addObject:[parentOne objectAtIndex:(NSUInteger)randomIndexTwo]];
                }
                else if (i == randomIndexThree)
                {
                    [child addObject:[parentOne objectAtIndex:(NSUInteger)randomIndexThree]];
                }
                else
                {
                    [child addObject:[parentTwo objectAtIndex:(NSUInteger)i]];
                }
            }
        }
        else
        {
            // 3 items will be taken from second parent
            for (int i = 0; i < self->numberOfItemsInUnit; i++)
            {
                if (i == randomIndexOne)
                {
                    [child addObject:[parentTwo objectAtIndex:(NSUInteger)randomIndexOne]];
                }
                else if (i == randomIndexTwo)
                {
                    [child addObject:[parentTwo objectAtIndex:(NSUInteger)randomIndexTwo]];
                }
                else if (i == randomIndexThree)
                {
                    [child addObject:[parentTwo objectAtIndex:(NSUInteger)randomIndexThree]];
                }
                else
                {
                    [child addObject:[parentOne objectAtIndex:(NSUInteger)i]];
                }
            }
        }
        
        // At this moment we have child and we will add it to next generation
        [self->newGeneration addObject:child];
    }
}

// PUBLIC
- (void) mutate:(int)mutationFactorPercentage
{
    for (NSMutableArray *unit in self->newGeneration)
    {
        int randomNumber = arc4random_uniform(100);
        
        if (randomNumber < mutationFactorPercentage)
        {
            // Do the mutation
            int randomIndexOne;
            int randomIndexTwo;
            
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

// PUBLIC
- (void) generationSwap
{
    [self->currentGeneration removeAllObjects];
    [self->currentGeneration addObjectsFromArray:self->newGeneration];
    [self->newGeneration removeAllObjects];
}

- (void) calculateGenerationCost:(int (^) (NSMutableArray*)) fitnessFunction
{
    [self->currentGenerationCost removeAllObjects];
    
    // Run fitness function on all items and calculate cost for each item
    for (NSMutableArray *item in self->currentGeneration)
    {
        int itemCost = fitnessFunction(item);
        
        [self->currentGenerationCost addObject:[NSNumber numberWithInt:itemCost]];
    }
    
    [self locateLowestCostItem];
}

// PRIVATE
- (void) locateLowestCostItem
{
    int currentItemCost;
    
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
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        
        // Do the shuffle
        [self->items exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
