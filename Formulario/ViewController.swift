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
    var group: String
    init(title: String, group: String) {
        self.title = title
        self.group = group
        super.init()
    }
    
    class func all() -> [Person] {
        return [
            Person(title: "👮", group: "1️⃣"),
            Person(title: "🎅", group: "2️⃣"),
            Person(title: "👷", group: "1️⃣"),
            Person(title: "🕵", group: "3️⃣")
        ]
    }
    
    class func allGroups() -> [String] {
        return ["1️⃣", "2️⃣", "3️⃣"]
    }
    
    func selectableOptionTitle() -> String {
        return title
    }
    
    func selectableOptionSectionTitle() -> String {
        return group
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let object = object as? Person else {
            return false
        }
        
        return self.title == object.title && self.group == object.group
    }
}

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameRow = FormRow(title: "Vorname", value: "Andreas")
        
        form.sections = [
            FormSection(title: "Static", rows: [
                nameRow,
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                FormRow(title: "Land", value: "🇦🇹 Austria", cellClass: SubtitleFormCell.self),
                FormRow(title: "Telefon", value: "+43 1 53422"),
                FormRow(title: "Email", value: "hello@example.com")
            ])
        ]
        
        form.sections.append(
            FormSection(title: "Various text field rows", rows: [
                TextFieldFormRow(title: "Text", value: nil, placeholder: "Text", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }),
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
            FormSection(title: "Date Picker", rows: [
                DatePickerFormRow(title: "Date", value: nil, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                DatePickerFormRow(title: "Time", value: nil, datePickerMode: .Time, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                DatePickerFormRow(title: "Date & Time", value: nil, datePickerMode: .DateAndTime, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        )
            
        form.sections.append(
            FormSection(title: "Boolean", rows: [
                SwitchFormRow(title: "Lights on", value: true, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectableFormRow(title: "Happy?", selected: true, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        )
        
        form.sections.append(
            FormSection(title: "✅ Options", rows: [
                SelectionFormRow(title: "Emoji", options: ["🐣", "👸", "🐮"], selectedOption: nil, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                
                SelectionFormRow(title: "Animals", options: Animal.all(), selectedOption: Animal.Dog, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectionFormRow(title: "🙃", options: Person.all(), selectedOption: Person.all().first, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                SelectionFormRow(title: "🙃 Grouped", options: Person.all(), selectedOption: Person.all().last, sectionTitles: Person.allGroups(), cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        )
        
        delay(3.0) {
            nameRow.value = "Andy"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

