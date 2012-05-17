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
        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
        [inputItems addObject:[NSNumber numberWithFloat:0.8f]];
        
        // Write output information how many beans was used for packing
        NSLog(@"Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
                                                                                numberOfUnitsInGeneration:20 
                                                                                      numberOfGenerations:500 
                                                                                 mutationFactorPercentage:5]);
    }
    
    return 0;
}