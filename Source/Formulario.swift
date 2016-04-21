//
//  Formulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

public class Form: NSObject {
    var formViewController: FormViewController?
    
    public var sections: [FormSection] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    public var tableView: UITableView? {
        willSet {
            tableView?.dataSource = nil
            tableView?.delegate = nil
        }
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.keyboardDismissMode = .OnDrag
            
            for cellClass in Form.registeredCellClasses {
                tableView?.registerClass(cellClass, forCellReuseIdentifier: cellClass.cellIdentifier())
            }
        }
    }
    
    private static var registeredCellClasses = [
        FormCell.self,
        TextFieldFormCell.self,
        EmailFormCell.self,
        PasswordFormCell.self,
        PhoneFormCell.self,
        DecimalFormCell.self,
        CurrencyFormCell.self,
        SliderFormCell.self,
        SwitchFormCell.self,
        SelectionFormCell.self,
        SelectableFormCell.self
    ]
    
    public class func registerCellClass(cellClass: FormCell.Type) {
        registeredCellClasses.append(cellClass)
    }
    
    public convenience override init() {
        self.init(sections: [])
    }
    
    public init(sections: [FormSection]) {
        self.sections = sections
        super.init()
    }
}

extension Form: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if formViewController is SelectionFormViewController, let selectedRow = sections[indexPath.section].rows[indexPath.row] as? SelectableFormRow {
            selectedRow.selected = false
            if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? FormCell {
                selectedCell.configure(selectedRow)
            }
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FormCell {
            row.selection?(cell)
            
//            if let selectionRow = row as? SelectionFormRow {
//                let optionsFormViewController = SelectionFormViewController(selectionRow: selectionRow)
//                self.formViewController?.navigationController?.pushViewController(optionsFormViewController, animated: true)
//            }
            
            if let selectableRow = row as? SelectableFormRow {
                selectableRow.selected = formViewController is SelectionFormViewController ? true : !selectableRow.selected
                cell.configure(selectableRow)
            }
        }
    }
}

extension Form: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.cellClass.cellIdentifier(), forIndexPath: indexPath) as! FormCell
        cell.configure(row)
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
}

public struct FormSection {
    var rows: [FormRow]
    var title: String?
    public init(title: String? = nil, rows: [FormRow] = []) {
        self.title = title
        self.rows = rows
    }
}

// MARK: - Rows

public class FormRow: NSObject {
    public var title: String?
    dynamic public var value: AnyObject?
    public var cellClass: FormCell.Type
    public var selection: ((FormCell)->Void)?
    public var valueChanged: ((FormRow)->Void)?
    
    public init(title: String?, value: AnyObject?, cellClass: FormCell.Type? = nil, cellSelection: ((FormCell) -> Void)? = nil, valueChanged: ((FormRow)->Void)? = nil) {
        self.title = title
        self.value = value
        self.cellClass = cellClass ?? FormCell.self
        self.selection = cellSelection
        self.valueChanged = valueChanged
        super.init()
        addObserver(self, forKeyPath: "value", options: .New, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "value")
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "value" {
            valueChanged?(self)
        }
    }
}

public class TextFieldFormRow: FormRow {
    var placeholder: String?
    public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        self.placeholder = placeholder
        super.init(title: title, value: value, cellClass: TextFieldFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

public class EmailFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = EmailFormCell.self
    }
}

public class PasswordFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = PasswordFormCell.self
    }
}

public class PhoneFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = PhoneFormCell.self
    }
}

public class DecimalFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = DecimalFormCell.self
    }
}

public class CurrencyFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = CurrencyFormCell.self
    }
}

public class SwitchFormRow: FormRow {
    public init(title: String?, value: Bool, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, cellClass: SwitchFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

public protocol SelectableOption {
    
}

extension String: SelectableOption {
}

public class OptionsFormRow<T: SelectableOption>: FormRow {
    var options: [T]
    
    public init(title: String?, options: [T], cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        self.options = options
        super.init(title: title, value: nil, cellClass: FormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}


public class SelectionFormRow<T: SelectableOption>: OptionsFormRow<T> {
//    var selectedOption: String? {
//        get {
//            return value as? String
//        }
//        set {
//            value = newValue
//        }
//    }
    public override init(title: String?, options: [T], cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, options: options, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = SelectionFormCell.self
    }
}

public class SelectableFormRow: FormRow {
    var selected: Bool {
        get {
            return value as? Bool ?? false
        }
        set {
            value = newValue
        }
    }
    
    public init(title: String?, selected: Bool = false, cellSelection: ((FormCell) -> Void)?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: selected, cellClass: SelectableFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

// MARK: - Cells

public class FormCell: UITableViewCell {
    public var row: FormRow?
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func cellIdentifier() -> String {
        return String.fromCString(class_getName(self)) ?? "FormCell"
    }
    
    public func configure(row: FormRow) {
        self.row = row
        self.textLabel?.text = row.title ?? row.value as? String
        self.detailTextLabel?.text = row.title != nil ? row.value as? String : nil
    }
}

public class TextFieldFormCell: FormCell, UITextFieldDelegate {
    var textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        textField.addTarget(self, action: #selector(TextFieldFormCell.textFieldValueChanged(_:)), forControlEvents: .EditingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(100, forAxis: .Horizontal)
        textField.textAlignment = .Right
        contentView.addSubview(textField)
        
        let views = [
            "textLabel": textLabel!,
            "textField": textField
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textLabel]-[textField]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textField]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textLabel]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func configure(row: FormRow) {
        self.row = row
        textLabel?.text = row.title
        textField.text = row.value as? String
        textField.placeholder = (row as? TextFieldFormRow)?.placeholder
    }
    
    func textFieldValueChanged(textField: UITextField) {
        row?.value = textField.text
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        if selected {
            textField.becomeFirstResponder()
        }
    }
}

public class EmailFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .EmailAddress
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class PasswordFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.secureTextEntry = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class PhoneFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .PhonePad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DecimalFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .DecimalPad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CurrencyFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .NumberPad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textFieldValueChanged(textField: UITextField) {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        
        if let centString = textField.text?.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("") where centString.isEmpty == false {
            let centValue = (centString as NSString).doubleValue
            let number = NSNumber(float: Float(centValue)/100.0)
            row?.value = number.floatValue
            textField.text = formatter.stringFromNumber(number)
        } else {
            row?.value = nil
            textField.text = nil
        }
    }
}

public class SliderFormCell: FormCell {
    var slider = UISlider()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(SliderFormCell.sliderChanged(_:)), forControlEvents: .ValueChanged)
        slider.setContentHuggingPriority(100, forAxis: .Horizontal)
        contentView.addSubview(slider)
        
        let views = [
            "textLabel": textLabel!,
            "slider": slider
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textLabel]-[slider]-16-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[slider]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textLabel]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func configure(row: FormRow) {
        super.configure(row)
        if let value = row.value as? Float {
            slider.value = value
        }
    }
    func sliderChanged(slider: UISlider) {
        row?.value = slider.value
    }
}

public class SwitchFormCell: FormCell {
    var switchControl = UISwitch()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(SwitchFormCell.switched(_:)), forControlEvents: .ValueChanged)
        switchControl.setContentHuggingPriority(100, forAxis: .Horizontal)
        contentView.addSubview(switchControl)
        
        let views = [
            "textLabel": textLabel!,
            "switchControl": switchControl
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textLabel]-(>=15)-[switchControl]-16-|", options: [], metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: switchControl, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textLabel]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func configure(row: FormRow) {
        super.configure(row)
        if let value = row.value as? Bool {
            switchControl.on = value
        }
    }
    func switched(control: UISwitch) {
        row?.value = control.on
    }
}

public class SelectionFormCell: FormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .Default
        accessoryType = .DisclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class SelectableFormCell: FormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public override func configure(row: FormRow) {
        super.configure(row)
        textLabel?.text = row.title
        detailTextLabel?.text = nil
        
        if let row = row as? SelectableFormRow {
            accessoryType = row.selected == true ? .Checkmark : .None
        }
    }
}

// MARK: - FormViewController

public class FormViewController: UITableViewController {
    public var form = Form() {
        willSet {
            form.tableView = nil
            form.formViewController = nil
        }
        didSet {
            form.tableView = tableView
            form.formViewController = self
        }
    }
    
    // MARK: - Initialization
    
    public convenience init(form: Form) {
        self.init(style: .Plain)
        self.form = form
    }
    
    public init() {
        super.init(style: .Plain)
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        form.tableView = tableView
        form.formViewController = self
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class SelectionFormViewController: FormViewController {
//    var selectionRow: SelectionFormRow
//    var selectedOptionIndexPath: NSIndexPath?
//    var allowsMultipleSelection = false
//    
//    init(selectionRow: SelectionFormRow) {
//        self.selectionRow = selectionRow
//        super.init()
//    }
//    
//    required internal init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        title = selectionRow.title
//        
//        var optionRows = [FormRow]()
//        for (index, option) in selectionRow.options.enumerate() {
//            if self.selectionRow.selectedOption == option {
//                self.selectedOptionIndexPath = NSIndexPath(forRow: index, inSection: 0)
//            }
//            optionRows.append(SelectableFormRow(title: option, selected: selectionRow.selectedOption == option, cellSelection: { (cell) in
//                self.selectionRow.selectedOption = option
//                if self.allowsMultipleSelection == false {
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//            }, valueChanged: nil))
//        }
//        form = Form(sections: [FormSection(title: nil, rows: optionRows)])
//        
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        tableView.selectRowAtIndexPath(selectedOptionIndexPath, animated: false, scrollPosition: .None)
//    }
}
