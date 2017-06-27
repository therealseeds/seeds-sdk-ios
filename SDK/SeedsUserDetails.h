//
//  SeedsUserDetails.h
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

extern NSString* const kCLYUserName;
extern NSString* const kCLYUserUsername;
extern NSString* const kCLYUserEmail;
extern NSString* const kCLYUserOrganization;
extern NSString* const kCLYUserPhone;
extern NSString* const kCLYUserGender;
extern NSString* const kCLYUserPicture;
extern NSString* const kCLYUserPicturePath;
extern NSString* const kCLYUserBirthYear;
extern NSString* const kCLYUserCustom;

#pragma mark - SeedsUserDetails
@interface SeedsUserDetails : NSObject

@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* email;
@property(nonatomic,strong) NSString* organization;
@property(nonatomic,strong) NSString* phone;
@property(nonatomic,strong) NSString* gender;
@property(nonatomic,strong) NSString* picture;
@property(nonatomic,strong) NSString* picturePath;
@property(nonatomic,readwrite) NSInteger birthYear;
@property(nonatomic,strong) NSDictionary* custom;

+(SeedsUserDetails*)sharedUserDetails;
-(void)deserialize:(NSDictionary*)userDictionary;
-(NSString*)serialize;
-(NSString*)extractPicturePathFromURLString:(NSString*)URLString;

@end
