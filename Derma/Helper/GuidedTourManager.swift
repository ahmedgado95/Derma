//
//  GuidedTourManager.swift
//  Derma
//
//  Created by ahmed gado on 10/03/2025.
//

import UIKit

class GuidedTourManager {
    
    var steps: [UIView] = []
    var messages: [String] = []
    var currentStep = 0
    
    lazy var overlay: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextStep)))
        return view
    }()
    
    lazy var tooltip: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(finishTour), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func startTour(steps: [UIView], messages: [String]) {
        self.steps = steps
        self.messages = messages
        
        UIApplication.shared.windows.first?.addSubview(overlay)
        overlay.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            skipButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -20)
        ])
        
        showStep()
    }
    
    @objc func nextStep() {
        currentStep += 1
        
        if currentStep >= steps.count {
            finishTour()
            return
        }
        
        showStep()
    }
    
    @objc func finishTour() {
        currentStep = 0
        overlay.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "TourCompleted") // Save Tour Status
    }
    
    func showStep() {
        let target = steps[currentStep]
        let rect = target.convert(target.bounds, to: overlay)
        
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlay.bounds)
        let holePath = UIBezierPath(roundedRect: rect.insetBy(dx: -10, dy: -10), cornerRadius: 10)
        path.append(holePath)
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        overlay.layer.mask = maskLayer
        
        tooltip.text = messages[currentStep]
        switch currentStep{
        case 1 :
            tooltip.frame = CGRect(x: rect.midX - -10, y: rect.maxY + 20, width: 250, height: 60)
        case 2 :
            tooltip.frame = CGRect(x: rect.midX + -250, y: rect.maxY + 20, width: 250, height: 60)
        default :
            tooltip.frame = CGRect(x: rect.midX - 150, y: rect.maxY + 20, width: 250, height: 60)
        }
        overlay.addSubview(tooltip)
    }
}
