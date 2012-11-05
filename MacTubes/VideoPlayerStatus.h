/* VideoPlayerStatus */

#define VIDEO_PLAYER_TYPE_SWF		0
#define VIDEO_PLAYER_TYPE_VIDEO		1
#define VIDEO_PLAYER_TYPE_QUICKTIME	2

// swf player state
#define SWF_LOAD_STATE_UNKNOWN			-1
#define SWF_LOAD_STATE_INIT				0
#define SWF_LOAD_STATE_LOAD				1
#define SWF_LOAD_STATE_CANPLAY			2
#define SWF_LOAD_STATE_BUFFER			3
#define SWF_LOAD_STATE_QUE				5
#define SWF_LOAD_STATE_ERROR			9

#define SWF_PLAY_STATE_NONE				-1
#define SWF_PLAY_STATE_ENDED			0
#define SWF_PLAY_STATE_PLAY				1
#define SWF_PLAY_STATE_PAUSE			2

// video load state
#define VIDEO_LOAD_STATE_INIT				0
#define VIDEO_LOAD_STATE_LOAD				1
#define VIDEO_LOAD_STATE_CANPLAY			2
#define VIDEO_LOAD_STATE_CANPLAYTHROUGH		3
#define VIDEO_LOAD_STATE_ERROR				9

// video play state
#define VIDEO_PLAY_STATE_NONE				-1
#define VIDEO_PLAY_STATE_ENDED				0
#define VIDEO_PLAY_STATE_PLAY				1
#define VIDEO_PLAY_STATE_PAUSE				2

// video control state
#define VIDEO_CONTROL_STATE_NONE			0
#define VIDEO_CONTROL_STATE_SEEKED			1
#define VIDEO_CONTROL_STATE_VOLUMECHANGE	2

// notification
#define VIDEO_NOTIF_OBJECT_DID_CHANGED		@"videoObjectDidChanged"
#define VIDEO_NOTIF_LOADING_DID_CHANGED		@"videoLoadingDidChanged"
#define VIDEO_NOTIF_LOADED_DID_CHANGED		@"videoLoadedDidChanged"
#define VIDEO_NOTIF_PLAY_DID_CHANGED		@"videoPlayDidChanged"
#define VIDEO_NOTIF_TIME_DID_CHANGED		@"videoTimeDidChanged"
#define VIDEO_NOTIF_RATE_DID_CHANGED		@"videoRateDidChanged"
#define VIDEO_NOTIF_SIZE_SCALE_DID_CHANGED	@"videoSizeScaleDidChanged"
#define VIDEO_NOTIF_FILE_FORMAT_DID_CHANGED	@"videoFileFormatDidChanged"
#define VIDEO_NOTIF_DEFAULT_PLAYER_TYPE_DID_CHANGED		@"videoDefaultPlayerTypeDidChanged"
#define VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED		@"videoVideoPlayerTypeDidChanged"
#define VIDEO_NOTIF_STATUS_DID_CHANGED		@"videoStatusDidChanged"
