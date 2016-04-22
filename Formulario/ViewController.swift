//
//  ViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario

enum Animal: SelectableOption {
    case Dog
    case Cow
    case Sheep
    
    static func all() -> [Animal] {
        return [.Cow, .Dog, .Sheep]
    }
    
    func selectableOptionTitle() -> String {
        switch self {
        case .Cow: return "Cow"
        case .Dog: return "Dog"
        case .Sheep: return "Sheep"
        }
    }
}

class Person: NSObject, SelectableOption {
    var title: String
    init(title: String) {
        self.title = title
        super.init()
    }
    func selectableOptionTitle() -> String {
        return title
    }
    class func all() -> [Person] {
        return [
            Person(title: "👮"),
            Person(title: "🎅"),
            Person(title: "👷")
        ]
    }
}

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form.sections = [
            FormSection(rows: [
                FormRow(title: "Vorname", value: "Andreas"),
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                TextFieldFormRow(title: "Text", value: nil, placeholder: "Text", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
                SwitchFormRow(title: "Lights on", value: true, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectionFormRow(title: "Emoji", options: ["🐣", "👸", "🐮"], cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectableFormRow(title: "Happy?", selected: true, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectionFormRow(title: "Animals", options: Animal.all(), cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectionFormRow(title: "🙃", options: Person.all(), cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        ]
        
        form.sections.append(
            FormSection(title: "Various text field rows", rows: [
                EmailFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
                PasswordFormRow(title: "Password", value: nil, placeholder: "Password", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
                PhoneFormRow(title: "Phone", value: nil, placeholder: "Phone", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
                DecimalFormRow(title: "Decimal", value: nil, placeholder: "Decimal", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
                CurrencyFormRow(title: "Price", value: nil, placeholder: "Price", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                })
            ])
        )
            
        form.sections.append(
            FormSection(title: "Static", rows: [
                FormRow(title: "Telefon", value: "+43 1 53422"),
                FormRow(title: "Email", value: "hello@example.com"),
            ])
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

