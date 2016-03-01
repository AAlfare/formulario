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
        FormRow(title: "Nachname", value: "Alfarè", cellSelection: { (cell) -> Void in
          print("cell selected")
        }),
        TextFieldFormRow(title: "Email", value: nil, placeholder: "Email", cellSelection: nil, valueChanged: { (row) -> Void in
          print(row.value)
        })
      ])
    ]
  }
}
```

## Create custom cell classes
```swift
class CustomCell: FormCell {
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    // add custom views
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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