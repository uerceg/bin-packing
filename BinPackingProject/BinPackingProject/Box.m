//
//  Box.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/28/12.
//  Open Source project
//

#import "Box.h"

@implementation Box
{
    @private float width;
    @private float length;
    @private float height;
}

@synthesize width, length, height;

- (id) initWithWidth:(float)initWidth 
                length:(float)initLength 
                height:(float)initHeight
{
    if (self = [super init]) 
    {        
        self->width = initWidth;
        self->length = initLength;
        self->height = initHeight;
    }
    
    return self;
}

- (BOOL) isEqualToBox:(Box *)aBox
{
    {
        if (self == aBox)
        {
            return YES;
        }
        if (self.width != aBox.width)
        {
            return NO;
        }
        if (self.height != aBox.height)
        {
            return NO;
        }
        if (self.length != aBox.length)
        {
            return NO;
        }
        
        return YES;
    }
}

@end
