// Darkmode Headers
// This file is kind of a mess, but hey. It works.
#define UIColorMake(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

extern "C" {
  CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);
}

@interface MTPlatterHeaderContentView : UIView
- (UILabel *)_titleLabel;
- (UILabel *)_dateLabel;
@end

@interface NCNotificationContentView : UIView
- (UILabel *)_secondaryTextView;
- (UILabel *)_primaryLabel;
- (UILabel *)_primarySubtitleLabel;
- (UILabel *)_secondaryLabel;
- (UILabel *)_summaryLabel;
@end

@interface NCNotificationShortLookView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(NSNotification *)notification;
-(MTPlatterHeaderContentView *)_headerContentView;
@end

@interface NCNotificationLongLookView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(NSNotification *)notification;
@property (nonatomic, readonly) UIView *customContentView;
@end

@interface BSUIEmojiLabelView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
@property (nonatomic, retain) UIColor *textColor;
- (void)darkmodeToggled:(NSNotification *)notification;
@end

@interface NCNotificationViewControllerView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(NSNotification *)notification;
@end

@interface NCNotificationListCellActionButton : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
@end

@interface NCToggleControl : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
@end

@interface WGWidgetPlatterView : UIView
@property (nonatomic, readonly) UIButton *showMoreButton;
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
- (MTPlatterHeaderContentView *)_headerContentView;
@end

@interface WGShortLookStyleButton : UIButton
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SPUIHeaderBlurView : UIVisualEffectView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIVisualEffect *lightBlur;
@property (nonatomic, retain) UIVisualEffect *darkBlur;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBWallpaperEffectView : UIView
@property (nonatomic, assign) long long wallpaperStyle;
- (void)darkmodeToggled:(id)arg1;
- (id)initWithWallpaperVariant:(long long)variant;
- (void)setStyle:(long long)style;
@end

@interface SBFolderBackgroundView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) NSArray *lightSubviews;
@property (nonatomic, retain) UIVisualEffectView *darkOverlayView;
@property (nonatomic, retain) UIVisualEffectView *darkBlurView;
@property (nonatomic, retain) UIVisualEffectView *lightBlurView;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBFolderIconImageView : UIImageView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) SBWallpaperEffectView *darkBackgroundView;
@property (nonatomic, retain) UIView *darkOverlayView;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBFolderIconBackgroundView : UIView
@end

@interface SBFolderIconView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
- (UIView *)iconBackgroundView;
@end

@interface SBDockView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIView *darkOverlayView;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBFloatingDockPlatterView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, assign) long long lightStyle;
- (void)darkmodeToggled:(id)arg1;
@end

@interface UIKBRenderConfig : UIView
@end

@interface CAFilter : NSObject
+ (CAFilter*)filterWithType:(NSString*)type;
+ (CAFilter*)filterWithName:(NSString*)name;
- (id)initWithType:(NSString*)type;
- (id)initWithName:(NSString*)name;
- (void)setDefaults;
@end

@interface MTMaterialView : UIView
@end

@interface UIInterfaceAction : NSObject
@property (nonatomic, assign) bool enabled;
@property (nonatomic, assign) UIColor *titleTextColor;
@end

@interface PLInterfaceActionGroupView : UIView
@property (nonatomic, readonly) NSArray *actions;
@end

@interface MTVibrantStylingProvider : NSObject
@end

@interface _UIBackdropView : UIView
@property (assign,nonatomic) long long style;
- (void)transitionToStyle:(NSInteger)style;
@end

@interface SBUIIconForceTouchWrapperViewController : UIViewController
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBUIActionView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)darkmodeToggled:(id)arg1;
@end

@interface SBUIActionViewLabel : UILabel
@end

@interface _UINavigationBarLargeTitleView : UIView
@property (nonatomic,copy) NSDictionary * titleAttributes;
@end

@interface CALayer (Darkmode)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) NSArray *darkFilters;
@property (nonatomic, retain) NSArray *lightFilters;
@property (nonatomic, retain) CAFilter *darkFilter;
@property (nonatomic, retain) CAFilter *lightFilter;
- (void)darkmodeToggled:(id)arg1;
- (void)enableDarkmode:(bool)arg1;
@end

@interface UILabel (Darkmode)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
- (void)darkmodeToggled:(id)arg1;
- (void)enableDarkmode:(bool)arg1;
@end

@interface UIButton (Darkmode)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTintColor;
@property (nonatomic, retain) UIColor *lightTintColor;
- (void)darkmodeToggled:(id)arg1;
- (void)enableDarkmode:(bool)arg1;
@end

@interface UITextView (Darkmode)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
- (void)darkmodeToggled:(id)arg1;
- (void)enableDarkmode:(bool)arg1;
@end

@interface UIView (Darkmode)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkBackgroundColor;
@property (nonatomic, retain) UIColor *lightBackgroundColor;
@property (nonatomic, retain) NSNumber *darkAlpha;
@property (nonatomic, retain) NSNumber *lightAlpha;
- (void)layoutDarkmode;
- (void)darkmodeToggled:(id)arg1;
- (void)enableDarkmode:(bool)arg1;
+ (void)crash;
- (void)crash;
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic, retain) MTMaterialView *normalStateBackgroundView;
- (void)_unhighlight;
- (void)setHighlighted:(bool)arg1;
@end

@interface CCUILabeledRoundButton : UIView
@property (nonatomic, assign) bool centered;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) bool labelsVisible;
@property (nonatomic, retain) UIImage *glyphImage;
@property (nonatomic, retain) CCUIRoundButton *buttonView;
- (id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3;
- (void)updatePosition;
@end

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, assign) bool labelsVisible;
@property (nonatomic, retain) CCUILabeledRoundButton *buttonContainer;
@property (nonatomic, retain) CCUIRoundButton *button;
-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 ;
@end

@interface CCUIDisplayBackgroundViewController : UIViewController
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *nightShiftButton;
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *trueToneButton;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,copy) NSString *moduleIdentifier;
@property (nonatomic,retain) CCUIDisplayBackgroundViewController *backgroundViewController;
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *darkButton;
@end

@interface CAPackage : NSObject
@property (readonly) CALayer *rootLayer;
@property (readonly) BOOL geometryFlipped;
+ (id)packageWithContentsOfURL:(id)arg1 type:(id)arg2 options:(id)arg3 error:(id)arg4;
- (id)_initWithContentsOfURL:(id)arg1 type:(id)arg2 options:(id)arg3 error:(id)arg4;
@end

extern NSString const *kCAPackageTypeCAMLBundle;

@interface CCUICAPackageView : UIView
@property (nonatomic, retain) CAPackage *package;
- (void)setStateName:(id)arg1;
@end

@interface CCUIDarkmodeButton : CCUIRoundButton
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) CCUICAPackageView *packageView;
- (id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3;
- (void)updateStateAnimated:(bool)arg1;
@end

@interface CKUITheme : NSObject
@end

@interface CKUIThemeDark : CKUITheme
- (UIColor *)entryFieldDarkStyleButtonColor;
@end

@interface SSBlurringFlashView : UIView
@end

@interface _UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

@interface UIStatusBarBackgroundView : UIView
@end

@interface UINavigationBar (Settings)
-(void)setLargeTitleTextAttributes:(NSDictionary *)arg1;
@end

@interface UISearchBarTextField : UITextField
@end

@interface UIImage (ResizeImage)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
@end

@implementation UIImage (ResizeImage)

- (UIImage *)imageScaledToSize:(CGSize)newSize {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
}

@end

@interface _UITableViewHeaderFooterViewBackground : UIView
@end

@interface _UIContentUnavailableView : UIView
@end

@interface PRXBubbleBackgroundView : UIView
@end

@interface WFAssociationStateView : UIView
@end

@interface UILayoutContainerView : UIView
@end

@interface WFTextFieldCell : UIView
@property (nonatomic, strong) UITextField *textField;
@end

@interface PSEditableTableCell : UIView
@end

@interface RemoteUITableViewCell : UIView
@end

@interface PUAlbumListCellContentView : UIView
@end

@interface PUCollectionView : UIView
@end

@interface DevicePINPane : UIView
@end

@interface PSBulletedPINView : UIView
@end

@interface PSPasscodeField : UIView
@property (nonatomic, strong) UIColor *foregroundColor;
@end

@interface SBIconBlurryBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView (SBIconBlurryBackgroundView)
@end

@interface SBFolderBackgroundView (UIView)
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
- (void)viewDidDisappear:(BOOL)arg1;
- (void)viewDidAppear:(BOOL)arg1;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic, readonly, copy) NSString *sectionIdentifier;
@property (nonatomic, readonly, copy) NSString *categoryIdentifier;
@end

@interface NCNotificationViewController : UIViewController
- (id)initWithNotificationRequest:(NCNotificationRequest *)arg1;
- (BOOL)dismissPresentedViewControllerAndClearNotification:(BOOL)arg1 animated:(BOOL)arg2;
- (void)dismissViewControllerWithTransition:(int)arg1 completion:(id /* block */)arg2;
@end

@interface CNContactListTableView : UIView
@end

@interface PHHandsetDialerView : UIView
@end

@interface UITableViewCellContentView : UIView
@end

@interface _UITableViewHeaderFooterViewLabel : UILabel
@end

@interface MPVoicemailMessageTableViewCell : UIView
@end

@interface MPRecentsTableViewCell : UIView
@end

@interface CNPropertyNoteCell : UIView
@end

@interface TPTableViewCell : UITableViewCell
{
    UIView* _foregroundView;
}
@property (nonatomic,readonly) UIView * foregroundView;
@end

@interface VMAccountsView : UIView
@end

@implementation TPTableViewCell
@synthesize foregroundView=_foregroundView;
@end

@interface MPVoicemailMailboxTableViewCell : TPTableViewCell
@end

@interface MPVoicemailMessageTableViewCellScrollView : UIView
@end

@interface CNContactListHeaderFooterView : UITableViewCell
@end

@interface PHBottomBarButton : UIButton
@end

@interface CNPropertyPhoneNumberCell : UIView
@end

@interface CNPropertyEmailAddressCell : UIView
@end

@interface CNContactActionCell : UIView
@end

@interface PHLCDViewTextField : UIView
@property (nonatomic, retain) UIColor *textColor;
@end

@interface UITableViewCellEditControl : UIView
@end

@interface _UIStatusBarForegroundView : UIView
@end

@interface _UITableViewHeaderFooterContentView : UIView
@end

@interface TPDialerNumberPad : UIView
@property (nonatomic, retain) UIColor *textColor;
@end

@interface CompactMonthWeekView : UIView
@property (nonatomic, retain) UIColor *textColor;
@end

@interface CompactYearViewYearHeader : UIView
@property (nonatomic, retain) UIColor *textColor;
@end

@interface CompactYearMonthView : UIView
@property (nonatomic, retain) UIColor *textColor;
@end

@interface TodayCardThreeLineOverlayView : UIView
@end

@interface PHHandsetDialerDeleteButton : UIView
@end

@interface MonthTitleView : UIView
@end

@interface CompactMonthWeekTodayCircle : UIView
@end

@interface UIAlertControllerVisualStyleActionSheet : UIView
@property (nonatomic, assign) bool isObserving;
@end

@interface UIInterfaceActionVisualStyleViewState : UIView
@property (nonatomic, assign) bool isObserving;
@end

@interface UIInterfaceActionVisualStyle : UIView
@property (nonatomic, assign) bool isObserving;
@end

@interface UIAlertControllerVisualStyleAlert : UIView
@property (nonatomic, assign) bool isObserving;
@end

@interface _UIAlertControlleriOSActionSheetCancelBackgroundView : UIView
@property (nonatomic, assign) bool isObserving;
@end

@interface MFTableViewCell : UITableViewCell
@end

@interface MailboxTableCell: MFTableViewCell
	@property(retain, nonatomic) UIColor *titleColor;
@end

@interface MailboxPickerController : UITableViewController
@end

@interface MailNavigationController : UINavigationController
@end

@interface MailStatusLabelView: UIView
	@property(nonatomic) NSAttributedString *primaryLabelText;
@end

@interface MailDetailNavigationController : UINavigationController
@end

@interface ComposeNavigationController : UINavigationController
@end

@interface MFActorItemHeaderView : UIView
	@property(retain, nonatomic) UIView *backgroundView;
	@property(retain, nonatomic) UILabel *titleLabel;
@end

@interface MFCollapsibleHeaderView
	@property(retain, nonatomic) UILabel *superTitleLabel;
@end

@interface MFCollapsibleHeaderContentView
	@property(retain, nonatomic) UITextView *textView;
@end

@interface MFMailboxFilterPickerControl
	@property(retain, nonatomic) UILabel *filtersLabel;
	@property(retain, nonatomic) UILabel *titleLabel;
@end

@interface MFAtomSearchBar : UISearchBar
@end

@interface MFSwipableTableViewCell: UITableViewCell
@end

@interface MailboxContentViewCell: MFSwipableTableViewCell
@end

@interface MFSimpleLabel: UILabel
@end

@interface MFSwipableTableView: UITableView
@end

@interface MFConversationItemHeaderBlock: UIView
@end

@interface MFExpandableCaptionView: UIView
@end

@interface MFModernAtomView
	@property UILabel *titleLabel;
@end

@interface MFCaptionLabel
	@property UIColor *textColor;
@end

@interface MFModernLabelledAtomList
	@property UIColor *labelTextColor;
@end

@interface MFMessageHeaderMessageInfoBlock: UIView
	@property UITextView *subjectTextView;
	@property UILabel *timestampLabel;
@end

@interface WKWebView: UIView
@end

@interface MFComposeTextContentView: UIView
@end

@interface MFConversationViewController: UIViewController
@end

@interface MFSearchSuggestionsViewController: UIViewController
@end

@interface MFSearchSuggestionsTableViewCell: UITableViewCell
@end

@interface SearchScopeControl: UIView
@end

@interface MFMailComposeToField: UIView
@end

@interface MFHeaderLabelView: UILabel
@end

@interface MFComposeRecipientTextView: UIView
	@property UIColor *typingTextColor;
@end

@interface MFComposeSubjectView: UIView
	@property UITextView *textView;
@end

@interface MFComposeMultiView: UIView
@end

@interface MFComposeFromView: UIView
@end

@interface MFRecipientTableViewCell: UIView
	@property UILabel *titleLabel;
	@property UILabel *detailLabel;
@end

@interface MessageSuggestionBannerView: UIView
@end

@interface MessageSuggestionTitleControl: UIView
	@property UILabel *titleLabel;
@end

@interface MFVibrantCardView: UIView
@end

@interface UIDateLabel: UILabel
@end

@interface MFCollapsedMessageCell: UIView
	@property MFVibrantCardView *cellBackgroundView;
	@property UILabel *senderLabel;
	@property UILabel *summaryLabel;
	@property UIDateLabel *timestampLabel;
@end

@interface _UIActivityGroupActivityCellTitleLabel : UIView
@end
