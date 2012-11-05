/* DialogExtension */

#import <Cocoa/Cocoa.h>

@interface NSObject(dialogExtension_)
	
- (int)displayMessage:(NSString *)messageStyle
					messageText:(NSString *)messageText
					infoText:(NSString *)infoText
					btnList:(NSString *)btnList;

- (int)displayMessageWithIcon:(NSString *)iconName
					messageText:(NSString *)messageText
					infoText:(NSString *)infoText
					btnList:(NSString *)btnList;

- (int)displayMessageAlertOpenVideo:(NSString*)url;
- (int)displayMessageAlertOpenURLWithBrowser:(NSString*)url;
- (int)displayMessageAlertWithOpenLog:(NSString *)messageText
							logString:(NSString *)logString
							target:(id)target;

- (NSArray*)selectFilePathWithOpenPanel:(BOOL)isFile
								isDir:(BOOL)isDir
								isMultiSel:(BOOL)isMultiSel
								isPackage:(BOOL)isPackage
								isAlias:(BOOL)isAlias
								canCreateDir:(BOOL)canCreateDir
								defaultPath:(NSString*)defaultPath;

- (NSString*)selectFilePathWithSavePanel:(NSString*)fileName
						canCreateDir:(BOOL)canCreateDir
						defaultPath:(NSString*)defaultPath;
@end
