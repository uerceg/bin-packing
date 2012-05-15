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
    int numberOfItemsInUnit;
    int numberOfUnitsInGeneration;
    int numberOfGenerationsInAlgorithm;
    
    NSMutableArray *items;
    NSMutableArray *currentGeneration;
}

// Default initializator
- (id) initWithItemArray:(NSMutableArray *)items:(int)numberOfUnitsInGeneration:(int)numberOfGenerationsInAlgorithm
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

@end
