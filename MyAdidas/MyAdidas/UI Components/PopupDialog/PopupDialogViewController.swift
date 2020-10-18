//
//  PopupDialogViewController.swift
//  Fluent
//
//  Created by Michael Borgmann on 18.10.20.
//  Copyright © 2020 Michael Borgmann. All rights reserved.
//

import UIKit

class PopupDialogViewController: UIViewController {

    @IBOutlet weak var popupDialogView: PopupDialogView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPopupDialog()
        setupPopupBackgroundColor(UIColor.clear.withAlphaComponent(0.5))
    }
    
    private func setupPopupDialog() {
        popupDialogView.cornerRadius = 16
        popupDialogView.title = "Anmerkungen"
        //popupDialogView.message = "Lorem ipsum solor it"
        popupDialogView.callback = {
            self.dismiss(animated: true, completion: nil)}
        
    }
    
    private func setupPopupBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }

}

extension PopupDialogViewController {
    
    static func showPopup(parentViewController parent: UIViewController) -> PopupDialogViewController? {
        
        let storyboard = UIStoryboard(name: "PopupDialog", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "PopupDialog") as? PopupDialogViewController else {
            return nil
        }
            
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
            
        parent.present(viewController, animated: true, completion: nil)
        
        return viewController
    }
    
}
