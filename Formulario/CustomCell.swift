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
    var slider = UISlider()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: "sliderChanged:", forControlEvents: .ValueChanged)
        contentView.addSubview(slider)
        
        let views = [
            "textLabel": textLabel!,
            "slider": slider
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[slider]-16-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[slider]|", options: [], metrics: nil, views: views))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configure(row: FormRow) {
        super.configure(row)
        if let value = row.value as? Float {
            slider.value = value
        }
    }
    func sliderChanged(slider: UISlider) {
        row?.value = slider.value
    }
}
