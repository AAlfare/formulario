# Formulario
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Language: Swift 2](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Easy formular creation

## Add rows to your form

```swift
import Formulario

class ViewController: FormViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    form.sections = [
      FormSection(rows: [
        FormRow(title: "Vorname", value: "Andreas"),
        TextFieldFormRow(title: "Nachname", value: "Alfarè", placeholder: "Nachname", cellSelection: nil, valueChanged: { (row) -> Void in
          print(row.value)
        }),
        EmailFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: { (row) -> Void in
          print(row.value)
        }),
        SwitchFormRow(title: "Lights on", value: true, cellSelection: nil, valueChanged: { (row) in
          print(row.value)
        }),
        SelectionFormRow(title: "Emoji", options: ["🐣", "👸", "🐮"], selectedOption: "🐮", cellSelection: nil, valueChanged: { (row) in
          print(row.value)
        })
      ])
    ]
  }
}
```

## Available rows
```
FormRow
TextFieldFormRow
EmailFormRow
PasswordFormRow
PhoneFormRow
DecimalFormRow
CurrencyFormRow
SwitchFormRow
SelectableFormRow
SelectionFormRow
```

## Selectable form row with custom types
By conforming to the SelectableOption protocol formulario will automatically display the given title in the form.
```swift
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

let row = SelectionFormRow(title: "Animals", options: Animal.all(), selectedOption: Animal.all().first,  cellSelection: nil, valueChanged: { (row) in
  print(row.value)
})
```

### Group options with section titles
```swift
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

let row = SelectionFormRow(title: "Persons", options: Person.all(), selectedOption: nil, sectionTitles: Person.allGroups(),  cellSelection: nil, valueChanged: { (row) in
  print(row.value)
})
```

## Create custom cell classes
```swift
class CustomCell: FormCell {
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    // add custom views
  }
  override func configure(row: FormRow) {
    super.configure(row)
    // configure your cell
  }
}
```

Register your custom cell classes (e.g. in applicaltion:didFinishLaunchingWithOptions)
```swift
Form.registerCellClass(CustomCell.self)
```

After registering the cell class simply add a row to your form …
```swift
FormRow(title: "Farbe", value: UIColor.redColor(), cellClass: CustomCell.self, cellSelection: nil, valueChanged: nil)
```

… or create a custom FormRow:
```swift
class ColorFormRow: FormRow {
  var color: UIColor?
  public init(title: String?, color: UIColor?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
    self.color = color
    super.init(title: title, value: color, cellClass: CustomCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
  }
}
```

## Install via Carthage
```
github "AAlfare/Formulario"
```

## Changelog

**0.4.3** (*26.04.2016*)
- Prevents updating wrong (dequeued) cell if it was removed from table
- Adds LabelFormCell and SubtitleFormCell
- Cleans up example code

**0.4.2** (*26.04.2016*)
- Update the UI of a cell after changing the value of a row

**0.4.1** (*22.04.2016*)
- Set initial selected option in selection form row

**0.4** (*22.04.2016*)
- Selection form row now accepts custom types as options

**0.3** (*14.04.2016*)
- Adds Selectable and Selection form rows

**0.2** (*12.04.2016*)
- Adds Email, Password, Phone, Decimal and Currency form rows
- Adds Switch form row

**0.1** (*01.03.2016*)
- Adds FormViewController, FormRow and FormSection to build a Form
- Adds Slider form cell
- Adds TextField form row
- Example project
