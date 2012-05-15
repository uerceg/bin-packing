//
//  GeneticAlgorithmFactory1D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface GeneticAlgorithmFactory1D : NSObject

- (void) generateInitialPopulation;
- (void) mate;
- (void) mutate;
- (void) calculateGenerationCost;

@end
