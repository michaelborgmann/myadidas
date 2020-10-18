//
//  PopupDialogView.swift
//  Fluent
//
//  Created by Michael Borgmann on 18/10/2020.
//  Copyright © 2020 Michael Borgmann. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class PopupDialogView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = cornerRadius.isZero ? false : true
        }
    }
    
    @IBInspectable var buttonTitle: String {
        get { okButton.titleLabel?.text ?? "" }
        set { okButton.setTitle(newValue, for: .normal) }
    }
    
    @IBInspectable var title: String {
        get { titleLabel.text ?? ""}
        set { titleLabel.text = newValue }
    }
    
    @IBInspectable var message: NSAttributedString {
        get { messageTextView.attributedText }
        set { messageTextView.attributedText = newValue }
    }
    
    var callback: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TITLE"
        
        return label
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.text = "Message"
        
        return textView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        
        return separator
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 20.5))
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        return button
    }()
    
    @objc func dismissView() {
        subviews.forEach { $0.removeFromSuperview() }
        callback?()
    }
    
    private lazy var blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        addSubview(blurEffect)
        addSubview(titleLabel)
        addSubview(messageTextView)
        addSubview(separator)
        addSubview(okButton)
        
        constrainView()
    }
    
    private func constrainView() {
        
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurEffect.topAnchor.constraint(equalTo: topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            
            messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageTextView.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -8),
            
            okButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -8),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        backgroundColor = .green
    }
    
}
