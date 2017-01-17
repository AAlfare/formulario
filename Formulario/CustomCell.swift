//
//  CustomCell.swift
//  Formulario
//
//  Created by Andreas Alfarè on 29.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario

class CustomCell: FormCell {
    var segmentedControl = UISegmentedControl(items: ["Weiblich", "Männlich"])
    
    override func setupUI() {
        super.setupUI()
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        fieldContainer.addSubview(segmentedControl)
        
        let views = [
            "segmentedControl": segmentedControl
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[segmentedControl]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[segmentedControl]-|", options: [], metrics: nil, views: views))
    }
    
    override func configure(_ row: FormRow) {
        super.configure(row)
        
    }
    
    func valueChanged(_ segmentedControl: UISegmentedControl) {
        row?.value = segmentedControl.selectedSegmentIndex
    }
}
