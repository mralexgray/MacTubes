#import "ImageBindController.h"
#import "UserDefaultsExtension.h"

static const int ICON_SIZE = 14;
 
@implementation ImageBindController

//------------------------------------
// createImage
//------------------------------------
- (NSImage*)createImage:(NSString*)imageName
{

	if([self defaultBoolValue:@"optShowMenuIcon"] == YES){
		NSImage *image = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]] autorelease];
		[image setScalesWhenResized:YES];
		[image setSize:NSMakeSize(ICON_SIZE,ICON_SIZE)];
		return image;
//		return [NSImage imageNamed:imageName];
	}else{
		return nil;
	}

}

//------------------------------------
// iconVideo
//------------------------------------
- (NSImage*)iconVideo
{
	return [self createImage:@"icon_video"];
}
//------------------------------------
// iconPlaylist
//------------------------------------
- (NSImage*)iconPlaylist
{
	return [self createImage:@"icon_playlist"];
}
//------------------------------------
// iconPlaylistGray
//------------------------------------
- (NSImage*)iconPlaylistGray
{
	return [self createImage:@"icon_playlist_gray"];
}

//------------------------------------
// iconCategory
//------------------------------------
- (NSImage*)iconCategory
{
	return [self createImage:@"icon_category"];
}
//------------------------------------
// iconFeed
//------------------------------------
- (NSImage*)iconFeed
{
	return [self createImage:@"icon_feed"];
}
//------------------------------------
// iconFolder
//------------------------------------
- (NSImage*)iconFolder
{
	return [self createImage:@"icon_folder"];
}
//------------------------------------
// iconSearch
//------------------------------------
- (NSImage*)iconSearch
{
	return [self createImage:@"icon_search"];
}
//------------------------------------
// iconAuthor
//------------------------------------
- (NSImage*)iconAuthor
{
	return [self createImage:@"icon_author"];
}
//------------------------------------
// iconWebSearch
//------------------------------------
- (NSImage*)iconWebSearch
{
	return [self createImage:@"icon_websearch"];
}
//------------------------------------
// iconDownload
//------------------------------------
- (NSImage*)iconDownload
{
	return [self createImage:@"icon_arrow_down"];
}
//------------------------------------
// iconCopy
//------------------------------------
- (NSImage*)iconCopy
{
	return [self createImage:@"icon_copy"];
}
//------------------------------------
// iconComment
//------------------------------------
- (NSImage*)iconComment
{
	return [self createImage:@"icon_comment"];
}
//------------------------------------
// iconItemInfo
//------------------------------------
- (NSImage*)iconItemInfo
{
	return [self createImage:@"icon_item_info"];
}
//------------------------------------
// iconEdit
//------------------------------------
- (NSImage*)iconEdit
{
	return [self createImage:@"icon_edit"];
}
//------------------------------------
// iconExport
//------------------------------------
- (NSImage*)iconExport
{
	return [self createImage:@"icon_export"];
}
//------------------------------------
// iconDelete
//------------------------------------
- (NSImage*)iconDelete
{
	return [self createImage:@"icon_delete"];
}

@end
