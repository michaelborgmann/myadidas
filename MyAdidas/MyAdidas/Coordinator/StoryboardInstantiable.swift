//
//  StoryboardInstantiable.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import UIKit

public protocol ViewModelBindalbe {
    init?<T>(coder: NSCoder, viewModel: T)
}

public protocol StoryboardInstantiable: class {
    associatedtype MyType: ViewModelBindalbe

    static var storyboardFileName: String { get }
    static var storyboardIdentifier: String { get }
    static func instanceFromStoryboard(_ bundle: Bundle?) -> MyType
    static func instanceFromStoryboard<T>(_ bundle: Bundle?, with viewModel: T) -> MyType
}

extension StoryboardInstantiable where Self: UIViewController {

    static var storyboardFileName: String {
        return storyboardIdentifier.components(separatedBy: "ViewController").first!
    }

    static var storyboardIdentifier: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instanceFromStoryboard(_ bundle: Bundle? = nil) -> Self {
        let fileName = storyboardFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
    
    static func instanceFromStoryboard<T>(_ bundle: Bundle? = nil, with viewModel: T) -> Self {
        let fileName = storyboardFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        
        let viewController = storyboard.instantiateViewController(identifier: storyboardIdentifier, creator: { coder in
            MyType(coder: coder, viewModel: viewModel) as? UIViewController
        })
        
        return viewController as! Self
    }
        
}
