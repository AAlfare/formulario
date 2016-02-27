//
//  ViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.form.sections = [
            FormSection(rows: [
                FormRow(title: "Vorname", value: "Andreas"),
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                FormRow(title: "Nachname", value: "Alfarè", cellClass: TextFieldFormCell.self, valueChanged: { (row) -> Void in
                    print("row value: \(row.value)")
                })
            ])
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

