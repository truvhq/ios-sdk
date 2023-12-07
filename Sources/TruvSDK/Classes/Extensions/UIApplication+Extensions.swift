import UIKit

extension UIApplication {

    class func topViewController(viewController: UIViewController? = UIApplication.getKeyWindow()?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }

    class func getKeyWindow() -> UIWindow? {
        shared.windows.first(where: { $0.isKeyWindow })
    }
}
