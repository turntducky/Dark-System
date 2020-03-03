#include <substrate.h>
#include <UIKit/UIStatusBar.h>
#include <SpringBoard/SpringBoard.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UITableView.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "Tweak.h"

static NSMutableDictionary *settings;
static BOOL enabled;
static BOOL notifications;
static BOOL notification3d;
static BOOL widgets;
static BOOL touch3d;
static BOOL folders;
static BOOL popups;
static BOOL dock;
static BOOL keyboard;
static BOOL searchbar;
static int mode;

static NSString *uButtonColor = nil;

static CGRect ccBounds;
static BOOL trueTone;

static CKUIThemeDark *darkTheme;

static UIImage *nightImage;
static UIImage *toneImage;

static NSBundle *localizeBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Darkmode/Localization.bundle"];

static void toggleRelatedDarkModeTweaks(bool setOn) {
  NSMutableDictionary *eclipsePreferences = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist"]];
  if (eclipsePreferences) {
    CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:setOn], CFSTR("com.gmoran.eclipse"));
  }

  NSArray *foxfortTweaks = @[@"amazonite", @"facebookdarkmode", @"deluminator", @"fbdarkadmin", @"darkgmaps", @"darksounds", @"gmailmidnight", @"nightmaps"];
  for (NSString *tweak in foxfortTweaks){
    NSString *plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/com.foxfort.%@settings.plist", tweak];
    NSMutableDictionary *tweakPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (tweakPreferences) {
      CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:setOn], (CFStringRef)[NSString stringWithFormat:@"com.foxfort.%@settings.plist", tweak]);
    }
  }
}

//Toggle Notifications
static void enableDarkmode(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.ducksrepo.darkmode.update" object:nil userInfo:nil];
  toggleRelatedDarkModeTweaks(enabled);
}

static void disbaleDarkmode(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.ducksrepo.darkmode.update" object:nil userInfo:nil];
  toggleRelatedDarkModeTweaks(enabled);
}


static void darkmodeEnabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.ducksrepo.darkmode.enabled"), nil, nil, true);
}

static void darkmodeDisabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.ducksrepo.darkmode.disabled"), nil, nil, true);
}

//Preference Updates
static void refreshPrefs() {
  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.twickd.turnt-ducky.darkmode"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.twickd.turnt-ducky.darkmode"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    CFRelease(keyList);
  } else {
    settings = nil;
  }
  if (!settings) {
    settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.twickd.turnt-ducky.darkmode.plist"];
  }

  enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
  notifications = [([settings objectForKey:@"notifications"] ?: @(YES)) boolValue];
  notification3d = [([settings objectForKey:@"notification3d"] ?: @(YES)) boolValue];
  widgets = [([settings objectForKey:@"widgets"] ?: @(YES)) boolValue];
  touch3d = [([settings objectForKey:@"touch3d"] ?: @(YES)) boolValue];
  folders = [([settings objectForKey:@"folders"] ?: @(YES)) boolValue];
  dock = [([settings objectForKey:@"dock"] ?: @(YES)) boolValue];
  keyboard = [([settings objectForKey:@"keyboard"] ?: @(YES)) boolValue];
  searchbar = [([settings objectForKey:@"searchbar"] ?: @(YES)) boolValue];
  popups = [([settings objectForKey:@"popups"] ?: @(YES)) boolValue];
  mode = [([settings objectForKey:@"mode"] ?: 0) floatValue];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.ducksrepo.darkmode.update" object:nil userInfo:nil];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
  if (enabled) {
    darkmodeEnabled();
  } else {
    darkmodeDisabled();
  }
}

//Dark Popups
%hook UIAlertControllerVisualStyleAlert
- (UIColor *)titleLabelColor {
  if (enabled & popups) {
    return UIColor.whiteColor;
  } else {
    return %orig;
  }
}

- (UIColor *)messageLabelColor {
  if (enabled & popups) {
    return UIColor.whiteColor;
  } else {
    return %orig;
  }
}

%end

%hook UIAlertControllerVisualStyleActionSheet
- (UIColor *)titleLabelColor {
  if (enabled & popups) {
    return UIColor.whiteColor;
  } else {
    return %orig;
  }
}

- (UIColor *)messageLabelColor {
  if (enabled & popups) {
    return UIColor.whiteColor;
  } else {
    return %orig;
  }
}
%end

%hook UIInterfaceActionVisualStyleViewState
-(bool)isDark {
  if (enabled & popups) {
    return 1;
  } else {
    return 0;
  }
}
%end

%hook _UIAlertControlleriOSActionSheetCancelBackgroundView
-(void)layoutSubviews {
}
%end

//Widget Hooks
%group Extension
%hook UILabel
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.darkTextColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
- (void)setTextColor:(UIColor *)color {
  if (!self.isObserving) {
    self.darkTextColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
  if (color != self.darkTextColor) {
    self.lightTextColor = color;
  }
  if (self.darkTextColor && enabled && widgets) {
    %orig(self.darkTextColor);
  } else {
    %orig;
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  if (self.darkTextColor) {
    if (enabled) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UIButton
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTintColor;
%property (nonatomic, retain) UIColor *lightTintColor;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.darkTintColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
- (void)setTintColor:(UIColor *)color {
  if (color != self.darkTintColor) {
    self.lightTintColor = color;
  }
  if (self.darkTintColor && enabled && widgets) {
    %orig(self.darkTintColor);
  } else {
    %orig;
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  [self enableDarkmode:enabled];
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkTintColor) {
    if (enable) {
      self.tintColor = self.darkTintColor;
    } else {
      self.tintColor = self.lightTintColor;
    }
  }
}
%end

%hook UIActivityIndicatorView
- (void)setColor:(UIColor *)color {
  if (enabled) {
    %orig([UIColor whiteColor]);
  } else {
    %orig;
  }
}
%end
%end

%group Invert
%hook CALayer
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *darkFilters;
%property (nonatomic, retain) NSArray *lightFilters;
%property (nonatomic, retain) CAFilter *darkFilter;
%property (nonatomic, retain) CAFilter *lightFilter;
- (void)layoutSublayers {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
- (void)setFilters:(NSArray *)filters {
  if (self.filters != self.darkFilters) {
    self.lightFilters = self.filters;
  }
  %orig;
}
- (void)setCompositingFilter:(CAFilter *)filter {
  if (self.compositingFilter != self.darkFilter) {
    self.lightFilter = self.compositingFilter;\
  }
  %orig;
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  if (self.filters && !self.darkFilters) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    [self setDarkFilters:[NSArray arrayWithObject:colorInvert]];
  }
  if (self.compositingFilter && !self.darkFilter) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    [self setDarkFilter:colorInvert];
  }
  if (enabled && widgets) {
    [self enableDarkmode:YES];
  } else {
    [self enableDarkmode:NO];
  }
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkFilters) {
    if (enable) {
      self.filters = self.darkFilters;
    } else {
      self.filters = self.lightFilters;
    }
  }
  if (self.darkFilter) {
    if (enable) {
      self.compositingFilter = self.darkFilter;
    } else {
      self.compositingFilter = self.lightFilter;
    }
  }
}
%end
%end

%group SpringBoard
//Dark Darkened Objects
%hook CALayer
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *darkFilters;
%property (nonatomic, retain) NSArray *lightFilters;
- (void)setFilters:(NSArray *)filters {
  if (filters && ![filters isEqual:self.darkFilters]) {
    self.lightFilters = filters;
    if (enabled && self.darkFilters) {
      %orig(self.darkFilters);
    }
  }
  %orig;
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkFilters) {
    if (enable) {
      self.filters = self.darkFilters;
    } else {
      self.filters = self.lightFilters;
    }
  }
}
%end

%hook UILabel
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UITextView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UIView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkBackgroundColor;
%property (nonatomic, retain) UIColor *lightBackgroundColor;
%property (nonatomic, retain) NSNumber *darkAlpha;
%property (nonatomic, retain) NSNumber *lightAlpha;
- (void)setBackgroundColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkBackgroundColor]) {
    self.lightBackgroundColor = color;
  }
  %orig;
}
- (void)setAlpha:(CGFloat)alpha {
  if (alpha && alpha != [self.darkAlpha floatValue]) {
    self.lightAlpha = [NSNumber numberWithFloat:alpha];
  }
  %orig;
}
%new
- (void)enableDarkmode:(bool)enable {
 if (self.darkBackgroundColor) {
    if (enable) {
      self.backgroundColor = self.darkBackgroundColor;
    } else {
      self.backgroundColor = self.lightBackgroundColor;
    }
  }
  if (self.darkAlpha) {
    if (enable) {
      self.alpha = [self.darkAlpha floatValue];
    } else {
      self.alpha = [self.lightAlpha floatValue];
    }
  }
}
%end

%hook BSUIEmojiLabelView
%property (nonatomic, retain) UIColor *lightTextColor;
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
- (void)layoutSubviews {
  %orig;
  if ([self.superview.superview isKindOfClass:%c(NCNotificationContentView)] && !self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  if (!self.layer.darkFilters) {
    CAFilter* filter = [CAFilter filterWithName:@"vibrantDark"];
    [filter setDefaults];
    [[self layer] setDarkFilters:[NSArray arrayWithObject:filter]];
  }
  if (enabled && notifications) {
    [[self layer] enableDarkmode:YES];
  } else {
    [[self layer] enableDarkmode:NO];
  }
}
%new
- (void)enableDarkmode:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

//Dark Notifications
%hook NCNotificationShortLookView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");

  if (mainOverlayView.backgroundColor != nil) {
    if (enabled && notifications && arg1 == YES ) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
      mainOverlayView.backgroundColor = blackColor;
    }
    if (enabled && notifications && arg1 == NO) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
      mainOverlayView.backgroundColor = blackColor;
    }
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");
  MTPlatterHeaderContentView *headerContentView = [self _headerContentView];
  NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");

  UIColor *whiteColor = [UIColor whiteColor];
  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];

  //Do Not Disturb fix
  if (mainOverlayView.backgroundColor != nil) {
    [mainOverlayView setDarkBackgroundColor:blackColor];

    [[[headerContentView _titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
    [[[headerContentView _dateLabel] layer] setDarkFilters:[[NSArray alloc] init]];
    [[headerContentView _titleLabel] setDarkTextColor:whiteColor];
    [[headerContentView _dateLabel] setDarkTextColor:whiteColor];

    [[notificationContentView _secondaryTextView] setDarkTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setDarkTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setDarkTextColor:whiteColor];

    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] setDarkTextColor:whiteColor];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] setDarkTextColor:whiteColor];
  }

  if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
    MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView").darkBackgroundColor = [UIColor clearColor];
  }

  if (enabled && notifications && mainOverlayView.backgroundColor != nil) {
    [mainOverlayView enableDarkmode:YES];
    [[headerContentView _titleLabel] enableDarkmode:YES];
    [[headerContentView _dateLabel] enableDarkmode:YES];
    [[[headerContentView _titleLabel] layer] enableDarkmode:YES];
    [[[headerContentView _dateLabel] layer] enableDarkmode:YES];
    [[notificationContentView _secondaryTextView] enableDarkmode:YES];
    [[notificationContentView _primaryLabel] enableDarkmode:YES];
    [[notificationContentView _primarySubtitleLabel] enableDarkmode:YES];
    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] enableDarkmode:YES];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] enableDarkmode:YES];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") enableDarkmode:YES];
    }
  } else if (mainOverlayView.backgroundColor != nil) {
    [mainOverlayView enableDarkmode:NO];
    [[headerContentView _titleLabel] enableDarkmode:NO];
    [[headerContentView _dateLabel] enableDarkmode:NO];
    [[[headerContentView _titleLabel] layer] enableDarkmode:NO];
    [[[headerContentView _dateLabel] layer] enableDarkmode:NO];
    [[notificationContentView _secondaryTextView] enableDarkmode:NO];
    [[notificationContentView _primaryLabel] enableDarkmode:NO];
    [[notificationContentView _primarySubtitleLabel] enableDarkmode:NO];
    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] enableDarkmode:NO];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] enableDarkmode:NO];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") enableDarkmode:YES];
    }
  }
}
%end

//Dark Widgets
%hook WGWidgetPlatterView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UIView *headerOverlayView = MSHookIvar<UIView *>(self, "_headerOverlayView");
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");
  MTPlatterHeaderContentView *headerContentView = [self _headerContentView];

  UIColor *whiteColor = [UIColor whiteColor];
  UIColor *headColor = [UIColor colorWithWhite:0.0 alpha:0.7];
  UIColor *mainColor = [UIColor colorWithWhite:0.0 alpha:0.54];

  [headerOverlayView setDarkBackgroundColor:headColor];
  [mainOverlayView setDarkBackgroundColor:mainColor];

  if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
    MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView").darkBackgroundColor = [UIColor clearColor];
  }

  [[headerContentView _titleLabel] setDarkTextColor:whiteColor];
  [[[headerContentView _titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
  if ([self showMoreButton]) {
    [[[self showMoreButton] titleLabel] setDarkTextColor:whiteColor];
    [[[[self showMoreButton] titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
  }

  if (enabled && widgets) {
    [headerOverlayView enableDarkmode:YES];
    [mainOverlayView enableDarkmode:YES];
    [[headerContentView _titleLabel] enableDarkmode:YES];
    [[[headerContentView _titleLabel] layer] enableDarkmode:YES];
    if ([self showMoreButton]) {
      [[[self showMoreButton] titleLabel] enableDarkmode:YES];
      [[[[self showMoreButton] titleLabel] layer] enableDarkmode:YES];
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") enableDarkmode:YES];
    }
  } else {
    [headerOverlayView enableDarkmode:NO];
    [mainOverlayView enableDarkmode:NO];
    [[headerContentView _titleLabel] enableDarkmode:NO];
    [[[headerContentView _titleLabel] layer] enableDarkmode:NO];
    if ([self showMoreButton]) {
      [[[self showMoreButton] titleLabel] enableDarkmode:NO];
      [[[[self showMoreButton] titleLabel] layer] enableDarkmode:NO];
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") enableDarkmode:NO];
    }
  }
}
%end

//Dark Notification 3D Touch
%hook NCNotificationLongLookView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UIColor *whiteColor = [UIColor whiteColor];

  NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");
  UIView *mainContentView = MSHookIvar<UIView *>(self, "_mainContentView");
  NCNotificationContentView *headerContentView = MSHookIvar<NCNotificationContentView *>(self, "_headerContentView");
  UIView *headerDivider = MSHookIvar<UIView *>(self, "_headerDivider");

  if (!notificationContentView.darkBackgroundColor) {
    notificationContentView.darkBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    mainContentView.darkBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    self.customContentView.darkBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    headerContentView.darkBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    headerDivider.darkBackgroundColor = [UIColor grayColor];

    [[notificationContentView _secondaryTextView] setDarkTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setDarkTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setDarkTextColor:whiteColor];
  }
  if (enabled && notification3d) {
    [notificationContentView enableDarkmode:YES];
    [mainContentView enableDarkmode:YES];
    [self.customContentView enableDarkmode:YES];
    [headerContentView enableDarkmode:YES];
    [headerDivider enableDarkmode:YES];
    [[notificationContentView _secondaryTextView] enableDarkmode:YES];
    [[notificationContentView _primaryLabel] enableDarkmode:YES];
    [[notificationContentView _primarySubtitleLabel] enableDarkmode:YES];
  } else {
    [notificationContentView enableDarkmode:NO];
    [mainContentView enableDarkmode:NO];
    [self.customContentView enableDarkmode:NO];
    [headerContentView enableDarkmode:NO];
    [headerDivider enableDarkmode:NO];
    [[notificationContentView _secondaryTextView] enableDarkmode:NO];
    [[notificationContentView _primaryLabel] enableDarkmode:NO];
    [[notificationContentView _primarySubtitleLabel] enableDarkmode:NO];
  }
}
%end

//Dark Stacked Notifications
%hook NCNotificationViewControllerView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  int count = 0;
  for (UIView *view in self.subviews) {
    if([view isKindOfClass:%c(PLPlatterView)]) {
      UIView *mainOverlayView = MSHookIvar<UIView *>(view, "_mainOverlayView");
      count++;
      if (count == 1 && self.subviews.count > 2) {
        mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.56];
      } else if (count == 2 || self.subviews.count == 2) {
        mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.55];
      } else {
      mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.55];
      }
      mainOverlayView.darkBackgroundColor = [UIColor blackColor];
      MSHookIvar<UIView *>(view, "_mainOverlayView") = mainOverlayView;

      if (enabled && notifications) {
        [MSHookIvar<UIView *>(view, "_mainOverlayView") enableDarkmode:YES];
      } else {
        [MSHookIvar<UIView *>(view, "_mainOverlayView") enableDarkmode:NO];
      }
    }
  }
}
%end

//Dark Notification Action Buttons (Manage/View/Clear/Etc.)
%hook NCNotificationListCellActionButton
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = blackColor;
  }
  if (enabled && notifications && arg1 == NO) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = blackColor;
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UIView *backgroundOverlayView = MSHookIvar<UIView *>(self, "_backgroundOverlayView");
  UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");

  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
  backgroundOverlayView.darkBackgroundColor = blackColor;
  [titleLabel.layer setDarkFilters:[[NSArray alloc] init]];

  if (enabled && notifications) {
    [backgroundOverlayView enableDarkmode:YES];
    [titleLabel.layer enableDarkmode:YES];
  } else {
    [backgroundOverlayView enableDarkmode:NO];
    [titleLabel.layer enableDarkmode:NO];
  }
}
%end

//Dark NC Clear/Show More/Show Less Buttons
%hook NCToggleControl
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = blackColor;
  }
  if (enabled && notifications && arg1 == NO) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = blackColor;
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UIView *overlayMaterialView = MSHookIvar<UIView *>(self, "_overlayMaterialView");
  UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");
  UIView *glyphView = MSHookIvar<UIView *>(self, "_glyphView");

  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
  overlayMaterialView.darkBackgroundColor = blackColor;
  CAFilter* filter = [CAFilter filterWithName:@"vibrantDark"];
  [filter setDefaults];
  [titleLabel.layer setDarkFilters:[NSArray arrayWithObject:filter]];
  [glyphView.layer setDarkFilters:[NSArray arrayWithObject:filter]];

  if (enabled && notifications) {
    [overlayMaterialView enableDarkmode:YES];
    [titleLabel.layer enableDarkmode:YES];
    [glyphView.layer enableDarkmode:YES];
  } else {
    [overlayMaterialView enableDarkmode:NO];
    [titleLabel.layer enableDarkmode:NO];
    [glyphView.layer enableDarkmode:NO];
  }
}
%end

//Dark Edit Button
%hook WGShortLookStyleButton
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  UILabel *titleLabel = MSHookIvar<UILabel*>(self, "_titleLabel");
  MTMaterialView *backgroundView = MSHookIvar<MTMaterialView*>(self, "_backgroundView");

  [[titleLabel layer] setDarkFilters:[[NSArray alloc] init]];

  for (UIView *view in backgroundView.subviews) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    view.darkBackgroundColor = blackColor;
  }

  if (enabled && widgets) {
    [titleLabel.layer enableDarkmode:YES];
    [titleLabel enableDarkmode:YES];
    for (UIView *view in backgroundView.subviews) {
      [view enableDarkmode:YES];
    }
  } else {
    [titleLabel.layer enableDarkmode:NO];
    [titleLabel enableDarkmode:NO];
    for (UIView *view in backgroundView.subviews) {
      [view enableDarkmode:NO];
    }
  }
}
%end

//Dark Search Bar
%hook SPUIHeaderBlurView
- (void)layoutSubviews {
  %orig;
  if (enabled && searchbar) {
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  } else {
    self.effect = nil;
  }
}
%end

//Dark Folders
%hook SBFolderBackgroundView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *lightSubviews;
%property (nonatomic, retain) UIVisualEffectView *darkOverlayView;
%property (nonatomic, retain) UIVisualEffectView *darkBlurView;
%property (nonatomic, retain) UIVisualEffectView *lightBlurView;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  if (!self.lightSubviews) {
    self.lightSubviews = self.subviews;
    self.lightBlurView = MSHookIvar<UIVisualEffectView *>(self, "_blurView");

    self.darkBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.darkBlurView.frame = [UIScreen mainScreen].bounds;

    self.darkOverlayView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    self.darkOverlayView.frame = [UIScreen mainScreen].bounds;
  }
  if (enabled && folders) {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.darkBlurView];
    [self.darkBlurView.contentView addSubview:self.darkOverlayView];

    MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.darkBlurView;
    self.darkBlurView.alpha = 1;
    self.darkOverlayView.alpha = 1;

    self.darkOverlayView.subviews[1].backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
  } else {
    if (!self.subviews) {
      for (UIView *view in self.lightSubviews) {
        [self addSubview:view];
      }
    }
    MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.lightBlurView;
    self.darkBlurView.alpha = 0;
    self.darkOverlayView.alpha = 0;
    [self enableDarkmode:NO];
  }
}
%end

%hook SBFolderIconBackgroundView
- (void)didAddSubview:(id)arg1 {
  return;
}
%end

%hook SBFolderIconImageView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) SBWallpaperEffectView *darkBackgroundView;
%property (nonatomic, retain) UIView *darkOverlayView;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  if (!self.darkBackgroundView) {
    UIView *backgroundView = MSHookIvar<UIView *>(self, "_backgroundView");
    self.darkBackgroundView = [[%c(SBWallpaperEffectView) alloc] initWithWallpaperVariant:1];
    [self.darkBackgroundView setFrame:backgroundView.bounds];
    [self.darkBackgroundView setStyle:27];
    self.darkBackgroundView.alpha = 1;
    self.darkBackgroundView.layer.cornerRadius = backgroundView.layer.cornerRadius;
    self.darkBackgroundView.layer.masksToBounds = backgroundView.layer.masksToBounds;
    [backgroundView addSubview:self.darkBackgroundView];

    self.darkOverlayView = [[UIView alloc] initWithFrame:backgroundView.bounds];
    self.darkOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.darkOverlayView.alpha = 1;
    self.darkOverlayView.layer.cornerRadius = backgroundView.layer.cornerRadius;
    self.darkOverlayView.layer.masksToBounds = backgroundView.layer.masksToBounds;
    [backgroundView addSubview:self.darkOverlayView];
  }
  if (enabled && folders) {
    self.darkOverlayView.alpha = 0;
    self.darkBackgroundView.alpha = 1;
    [self.darkBackgroundView setStyle:14];
  } else {
    self.darkOverlayView.alpha = 0;
    self.darkBackgroundView.alpha = 0;
  }
}
%end

//Dark Dock
%hook SBDockView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIView *darkOverlayView;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  SBWallpaperEffectView *backgroundView = MSHookIvar<SBWallpaperEffectView *>(self, "_backgroundView");
   if (!self.darkOverlayView) {
   	self.darkOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height)];
     self.darkOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
     self.darkOverlayView.alpha = 1;
     [backgroundView addSubview:self.darkOverlayView];
   }
   if (enabled && dock) {
       self.darkOverlayView.alpha = 1;
       backgroundView.wallpaperStyle = 14;
   } else {
     self.darkOverlayView.alpha = 0;
     backgroundView.wallpaperStyle = 12;
   }
}
%end

%hook SBFloatingDockPlatterView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, assign) long long lightStyle;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  _UIBackdropView *backgroundView = MSHookIvar<_UIBackdropView*>(self, "_backgroundView");
    if (!self.lightStyle) {
      self.lightStyle = backgroundView.style;
    }
      if (enabled && dock) {
        _UIBackdropView *backgroundView = MSHookIvar<_UIBackdropView*>(self, "_backgroundView");
        [backgroundView transitionToStyle:2030];
      } else {
        [backgroundView transitionToStyle:self.lightStyle];
    }
  }
%end

//Dark 3D Touch Menus
%hook SBUIIconForceTouchWrapperViewController
%property (nonatomic, assign) bool isObserving;
- (void)viewDidLayoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
  }
  [self darkmodeToggled:nil];
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  for (MTMaterialView *materialView in self.view.subviews) {
    for (UIView *view in materialView.subviews) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
      view.darkBackgroundColor = blackColor;
      if (enabled && touch3d) {
        [view enableDarkmode:YES];
      } else {
        [view enableDarkmode:NO];
      }
    }
  }
}
%end

%hook SBUIActionView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  //I know, this is terrible. I was lazy.
  if ([self.superview.superview.superview.superview.superview.superview.superview.superview isKindOfClass:%c(SBUIIconForceTouchWindow)] && !self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darkmodeToggled:) name:@"xyz.ducksrepo.darkmode.update" object:nil];
    [self darkmodeToggled:nil];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && touch3d && arg1) {
    UIColor *whiteColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.backgroundColor = whiteColor;
  } else if (enabled && touch3d && arg1 == NO) {
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
  }
}
%new
- (void)darkmodeToggled:(NSNotification *)notification {
  SBUIActionViewLabel *titleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_titleLabel");
  SBUIActionViewLabel *subtitleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_subtitleLabel");
  UILabel *title = MSHookIvar<UILabel*>(titleLabel, "_label");
  UILabel *subtitle = nil;
  if (subtitleLabel) subtitle = MSHookIvar<UILabel*>(subtitleLabel, "_label");
  UIImageView *imageView = MSHookIvar<UIImageView*>(self, "_imageView");

  if (!title.darkTextColor) {
    title.darkTextColor = [UIColor whiteColor];
    if (subtitle) subtitle.darkTextColor = [UIColor whiteColor];
    [title.layer setDarkFilters:[[NSArray alloc] init]];
    if (subtitle) [subtitle.layer setDarkFilters:[[NSArray alloc] init]];
    [imageView.layer setDarkFilters:[[NSArray alloc] init]];
  }
  if (enabled && touch3d) {
    [title enableDarkmode:YES];
    if (subtitle) [subtitle enableDarkmode:YES];
    [title.layer enableDarkmode:YES];
    if (subtitle) [subtitle.layer enableDarkmode:YES];
    [imageView.layer enableDarkmode:YES];
    imageView.tintColor = [UIColor whiteColor];
  } else {
    [title enableDarkmode:NO];
    if (subtitle) [subtitle enableDarkmode:NO];
    [title.layer enableDarkmode:NO];
    if (subtitle) [subtitle.layer enableDarkmode:NO];
    [imageView.layer enableDarkmode:NO];
    //imageView.tintColor = [UIColor blackColor];
  }
}
%end
%end

//Dark Keyboard
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
  if (enabled && keyboard) {
    %orig(NO);
  } else {
    %orig(YES);
  }
}
%end

%hook UIDevice
- (long long)_keyboardGraphicsQuality {
  if (enabled && keyboard) {
    return 10;
  } else {
    return 100;
  }
}
%end

//Control Center Toggle
%group Toggle
%subclass CCUIDarkmodeButton : CCUIRoundButton
%property (nonatomic, retain) UIView *backgroundView;
%property (nonatomic, retain) CCUICAPackageView *packageView;
- (void)layoutSubviews {
  %orig;
  if (!self.packageView) {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.userInteractionEnabled = NO;
    self.backgroundView.layer.cornerRadius = self.bounds.size.width/2;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.alpha = 0;
    [self addSubview:self.backgroundView];

    self.packageView = [[%c(CCUICAPackageView) alloc] initWithFrame:self.bounds];
    self.packageView.package = [CAPackage packageWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Application Support/Darkmode/Stylemode.ca"] type:kCAPackageTypeCAMLBundle options:nil error:nil];
    [self.packageView
    setStateName:@"on"];
    [self addSubview:self.packageView];

    [self setHighlighted:NO];
    [self updateStateAnimated:NO];
  }
}
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
  %orig;
  if (enabled) {
    darkmodeDisabled();
    CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:NO], CFSTR("com.twickd.turnt-ducky.darkmode"));
  } else {
    darkmodeEnabled();
    CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:YES], CFSTR("com.twickd.turnt-ducky.darkmode"));
  }

  refreshPrefs();
  [self updateStateAnimated:YES];
}
%new
- (void)updateStateAnimated:(bool)animated {
  if (!enabled) {
    ((CCUILabeledRoundButton *)self.superview).subtitle = [localizeBundle localizedStringForKey:@"OFF" value:@"Off" table:nil];
    [self.packageView setStateName:@"off"];
    if (animated) {
      [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.backgroundView.alpha = 1;
      } completion:nil];
    } else {
      self.backgroundView.alpha = 1;
    }
  } else {
    ((CCUILabeledRoundButton *)self.superview).subtitle = [localizeBundle localizedStringForKey:@"ON" value:@"On" table:nil];
    [self.packageView setStateName:@"on"];
    if (animated) {
      [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.backgroundView.alpha = 0;
      } completion:nil];
    } else {
      self.backgroundView.alpha = 0;
    }
  }
}
%end

%hook CCUIContentModuleContainerViewController
%property (nonatomic, retain) CCUILabeledRoundButtonViewController *darkButton;
- (void)setExpanded:(bool)arg1 {
  %orig;
  if (arg1 && ([self.moduleIdentifier isEqual:@"com.apple.control-center.DisplayModule"] || [self.moduleIdentifier isEqual:@"com.jailbreak365.control-center.TinyDisplayModule"])) {
    ccBounds = self.view.bounds;
    if (self.backgroundViewController.trueToneButton) {
      trueTone = YES;
    } else {
      trueTone = NO;
    }
    if (!self.darkButton) {
      self.darkButton = [[%c(CCUILabeledRoundButtonViewController) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      self.darkButton.buttonContainer = [[%c(CCUILabeledRoundButton) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      [self.darkButton.buttonContainer setFrame:CGRectMake(0, 0, 72, 91)];
      self.darkButton.view = self.darkButton.buttonContainer;
      self.darkButton.buttonContainer.buttonView = [[%c(CCUIDarkmodeButton) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      [self.darkButton.buttonContainer addSubview:self.darkButton.buttonContainer.buttonView];
      self.darkButton.button = self.darkButton.buttonContainer.buttonView;

      self.darkButton.title = [localizeBundle localizedStringForKey:@"DARK MODE" value:@"Dark mode" table:nil];
      if (enabled) {
        self.darkButton.subtitle = [localizeBundle localizedStringForKey:@"ON" value:@"On" table:nil];
        [((CCUIDarkmodeButton *)self.darkButton.buttonContainer.buttonView).packageView setStateName:@"on"];
      } else {
        self.darkButton.subtitle = [localizeBundle localizedStringForKey:@"OFF" value:@"Off" table:nil];
        [((CCUIDarkmodeButton *)self.darkButton.buttonContainer.buttonView).packageView setStateName:@"off"];
      }
      [self.darkButton setLabelsVisible:YES];

      [self.backgroundViewController.view addSubview:self.darkButton.buttonContainer];
    }
    [self.darkButton.buttonContainer updatePosition];
    nightImage = self.backgroundViewController.nightShiftButton.buttonContainer.glyphImage;
    [self.backgroundViewController.nightShiftButton.buttonContainer updatePosition];
    if (self.backgroundViewController.trueToneButton) {
      toneImage = self.backgroundViewController.trueToneButton.buttonContainer.glyphImage;
      [self.backgroundViewController.trueToneButton.buttonContainer updatePosition];
    }
    self.darkButton.buttonContainer.alpha = 1;
  }
}
%end

%hook CCUILabeledRoundButton
%property (nonatomic, assign) bool centered;
- (void)setCenter:(CGPoint)center {
  if (self.centered) {
    return;
  } else {
    self.centered = YES;
    %orig;
  }
}
%new
- (void)updatePosition {
  self.centered = NO;
  CGPoint center;
  if ([self.title isEqual: [localizeBundle localizedStringForKey:@"DARK MODE" value:@"Dark mode" table:nil]]) {
    if (ccBounds.size.width < ccBounds.size.height && !trueTone) {
      center.x = ccBounds.size.width/2-ccBounds.size.width*0.192;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (!trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2-ccBounds.size.width*0.1;
    } else if (ccBounds.size.width < ccBounds.size.height && trueTone) {
      center.x = ccBounds.size.width/2-ccBounds.size.width*0.29;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2-ccBounds.size.height*0.3;
    }
  } else if (self.glyphImage == nightImage) {
    if (ccBounds.size.width < ccBounds.size.height && !trueTone) {
      center.x = ccBounds.size.width/2+ ccBounds.size.width*0.192;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (!trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2+ ccBounds.size.width*0.1;
    } else if (ccBounds.size.width < ccBounds.size.height && trueTone) {
      center.x = ccBounds.size.width/2;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2;
    }
  } else if (trueTone && self.glyphImage == toneImage) {
    if (ccBounds.size.width < ccBounds.size.height) {
      center.x = ccBounds.size.width/2+ccBounds.size.width*0.29;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2+ ccBounds.size.height*0.3;
    }
  }
  [self setCenter:center];
}
%end
%end

//Initialize
%ctor {

  refreshPrefs();

  darkTheme = [[%c(CKUIThemeDark) alloc] init];

  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.twickd.turnt-ducky.darkmode.plist"];
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.ducksrepo.darkmode.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, enableDarkmode, CFSTR("xyz.ducksrepo.darkmode.enabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, disbaleDarkmode, CFSTR("xyz.ducksrepo.darkmode.disabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

  %init;
  %init(Toggle);

  if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
    %init(SpringBoard);
  }

  if ([(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"]) {
    if ([[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"]) {
      if (([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]] && widgets) || ([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.usernotifications.content-extension"]] && notification3d)) {
        %init(Extension);
      }
      if ([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]] && widgets) {
        %init(Invert);
      }
    }
  }
}
