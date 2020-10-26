//
//  TimerView.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 08/10/20.
//

import UIKit

class TimerView: UIView {
    
    lazy var progressView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        return view
    }()
    
    var progressViewWidth: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        progressViewWidth = progressView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
        progressViewWidth?.isActive = true
    }
    
    public func updateWidth(with progress: Double) {
        UIView.animate(withDuration: 0.1) {
            self.progressViewWidth?.constant = CGFloat(progress)
        }
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
