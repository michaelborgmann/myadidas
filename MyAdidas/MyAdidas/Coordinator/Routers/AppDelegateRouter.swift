//
//  AppDelegateRouter.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import UIKit

public class AppDelegateRouter: Router {
    
    public let window: UIWindow
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, onDismissed: (()->Void)?) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    public func dismiss(animated: Bool) {
        // isn't meant to be dismissible
    }
    
}
