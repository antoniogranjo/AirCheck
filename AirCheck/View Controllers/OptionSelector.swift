//
//  OptionSelector.swift
//  AirCheck
//
//  Created by Jorge Raul Ovalle Zuleta on 4/23/16.
//  Copyright © 2016 aircheck. All rights reserved.
//

import UIKit
import pop

protocol OptionSelectorDelegate{
    func openSelector()
    func closeSelector()
    func extendSelector()
}

class OptionSelector: UIView {
    var isOpen = false
    var openButton:OpenOptionButton!
    var contentView:UIView!
    var delegate:OptionSelectorDelegate?
    
    var active = ReportType.symptoms
    
    var menu:ContentMenu!
    var switchBtn:UIButton!
    var cancelBtn:UIButton!
    
    
    init() {
        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addUIComponents()
        self.addUIConstraints()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionTapped:", name: "optionTapped", object: nil)
    }
    
    func addUIComponents(){
        openButton                                           = OpenOptionButton()
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.setImage(UIImage(named: "arrow_up"), forState: .Normal)
        openButton.addTarget(self, action: Selector("openOptions"), forControlEvents: .TouchUpInside)
        self.addSubview(openButton)
        
        contentView                                           = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor                           = UIColor(patternImage: UIImage(named: "Mask")!)
        self.addSubview(contentView)
        
        menu = ContentMenu()
        menu.setOptions((OptionTree.sharedInstance.tree?.children)!)
        contentView.addSubview(menu)
        
        switchBtn       = UIButton()
        switchBtn.alpha = 0
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.backgroundColor = UIColor(red:0.24, green:0.60, blue:0.56, alpha:1.00)
        switchBtn.setTitle("SÍNTOMAS", forState: .Normal)
        switchBtn.layer.cornerRadius = 10
        switchBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        switchBtn.addTarget(self, action: Selector("swap"), forControlEvents: .TouchUpInside)
        contentView.addSubview(switchBtn)
        
        
        cancelBtn       = UIButton()
        cancelBtn.alpha = 0
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.backgroundColor = UIColor(red:0.62, green:0.22, blue:0.22, alpha:1.00)
        cancelBtn.setTitle("CANCELAR", forState: .Normal)
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        cancelBtn.addTarget(self, action: Selector("cancel"), forControlEvents: .TouchUpInside)
        contentView.addSubview(cancelBtn)
        
    }
    
    func addUIConstraints(){
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        let views =  ["openButton":openButton,"contentView":contentView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[openButton(40)][contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[openButton]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[menu]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu" : menu]))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[switchBtn]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["switchBtn" : switchBtn]))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[cancelBtn]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["cancelBtn" : cancelBtn]))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[menu(90)]-25-[switchBtn(45)]-[cancelBtn(45)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu" : menu,"switchBtn":switchBtn, "cancelBtn":cancelBtn]))
    }
    
    func swap(){
        switch active{
            case .symptoms:
                menu.setOptions((OptionTree.sharedInstance.tree?.search("SYM")?.children)!)
                switchBtn.setTitle("SÍNTOMAS", forState: .Normal)
                active = .pollution
            case .pollution:
                active = .symptoms
                switchBtn.setTitle("POLUCIÓN", forState: .Normal)
                menu.setOptions((OptionTree.sharedInstance.tree?.search("POL")?.children)!)
        }
    }
    
    func cancel(){
        delegate?.closeSelector()
        openButton.setImage(UIImage(named: "arrow_up"), forState: .Normal)
        menu.setOptions((OptionTree.sharedInstance.tree?.children)!)
        switchBtn.alpha = 0
        cancelBtn.alpha = 0
    }
    
    func openOptions(){
        if isOpen{
            cancel()
        }else{
            delegate?.openSelector()
            openButton.setImage(UIImage(named: "arrow_down"), forState: .Normal)
        }
        isOpen = !isOpen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func optionTapped(notification:NSNotification){
        let option = (notification.object as! Option)
        let opt = OptionTree.sharedInstance.tree?.search(option.name)
        if option.name == "REPORTAR"{
            menu.setOptions((opt?.children[0].children)!)
            let animation:POPSpringAnimation =  POPSpringAnimation(propertyNamed: kPOPViewAlpha)
            animation.springSpeed      = 20.0
            animation.springBounciness = 15.0
            animation.toValue          = 1
            switchBtn.pop_addAnimation(animation, forKey: "switchAlpha")
            cancelBtn.pop_addAnimation(animation, forKey: "switchAlpha")
            delegate?.extendSelector()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "optionTapped", object: nil)
    }    
}
