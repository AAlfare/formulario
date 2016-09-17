//
//  CustomViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 29.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario

class CustomizedTextFieldCell: TextFieldFormCell {
    override func configure(row: FormRow) {
        super.configure(row)
        
        titleLabel.text = row.form?.layoutAxis == .Vertical ? row.title?.uppercaseString : row.title
        
        // Add custom margins and colors to views
        contentView.layoutMargins.bottom = 15
        contentView.backgroundColor = UIColor.darkGrayColor()
        titleContainer.layoutMargins.left = row.form?.layoutAxis == .Vertical ? 9 : 0
        container.backgroundColor = UIColor.whiteColor()
        container.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        container.preservesSuperviewLayoutMargins = false
        container.layer.cornerRadius = 2.5
        container.layer.masksToBounds = true
        fieldContainer.backgroundColor = UIColor.groupTableViewBackgroundColor()
        fieldContainer.layer.cornerRadius = 2.5
        fieldContainer.layer.masksToBounds = true
        fieldContainer.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textField.textAlignment = .Left
    }
}

class CustomViewController: UIViewController {
    var tableView = UITableView()
    var form = Form()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let views = [
            "tableView": tableView
        ]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: [], metrics: nil, views: views))
        
        form.tableView = tableView
        form.layoutAxis = .Vertical
        form.sections.append(FormSection(title: "Servus", rows: [
            FormRow(title: "Hallo", value: "Otto"),
            FormRow(title: "Vorname", value: nil, cellClass: CustomizedTextFieldCell.self, cellSelection: nil, valueChanged: nil),
            FormRow(title: "Nachname", value: "", cellClass: CustomizedTextFieldCell.self, cellSelection: nil, valueChanged: nil),
            FormRow(title: "Geschlecht", value: 0.3, cellClass: CustomCell.self, cellSelection: nil, valueChanged: { (row) -> Void in
                print("Slider changed: \(row.value)")
            }),
            
        ]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
