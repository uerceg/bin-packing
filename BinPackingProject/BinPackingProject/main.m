//
//  main.m
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>
#import "BinPackingFactory1D.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        NSMutableArray * inputItems = [NSMutableArray new];
        BinPackingFactory1D * binPackingFactory1D = [[BinPackingFactory1D alloc] init];
        
        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.7f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.3f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.9f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.8f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.3f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
        
        
        // Write output information how many beans was used for packing
        NSLog(@"[FF] Number of used bins: %lu", [binPackingFactory1D firstFitAlgorithmForGivenItems:inputItems 
                                                                                   withBinCapacity:1.0f]);
        
        NSLog(@"[BF] Number of used bins: %lu", [binPackingFactory1D bestFitAlgorithmForGivenItems:inputItems 
                                                                                   withBinCapacity:1.0f]);
        
        NSLog(@"[PM] Number of used bins: %lu", [binPackingFactory1D detailSearchAlgorithmForGivenItems:inputItems 
                                                                                        withBinCapacity:1.0f]);
        
        NSLog(@"[GA] Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
                                                                                numberOfUnitsInGeneration:10 
                                                                                      numberOfGenerations:100 
                                                                                 mutationFactorPercentage:2]);
    }
    
    return 0;
}