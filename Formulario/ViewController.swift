//
//  ViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form.sections = [
            FormSection(rows: [
                FormRow(title: "Vorname", value: "Andreas"),
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                TextFieldFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                })
            ])
        ]
        
        form.sections.append(
            FormSection(title: "Kommunikation", rows: [
                FormRow(title: "Telefon", value: "+43 1 53422"),
                TextFieldFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: nil),
                ])
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

