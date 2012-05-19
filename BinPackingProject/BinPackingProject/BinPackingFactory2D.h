//
//  BinPackingFactory2D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory2D : NSObject

- (id) initWithStorageWidth:(CGFloat)width 
                storageHeight:(CGFloat)height;

- (void) firstFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles;

@end
