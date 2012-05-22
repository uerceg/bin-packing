// UNUSABLE SO FAR, SINCE PSO VELOCITY CALCULATION DOESN'T GIVE UNIQUE INDEXES ARRAY
// PSO WILL BE RECONSIDERED LATER

//
//  PSOAlgorithmFactory1D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import "PSOAlgorithmFactory1D.h"

@implementation PSOAlgorithmFactory1D
{
    @private NSUInteger numberOfParticlesInSwarm;
    
    @private NSMutableArray *indexes;
    @private NSMutableArray *velocity;
    @private NSMutableArray *particles;
    
    @private NSMutableArray *newSwarm;
    @private NSMutableArray *currentSwarm;
    
    @private NSUInteger currentBestParticleFitnessValue;
    @private NSMutableArray *currentBestParticleIndexes;
    
    @private NSUInteger allTimeBestParticleFitnessValue;
    @private NSMutableArray *allTimeBestParticleIndexes;
}

@synthesize allTimeBestParticleFitnessValue;

// INIT: Custom initializator which takes item array and number of particles
- (id) initWithNumberOfParticlesInSwarm:(NSUInteger)numberOfParticles 
                     numberOfIterations:(NSUInteger) iterations
                         particlesArray:(NSMutableArray *)particlesArray
{
    if (self = [super init]) 
    {
        // Save original array of items
        self->newSwarm = [NSMutableArray array];
        self->currentSwarm = [NSMutableArray array];
        self->currentBestParticleIndexes = [NSMutableArray new];
        
        self->indexes = [NSMutableArray new];
        self->velocity = [NSMutableArray array];
        
        self->particles = [NSMutableArray new];
        [self->particles addObjectsFromArray:particlesArray];
        
        self->currentBestParticleFitnessValue = INT_MAX;
        self->numberOfParticlesInSwarm = numberOfParticles;
        self->allTimeBestParticleFitnessValue = INT_MAX;
        self->allTimeBestParticleIndexes = [NSMutableArray new];
        
        NSMutableArray *dummyVelocity = [NSMutableArray new];
        for (NSUInteger i = 0; i < [self->particles count]; i++)
        {
            [dummyVelocity addObject:[NSNumber numberWithInt:0]];
        }
        
        for (NSUInteger i = 0; i < [self->particles count]; i++)
        {
            [self->indexes addObject:[NSNumber numberWithInteger:i]];
            [self->velocity addObject:dummyVelocity];
        }
    }
    
    return self;
}

// PUBLIC: Generate initial swarm from indexes
- (void) generateInitialSwarm
{
    // Generate numberOfUnitsInGeneration units in to start algorithm
    for (NSUInteger i = 0; i < self->numberOfParticlesInSwarm; i++)
    {
        [self shuffleItems];
        
        NSMutableArray *newIndexParticle = [NSMutableArray new];
        [newIndexParticle addObjectsFromArray:self->indexes];
        
        [self->currentSwarm addObject:newIndexParticle];
    }
}

// PUBLIC: Calculate best candidate from swarm and update global one if needed
- (void) calculateBestCandidateFromSwarm:(NSUInteger (^) (NSMutableArray *)) fitnessFunction
{
    self->currentBestParticleFitnessValue = INT_MAX;
    
    for (NSMutableArray *particleIndexes in self->currentSwarm)
    {
        NSMutableArray *particleFromIndexes = [self generateParticleFromIndexes:particleIndexes];
        NSUInteger particleFitness = fitnessFunction(particleFromIndexes);
        
        // Check if current particle is the best
        if (particleFitness < self->currentBestParticleFitnessValue)
        {
            self->currentBestParticleFitnessValue = particleFitness;
            
            [self->currentBestParticleIndexes removeAllObjects];
            [self->currentBestParticleIndexes addObjectsFromArray:particleIndexes];
            
            // Check if it is better then currently best particle of all times
            if (particleFitness < self->allTimeBestParticleFitnessValue)
            {
                self->allTimeBestParticleFitnessValue = particleFitness;
                
                [self->allTimeBestParticleIndexes removeAllObjects];
                [self->allTimeBestParticleIndexes addObjectsFromArray:particleIndexes];
            }
        }
    }
}

// PUBLIC: Calculating correction factor for making new swarm
- (void) calculateVelocityForNextStep:(NSUInteger (^) (NSMutableArray *)) fitnessFunction
{
    float w = 0.9f;
    float c1 = 1.0f;
    float c2 = 1.0f;
    float r1 = arc4random();
    float r2 = arc4random();
    
    [self->velocity removeAllObjects];
    
    for (NSMutableArray *particleIndexes in self->currentSwarm)
    {
        NSMutableArray *currentParticle = [self generateParticleFromIndexes:particleIndexes];
        NSUInteger currentFitness = fitnessFunction(currentParticle);
        
        for (NSUInteger i = 0; i < [self->velocity count]; i++)
        {
            NSUInteger newVelocity = w * [[self->velocity objectAtIndex:i] intValue] + c1 * r1 * (self->currentBestParticleFitnessValue - currentFitness) + c2 * r2 * (self->allTimeBestParticleFitnessValue - currentFitness);
            
            [self->velocity replaceObjectAtIndex:i 
                                      withObject:[NSNumber numberWithInteger:newVelocity]];
        }
    }
}

// PUBLIC: Generate new particles in swarm by performing velocity add
- (void) addVelocityToParticlesInSwarm
{
    [self-> newSwarm removeAllObjects];
    
    for (NSUInteger i = 0; i < [self->currentSwarm count]; i++)
    {
        NSMutableArray *newParticleIndexes = [NSMutableArray new];
        NSMutableArray *currentParticleIndexes = [self->currentSwarm objectAtIndex:i];
        NSMutableArray *currentParticleIndexesVelocity = [self->currentSwarm objectAtIndex:i];
        
        for (NSUInteger j = 0; j < [currentParticleIndexes count]; j++)
        {
            NSInteger newIndex = [[currentParticleIndexes objectAtIndex:j] intValue] + [[currentParticleIndexesVelocity objectAtIndex:j] intValue];
            
            // HERE'S THE PROBLEM
            // Saturate newly created indexes to fit index bounds
            if (newIndex < 0)
            {
                newIndex = 0;
            }
            if (newIndex > [currentParticleIndexes count] - 1)
            {
                newIndex = [currentParticleIndexes count] - 1;
            }
            
            [newParticleIndexes addObject:[NSNumber numberWithInteger:newIndex]];
        }

        [self->newSwarm addObject:newParticleIndexes];
    }
}

// PUBLIC: Method which swaps newly created swarm to become current swarm
- (void) swarmSwap
{
    [self->currentSwarm removeAllObjects];
    [self->currentSwarm addObjectsFromArray:self->newSwarm];
    [self->newSwarm removeAllObjects];
}

// PRIVATE: Shuffle items in array in order to generate new combination of items
- (void) shuffleItems
{    
    NSUInteger count = [self->indexes count];
    
    for (NSUInteger i = 0; i < count; ++i) 
    {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        
        // Do the shuffle
        [self->indexes exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

// PRIVATE: Method which generates new particle from given indexes order
- (NSMutableArray *) generateParticleFromIndexes:(NSMutableArray *)indexesArray
{
    NSMutableArray *newParticle = [NSMutableArray new];
    
    for (NSNumber *index in indexesArray)
    {
        [newParticle addObject:[self->particles objectAtIndex:[index intValue]]];
    }
    
    return newParticle;
}

@end
