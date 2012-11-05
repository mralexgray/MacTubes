/* DownloadItem */

#import <Cocoa/Cocoa.h>
#import "DownloadStatus.h"
#import "FetchItem.h"
#import "FetchItemStatus.h"

@interface DownloadItem : NSObject
{

	NSURLDownload *download_;

	long long totalLength_;
	long long receivedLength_;
	int status_;
	int fetchStatus_;

	NSString *downloadURL_;
	NSString *watchURL_;
	NSString *fileName_;
	NSString *filePath_;
	NSString *fileExt_;
	NSString *errorLog_;
	int fileFormatNo_;
	BOOL isGetURL_;
	NSImage* iconImage_;
	NSTimer *requestTimer_;
	NSTimer *notifyTimer_;
	FetchItem *fetchItem_;

}
- (id)initWithURLString:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL;

- (void)startFetchItemByTimer:(NSString*)watchURL
					fileFormatNo:(int)fileFormatNo
						interval:(float)interval;
- (void)startFetchItem:(id)sender;
- (void)startFetch:(NSString*)watchURL fileFormatNo:(int)fileFormatNo;

- (BOOL)startDownload:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL;
- (NSURLDownload*)createDownload:(NSString*)downloadURL;

- (void)cancelDownload;

- (void)notifyDownloadItemChange:(DownloadItem*)item;

- (void)setDownload:(NSURLDownload*)download;
- (NSURLDownload*)download;

- (void)setTotalLength:(long long)totalLength;
- (long long)totalLength;
- (void)setReceivedLength:(long long)receivedLength;
- (long long)receivedLength;
- (void)setStatus:(int)status;
- (int)status;

- (void)setDownloadURL:(NSString*)downloadURL;
- (NSString*)downloadURL;
- (void)setWatchURL:(NSString*)watchURL;
- (NSString*)watchURL;

- (void)setFileName:(NSString*)fileName;
- (NSString*)fileName;
- (void)setFilePath:(NSString*)filePath;
- (NSString*)filePath;
- (void)setFileExt:(NSString*)fileExt;
- (NSString*)fileExt;
- (void)setFileFormatNo:(int)fileFormatNo;
- (int)fileFormatNo;
- (void)setIsGetURL:(BOOL)isGetURL;
- (BOOL)isGetURL;
- (void)setIconImage:(NSImage*)iconImage;
- (NSImage*)iconImage;
- (void)setErrorLog:(NSString*)errorLog;
- (NSString*)errorLog;

- (void)setFetchItem:(FetchItem*)fetchItem;
- (FetchItem*)fetchItem;
- (void)cancelFetchItem;
- (void)setFetchStatus:(int)fetchStatus;
- (int)fetchStatus;

- (void)setRequestTimer:(NSTimer*)requestTimer;
- (NSTimer*)requestTimer;
- (void)cancelRequestTimer;

- (void)setNotifyTimer:(NSTimer*)notifyTimer;
- (NSTimer*)notifyTimer;

- (void)startNotifyTimer;
- (void)cancelNotifyTimer;
- (void)sendNotifyWithTimer:(NSTimer*)aTimer;

@end
