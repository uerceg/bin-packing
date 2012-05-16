//
//  GeneticAlgorithmFactory1D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

@interface GeneticAlgorithmFactory1D : NSObject

@property (nonatomic) int lowestCost;

- (id) initWithItemArray:(NSMutableArray *)itemsArray:(int)numberOfUnits;

- (void) generateInitialPopulation;
- (void) mate;
- (void) generationSwap;
- (void) mutate:(int)mutationFactorPercentage;
- (void) calculateGenerationCost:(int (^) (NSMutableArray *)) fitnessFunction;

@end
