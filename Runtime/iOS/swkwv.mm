#ifndef __has_feature
#define __has_feature(x) 0 /* for non-clang compilers */
#endif

#if !__has_feature(objc_arc)
#error ARC must be enabled by adding -fobjc-arc under your target => Build Phases => Compile Sources => UnityDeeplinks.mm => Compiler Flags
#endif

// UIKit et WebKit AVANT le header Swift genere : en Objective-C++ sans modules, ses @import sont ignores
// et il ne declare pas lui-meme les types UIKit / WebKit qu'il utilise
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "swkwv.h"
// les sources Swift sont compilees dans la cible UnityFramework : Xcode genere ce header
#import <UnityFramework/UnityFramework-Swift.h>
#import <UnityAppController.h>
#import "UnityInterface.h"

@interface swkwv : NSObject <SmartWKWebViewControllerDelegateDissmissed>
- (void)openURL:(NSString*)url openBlankInsideWebview:(Boolean)openBlankInsideWebview showNavigationButtons:(Boolean)showNavigationButtons;
@end

@implementation swkwv
- (void)ondismiss
{
    UnitySendMessage("_Extern_WebViewLight", "OnPopupClosed", "");
}
- (void)ondataWithStr:(NSString *)str
{
    const char* url = (const char*) [str UTF8String];
    UnitySendMessage("_Extern_WebViewLight", "OnPopupData", url);
}
- (void)openURL:(NSString*)url 
openBlankInsideWebview:(Boolean)openBlankInsideWebview
showNavigationButtons:(Boolean)showNavigationButtons
{
    SmartWK *myClass = [[SmartWK alloc] init];
    [myClass openWkWvWithUnityviewcontroller:UnityGetGLViewController() 
                                         url:url dismisseddelegate:self
                      openBlankInsideWebview:openBlankInsideWebview
                       showNavigationButtons:showNavigationButtons];
}
@end



extern "C"
{
    bool isInit = FALSE;

    void init()
    {
        isInit = TRUE;
        [SmartWK setDatasSchemesFromBundleWithBundle:NSBundle.mainBundle];
    }

    void WK_openFrame(const char *curl, bool openBlankInsideWebview, bool showNavigationButtons)
    {
        if( isInit != TRUE )
            init();
        
        swkwv *myClass = [[swkwv alloc] init];
        NSString* url = [NSString stringWithCString:curl encoding:NSUTF8StringEncoding];
        [myClass openURL:url 
  openBlankInsideWebview:openBlankInsideWebview
   showNavigationButtons:showNavigationButtons];
    }

    void WK_closeFrame()
    {
        [SmartWK closeWkWv];
    }
    
    void WK_setInspectable(bool inspectable)
    {
        [SmartWK setInspectableWithInspectable:inspectable];
    }
    
    BOOL WK_CanOpenURL(const char* url)
    {
        NSString* urlStr = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
        return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]];
    }
}
