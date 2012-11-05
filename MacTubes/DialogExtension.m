#import "DialogExtension.h"
#import "LogStatusController.h"

@implementation NSObject(dialogExtension_)

//------------------------------------
// displayMessage
//------------------------------------
- (int)displayMessage:(NSString *)messageStyle
					messageText:(NSString *)messageText
					infoText:(NSString *)infoText
					btnList:(NSString *)btnList
{
	NSAlert *alert;
    int i,result;
	NSArray *btnArray;

    alert = [[[NSAlert alloc] init] autorelease];

	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:messageText];
	if(![infoText isEqualToString:@""]){
		[alert setInformativeText:infoText];
	}

	if([messageStyle isEqualToString:@"alert"]){
		[alert setIcon:[NSImage imageNamed:@"icon_alert"]];
	}
	else if([messageStyle isEqualToString:@"error"]){
		[alert setIcon:[NSImage imageNamed:@"icon_stop"]];
	}
	else if([messageStyle isEqualToString:@"info"]){
		[alert setIcon:[NSImage imageNamed:@"icon_info"]];
	}
	else{
		[alert setIcon:[NSImage imageNamed:@"icon_info"]];
	}

	btnArray = [btnList componentsSeparatedByString:@","];
	for(i = 0; i < [btnArray count]; i++){
		[alert addButtonWithTitle:[btnArray objectAtIndex:i]];
	}

	result = [alert runModal];
	return result;

}
//------------------------------------
// displayMessageWithIcon
//------------------------------------
- (int)displayMessageWithIcon:(NSString *)iconName
					messageText:(NSString *)messageText
					infoText:(NSString *)infoText
					btnList:(NSString *)btnList
{
	NSAlert *alert;
    int i,result;
	NSArray *btnArray;

    alert = [[[NSAlert alloc] init] autorelease];

	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:messageText];
	if(![infoText isEqualToString:@""]){
		[alert setInformativeText:infoText];
	}

	if(![iconName isEqualToString:@""]){
		[alert setIcon:[NSImage imageNamed:iconName]];
	}else{
		[alert setIcon:[NSImage imageNamed:@"icon_info"]];
	}

	btnArray = [btnList componentsSeparatedByString:@","];
	for(i = 0; i < [btnArray count]; i++){
		[alert addButtonWithTitle:[btnArray objectAtIndex:i]];
	}

	result = [alert runModal];
	return result;

}
//------------------------------------
// displayMessageAlertOpenVideo 
//------------------------------------
- (int)displayMessageAlertOpenVideo:(NSString*)url
{
	NSString *btnList = @"";
	if(url && ![url isEqualToString:@""]){
		btnList = @"Cancel,Log,Open URL";
	}else{
		btnList = @"Cancel,Log";
	}

	return [self displayMessage:@"alert"
						messageText:@"Can not open video"
						infoText:@"Please open URL with browser"
						btnList:btnList
			];
}

//------------------------------------
// displayMessageAlertOpenURLWithBrowser 
//------------------------------------
- (int)displayMessageAlertOpenURLWithBrowser:(NSString*)url
{
	return [self displayMessage:@"alert"
						messageText:[NSString stringWithFormat:@"Can not open url with browser url=%@", url]
						infoText:@""
						btnList:@"Cancel"
			];
}
//------------------------------------
// displayMessageAlertWithOpenLog
//------------------------------------
- (int)displayMessageAlertWithOpenLog:(NSString *)messageText
							logString:(NSString *)logString
							target:(id)target
{

	int result = [self displayMessage:@"alert"
					messageText:messageText
					infoText:@"Please check error log"
					btnList:@"Cancel,Log"
			];

	// show log
	if(result == NSAlertSecondButtonReturn){
		[target setTitle:@"Error Log"];
		[target setLogString:logString];
		[target openLogWindow:nil];
	}else{
		[target setTitle:@""];
		[target setLogString:@""];
	}

	return result;

}
//------------------------------------
// selectFilePathWithOpenPanel
//------------------------------------
- (NSArray*)selectFilePathWithOpenPanel:(BOOL)isFile
						isDir:(BOOL)isDir
						isMultiSel:(BOOL)isMultiSel
						isPackage:(BOOL)isPackage
						isAlias:(BOOL)isAlias
						canCreateDir:(BOOL)canCreateDir
						defaultPath:(NSString*)defaultPath
{
	NSOpenPanel* openPanel;
	int	result;
	NSArray* filePaths = [[[NSArray alloc] init] autorelease];
//	defaultPath = [defaultPath stringByDeletingLastPathComponent];

	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:isFile];
	[openPanel setCanChooseDirectories:isDir];
	[openPanel setAllowsMultipleSelection:isMultiSel];
	[openPanel setTreatsFilePackagesAsDirectories:isPackage];
	[openPanel setResolvesAliases:isAlias];
	[openPanel setCanCreateDirectories:canCreateDir];

	result = [openPanel runModalForDirectory:defaultPath file:nil types:nil];

	if (result == NSFileHandlingPanelOKButton) {
		filePaths = [openPanel filenames];
	}

	return filePaths;

}
//------------------------------------
// selectFilePathWithSavePanel
//------------------------------------
- (NSString*)selectFilePathWithSavePanel:(NSString*)fileName
						canCreateDir:(BOOL)canCreateDir
						defaultPath:(NSString*)defaultPath
{

	NSSavePanel* savePanel;
	int	result;
	NSString *filePath = @"";

	savePanel = [NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:canCreateDir];

	result = [savePanel runModalForDirectory:defaultPath file:fileName];

	if (result == NSFileHandlingPanelOKButton) {
		filePath = [savePanel filename];
	}

	return filePath;
}

@end