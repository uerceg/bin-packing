//
//  Box.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/28/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface Box : NSObject

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float length;
@property (nonatomic, readonly) float height;

- (id) initWithWidth:(float)initWidth 
              length:(float)initLength 
              height:(float)initHeight;

- (BOOL) isEqualToBox:(Box *)aBox; 

@end
