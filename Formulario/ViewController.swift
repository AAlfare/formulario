//
//  ViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import Formulario
import MapKit

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
        
        form.title = "Formulario"
        
        let nameRow = FormRow(title: "Vorname", value: "Andreas")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left
        
        let multiLineText = NSMutableAttributedString(string: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.", attributes: [ NSParagraphStyleAttributeName: paragraphStyle ])
        
        form.sections = [
            FormSection(title: "Static", rows: [
                nameRow,
                FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
                    print("cell selected")
                }),
                FormRow(title: "Land", value: "🇦🇹 Austria", cellClass: SubtitleFormCell.self),
                FormRow(title: "Multiline", value: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.", cellClass: MultiLineLabelFormCell.self),
                FormRow(title: nil, value: multiLineText, cellClass: MultiLineLabelFormCell.self),
                FormRow(title: "Telefon", value: "+43 1 53422"),
                FormRow(title: "Email", value: "hello@example.com"),
                FormRow(title: "Address", value: "Salzburg\nÖsterreich", cellClass: MultiLineLabelFormCell.self, cellHeight: 60)
            ])
        ]
        
        form.sections.append(
            FormSection(title: "Various text field rows", rows: [
                TextFieldFormRow(title: "Text", value: nil, placeholder: "Text", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                }, didEndEditing: {
                    print("text field did end editing")
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
                CurrencyFormRow(title: "Price", value: NSDecimalNumber(double: 99.0), placeholder: "Price", cellSelection: nil, valueChanged: { (row) -> Void in
                    print(row.value)
                })
            ])
        )
        
        let customDateFormatter = NSDateFormatter()
        customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        form.sections.append(
            FormSection(title: "Date Picker", rows: [
                DatePickerFormRow(title: "Date", value: nil, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                DatePickerFormRow(title: "Time", value: NSDate(), datePickerMode: .Time, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                }),
                DatePickerFormRow(title: "⌚️", value: nil, dateFormatter: customDateFormatter, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        )
            
        form.sections.append(
            FormSection(title: "Boolean", rows: [
                SwitchFormRow(title: "Lights on", value: false, cellSelection: nil, valueChanged: { (row) in
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
                }),
                DropdownFormRow(title: "Dropdown", options: Animal.all(), selectedOption: Animal.Sheep, cellSelection: nil, valueChanged: { (row) in
                    print(row.value)
                })
            ])
        )
        
        let mapRow = MapFormRow(coordinate: CLLocationCoordinate2D(latitude: 47.8, longitude: 13.033333), cellHeight: 100, cellSelection: nil, valueChanged: nil)
        form.sections.append(
            FormSection(title: "Map", rows: [
                mapRow
            ])
        )
        
        delay(5.0) {
            nameRow.value = "Andy"
            mapRow.value = CLLocationCoordinate2D(latitude: 47.81, longitude: 13.03)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

