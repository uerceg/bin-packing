//
//  GeneticAlgorithmFactory1D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

@interface GeneticAlgorithmFactory1D : NSObject

@property (nonatomic, readonly) NSUInteger lowestCost;

- (id) initWithNumberOfItemsInGeneration:(NSUInteger)numberOfUnits 
                              itemsArray:(NSMutableArray *)itemsArray;

- (void) mate;
- (void) generationSwap;
- (void) generateInitialPopulation;
- (void) mutate:(NSUInteger)mutationFactorPercentage;
- (void) calculateGenerationCost:(NSUInteger (^) (NSMutableArray *)) fitnessFunction;

@end
