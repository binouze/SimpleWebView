import Foundation
import UIKit

@objc public class SmartWK : NSObject {

    @objc public static var curWV : SmartWKWebViewController?;
    
    @objc public func openWkWv( unityviewcontroller:UIViewController, url:String, dismisseddelegate:SmartWKWebViewControllerDelegateDissmissed, openBlankInsideWebview:Bool = true, showNavigationButtons:Bool = true )
    {
        // fermer les WV precedentes au cas ou
        //SmartWK.closeWkWv()
        
        // ouvrir la nouvelle WV
        let vc = SmartWKWebViewController()
        
        vc.openBlankInWebView    = openBlankInsideWebview
        vc.showNavigationButtons = showNavigationButtons
        vc.url                   = URL(string: url)
        vc.ondismiss             = dismisseddelegate;
        
        unityviewcontroller.present(vc, animated: true)
        
        SmartWK.curWV = vc;
    }
    
    @objc public static func setDatasSchemesFromBundle(bundle:Bundle)
    {
        print("setDatasSchemesFromBundle")
        
        let schemes = self.getExternalURLSchemes(bundle: bundle)
        
        for scheme in schemes {
            print("scheme added: \(scheme)")
        }
        
        SmartWKWebViewController.dataschemes = schemes
    }
    
    @objc public static func closeWkWv()
    {
        curWV?.forceDismiss();
    }
    
    static func getExternalURLSchemes(bundle:Bundle) -> [String] {
        guard let urlTypes = bundle.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return []
        }

        var result: [String] = []
        for urlTypeDictionary in urlTypes {
            guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
            
            for scheme in urlSchemes {
                result.append(scheme)
            }
            //guard let externalURLScheme = urlSchemes.first else { continue }
            //result.append(externalURLScheme)
        }

        return result
    }
}

extension Bundle {

    static let getExternalURLSchemes: [String] = {
        guard let urlTypes = main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return []
        }

        var result: [String] = []
        for urlTypeDictionary in urlTypes {
            guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
            guard let externalURLScheme = urlSchemes.first else { continue }
            result.append(externalURLScheme)
        }

        return result
    }()
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}

extension UIView {
    var safeAreaBottom: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }

    var safeAreaTop: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
        }
        return 0
    }
}
