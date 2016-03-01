//
//  CustomViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 29.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario

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
        form.sections.append(FormSection(title: "Servus", rows: [
            FormRow(title: "Hallo", value: "Otto"),
            FormRow(title: nil, value: 0.3, cellClass: CustomCell.self, cellSelection: nil, valueChanged: { (row) -> Void in
                print("Slider changed: \(row.value)")
            }),
            FormRow(title: "Geschwindigkeit", value: 0.6, cellClass: SliderFormCell.self, cellSelection: nil, valueChanged: nil)
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
