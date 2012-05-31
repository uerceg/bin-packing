//
//  GeneticAlgorithmFactory3D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/30/12.
//  Open Source project
//

#import "GeneticAlgorithmFactory3D.h"
#import "Box.h"

@implementation GeneticAlgorithmFactory3D
{
    @private float storageWidth;
    @private float storageLength;
    @private float storageHeight;
    @private float lowestCost;
    
    @private NSUInteger elitismFactor;
    @private NSUInteger numberOfBoxesInUnit;
    @private NSUInteger numberOfUnitsInGeneration;
    
    @private NSMutableArray *boxes;
    @private NSMutableArray *boxesElite;
    @private NSMutableArray *dummyBoxes;
    @private NSMutableDictionary *sliceLevelsPerLevel;
    @private NSMutableDictionary *sliceLevelsPerLevelWithBoxes;
    
    @private NSMutableArray *newGeneration;
    @private NSMutableArray *currentGeneration;
    @private NSMutableArray *currentGenerationCost;
}

@synthesize sliceLevelsPerLevel;

// INIT: Custom initializator
- (id) initWithNumberOfUnitsInGeneration:(NSUInteger)numberOfUnits 
                              boxesArray:(NSMutableArray *)boxesArray
                           elitismFactor:(NSUInteger)elitism 
                            storageWidth:(float)width 
                           storageHeight:(float)height
                           storageLength:(float)length
{
    if (self = [super init])
    {
        self->boxes = [NSMutableArray new];
        self->sliceLevelsPerLevel = [NSMutableDictionary dictionary];
        self->sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
        
        self->dummyBoxes = [NSMutableArray new];
        self->boxesElite = [NSMutableArray array];
        self->newGeneration = [NSMutableArray array];
        self->currentGeneration = [NSMutableArray array];
        self->currentGenerationCost = [NSMutableArray new];
        
        [self->boxes addObjectsFromArray:boxesArray];
        
        self->lowestCost = (float)INT_MAX;
        self->storageWidth = width;
        self->storageHeight = height;
        self->storageLength = length;
        
        self->elitismFactor = elitism;
        self->numberOfBoxesInUnit = [boxesArray count];
        self->numberOfUnitsInGeneration = numberOfUnits;
        
        for (NSUInteger i = 0; i < [boxesArray count]; i++)
        {
            [self->dummyBoxes addObject:[[Box alloc] initWithWidth:0.0f length:0.0f height:0.0f]];
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
        [self shuffleBoxes];
        
        NSMutableArray *newUnit = [NSMutableArray new];
        [newUnit addObjectsFromArray:self->boxes];
        
        [self->currentGeneration addObject:newUnit];
    }
}

// PUBLIC: Method where selection + crossing is done
- (void) mate:(NSUInteger)crossingPointsNumber
{
    // Place elite units in new generation
    [self->newGeneration removeAllObjects];
    
    for (NSNumber *eliteUnit in self->boxesElite)
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
        
        NSInteger randomIndexes[[self->boxes count]];
        
        for (NSUInteger i = 0; i < [self->boxes count]; i++)
        {
            randomIndexes[i] = i;
        }
        
        NSUInteger maximum = [self->boxes count] - 1;
        
        // Randomize index positions
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
        [child addObjectsFromArray:self->dummyBoxes];
        
        if (parentChoice == 0)
        {
            // Items will be taken from second parent            
            for (NSUInteger i = 0; i < crossingPointsNumber; i++)
            {
                [child replaceObjectAtIndex:randomIndexes[i] withObject:[parentOne objectAtIndex:randomIndexes[i]]];
            }
            
            // Fill the rest of the fields with remaining items from parent two
            // In sequential order from left to right
            NSUInteger remainedIndexes[self->numberOfBoxesInUnit - crossingPointsNumber];
            NSUInteger remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger j = 0; j < self->numberOfBoxesInUnit; j++)
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
            NSMutableArray *remainedBoxes = [NSMutableArray new];
            [remainedBoxes addObjectsFromArray:parentTwo];
            
            // Determine items which should be removed and which are taken from firstly selected parent
            NSMutableArray *boxesToRemoveFromRemained = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < crossingPointsNumber; j++)
            {
                [boxesToRemoveFromRemained addObject:[parentOne objectAtIndex:randomIndexes[j]]];
            }
            
            // Remove those items from secondly selected parent
            for (Box *box in boxesToRemoveFromRemained)
            {
                NSUInteger j;
                
                for (j = 0; j < [remainedBoxes count]; j++)
                {
                    if (YES == [box isEqualToBox:(Box *)[remainedBoxes objectAtIndex:j]])
                    {
                        break;
                    }
                }
                
                [remainedBoxes removeObjectAtIndex:j];
            }
            
            // Now place unfilled items to unfilled indexes in child
            for (NSInteger j = 0; j < [remainedBoxes count]; j++)
            {
                [child replaceObjectAtIndex:remainedIndexes[j] withObject:[remainedBoxes objectAtIndex:j]];
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
            NSUInteger remainedIndexes[self->numberOfBoxesInUnit - crossingPointsNumber];
            NSUInteger remainedIndexesCount = 0;
            
            // Determine remained unfilled indexes
            for (NSUInteger j = 0; j < self->numberOfBoxesInUnit; j++)
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
            NSMutableArray *remainedBoxes = [NSMutableArray new];
            [remainedBoxes addObjectsFromArray:parentOne];
            
            // Determine items which should be removed and which are taken from firstly selected parent
            NSMutableArray *boxesToRemoveFromRemained = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < crossingPointsNumber; j++)
            {
                [boxesToRemoveFromRemained addObject:[parentTwo objectAtIndex:randomIndexes[j]]];
            }
            
            // Remove those items from secondly selected parent
            for (Box *box in boxesToRemoveFromRemained)
            {
                NSUInteger j;
                
                for (j = 0; j < [remainedBoxes count]; j++)
                {
                    if (YES == [box isEqualToBox:(Box *)[remainedBoxes objectAtIndex:j]])
                    {
                        break;
                    }
                }
                
                [remainedBoxes removeObjectAtIndex:j];
            }
            
            // Now place unfilled items to unfilled indexes in child
            for (NSInteger j = 0; j < [remainedBoxes count]; j++)
            {
                [child replaceObjectAtIndex:remainedIndexes[j] withObject:[remainedBoxes objectAtIndex:j]];
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
                randomIndexOne = arc4random_uniform(self->numberOfBoxesInUnit);
                randomIndexTwo = arc4random_uniform(self->numberOfBoxesInUnit);
                
            } while (randomIndexOne == randomIndexTwo);
            
            NSValue *firstBox = [unit objectAtIndex:(NSUInteger)randomIndexOne];
            NSValue *secondBox = [unit objectAtIndex:(NSUInteger)randomIndexTwo];
            
            [unit replaceObjectAtIndex:(NSUInteger)randomIndexOne withObject:secondBox];
            [unit replaceObjectAtIndex:(NSUInteger)randomIndexTwo withObject:firstBox];
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
- (void) calculateGenerationCostForFitnessFunction1:(float (^) (NSMutableArray *))ffunction1 
                                   fitnessFunction2:(float (^) (NSMutableArray *, NSMutableDictionary *))ffunction2
{
    [self->boxesElite removeAllObjects];
    [self->currentGenerationCost removeAllObjects];
    
    // Run fitness function on all items and calculate cost for each item
    for (NSMutableArray *boxesArray in self->currentGeneration)
    {
        float unitCost = ffunction1(boxesArray);
        
        [self->currentGenerationCost addObject:[NSNumber numberWithInt:unitCost]];
    }
    
    // Find out which units are elite one and save them
    NSMutableArray *specArray = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [self->currentGenerationCost count]; i++)
    {
        [specArray addObject:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:[[self->currentGenerationCost objectAtIndex:i] floatValue]], [NSNumber numberWithInteger:i], nil]];
    }
    
    NSArray *sortedArray = [specArray sortedArrayUsingFunction:customCompareFunction3D context:NULL];
    
    for (NSUInteger i = 0; i < self->elitismFactor; i++)
    {
        [self->boxesElite addObject:[self->currentGeneration objectAtIndex:[[[sortedArray objectAtIndex:i] objectAtIndex:1] intValue]]];
    }
    
    // Save the best one for printing purpose (best ones are in elite units)
    for (NSUInteger i = 0; i < [self->boxesElite count]; i++)
    {
        NSMutableArray *eliteUnit = [NSMutableArray arrayWithArray:[self->boxesElite objectAtIndex:i]];
        NSMutableDictionary *eliteUnitShelvesLevelPerLevel = [NSMutableDictionary dictionary];
        
        float currentEliteCost = ffunction2(eliteUnit, eliteUnitShelvesLevelPerLevel);
        
        if (self->lowestCost > currentEliteCost)
        {
            self->lowestCost = currentEliteCost;
            [self->sliceLevelsPerLevel removeAllObjects];
            [self->sliceLevelsPerLevel addEntriesFromDictionary:eliteUnitShelvesLevelPerLevel];
        }
    }
}

// PRIVATE: Sorting method
NSComparisonResult customCompareFunction3D(NSArray* first, NSArray* second, void* context)
{
    id firstValue = [first objectAtIndex:0];
    id secondValue = [second objectAtIndex:0];
    return [firstValue compare:secondValue];
}

// PRIVATE: Shuffle items in array in order to generate new combination of items
- (void) shuffleBoxes
{    
    NSUInteger count = [self->boxes count];
    
    for (NSUInteger i = 0; i < count; ++i) 
    {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        
        // Do the shuffle
        [self->boxes exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
