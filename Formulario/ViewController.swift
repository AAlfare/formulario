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
        
        title = "Formulario"
        
        form.sections = [
            FormSection(rows: [
                FormRow(title: "Vorname", value: "Andreas"),
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                TextFieldFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                })
            ]),
            FormSection(title: "Kommunikation", rows: [
                FormRow(title: "Email", value: "andreas@alfare.it"),
                TextFieldFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: nil),
            ])
        ]
        
        form.sections.append(FormSection(title: "Blubb", rows: [
            FormRow(title: "Test", value: "Möpp!")
        ]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

