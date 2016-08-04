//
//  SeedsUrlFormatter.h
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

@interface SeedsUrlFormatter: NSObject

NSString* SeedsJSONFromObject(id object);
NSString* SeedsURLEscapedString(NSString* string);
NSString* SeedsURLUnescapedString(NSString* string);

@end

@interface NSMutableData (AppendStringUTF8)
-(void)appendStringUTF8:(NSString*)string;
@end


