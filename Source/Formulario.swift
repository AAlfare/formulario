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
    var tableStyle: UITableViewStyle = .Plain
    
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
        LabelFormCell.self,
        SubtitleFormCell.self,
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
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FormCell {
            row.selection?(cell)
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
        row.form = self
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.cellClass.cellIdentifier(), forIndexPath: indexPath)
        if let cell = cell as? FormCell {
            cell.row = row
            cell.configure(row)
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.cell = cell as? FormCell
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.cell = nil
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

public typealias FormCellSelectionClosureType = FormCell -> Void

public class FormRow: NSObject {
    weak var form: Form?
    public var title: String?
    public var value: Any? {
        didSet {
            cell?.configure(self)
            valueChanged?(self)
        }
    }
    weak var cell: FormCell?
    public var cellClass: FormCell.Type
    public var selection: FormCellSelectionClosureType?
    public var valueChanged: ((FormRow)->Void)?
    
    public init(title: String?, value: Any?, cellClass: FormCell.Type = LabelFormCell.self, cellSelection: FormCellSelectionClosureType? = nil, valueChanged: ((FormRow)->Void)? = nil) {
        self.title = title
        self.value = value
        self.cellClass = cellClass
        self.selection = cellSelection
        self.valueChanged = valueChanged
        super.init()
    }
    
}

public class TextFieldFormRow: FormRow {
    var placeholder: String?
    public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.placeholder = placeholder
        super.init(title: title, value: value, cellClass: TextFieldFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

public class EmailFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = EmailFormCell.self
    }
}

public class PasswordFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = PasswordFormCell.self
    }
}

public class PhoneFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = PhoneFormCell.self
    }
}

public class DecimalFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = DecimalFormCell.self
    }
}

public class CurrencyFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, placeholder: placeholder, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = CurrencyFormCell.self
    }
}

public class SwitchFormRow: FormRow {
    public init(title: String?, value: Bool, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: value, cellClass: SwitchFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

public protocol SelectableOption {
    func selectableOptionTitle() -> String
    func selectableOptionSectionTitle() -> String
}

extension SelectableOption {
    public func selectableOptionSectionTitle() -> String {
        return ""
    }
}

extension String: SelectableOption {
    public func selectableOptionTitle() -> String {
        return self
    }
}

public class OptionsFormRow<T: SelectableOption>: FormRow {
    var options: [T]
    var selectedOption: T? {
        get {
            return value as? T
        }
        set {
            value = newValue
        }
    }
    
    public init(title: String?, options: [T], selectedOption: T?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.options = options
        super.init(title: title, value: nil, cellClass: FormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        self.selectedOption = selectedOption
    }
}


public class SelectionFormRow<T: SelectableOption where T: Equatable>: OptionsFormRow<T> {
    var sectionTitles: [String]?
    var tableStyle: UITableViewStyle
    
    public init(title: String?, options: [T], selectedOption: T?, sectionTitles: [String]? = nil, tableStyle: UITableViewStyle = .Plain, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.tableStyle = tableStyle
        super.init(title: title, options: options, selectedOption: selectedOption, cellSelection: nil, valueChanged: valueChanged)
        self.sectionTitles = sectionTitles
        self.cellClass = SelectionFormCell.self
        self.selection = { cell in
            cellSelection?(cell)
            let optionsFormViewController = SelectionFormViewController(selectionRow: self)
            cell.row?.form?.formViewController?.navigationController?.pushViewController(optionsFormViewController, animated: true)
        }
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
    
    public init(title: String?, selected: Bool = false, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, value: selected, cellClass: SelectableFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

// MARK: - Cells

public class FormCell: UITableViewCell {
    public var row: FormRow?
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func cellIdentifier() -> String {
        return String.fromCString(class_getName(self)) ?? "FormCell"
    }
    
    public func configure(row: FormRow) {
        self.textLabel?.text = row.title ?? row.value as? String
        self.detailTextLabel?.text = row.title != nil ? row.value as? String : nil
    }
}

public class LabelFormCell: FormCell {
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class SubtitleFormCell: FormCell {
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        super.init(coder: aDecoder)
    }
    
    override public func configure(row: FormRow) {
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
        super.init(coder: aDecoder)
    }
}

public class PasswordFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.secureTextEntry = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class PhoneFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .PhonePad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class DecimalFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .DecimalPad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class CurrencyFormCell: TextFieldFormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.keyboardType = .NumberPad
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        super.init(coder: aDecoder)
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
        super.init(coder: aDecoder)
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
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .Default
        accessoryType = .DisclosureIndicator
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
    }
    func didSelect(gestureRecognizer: UIGestureRecognizer) {
        row?.selection?(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override func configure(row: FormRow) {
        super.configure(row)
        
        if let option = row.value as? SelectableOption {
            detailTextLabel?.text = option.selectableOptionTitle()
        }
    }
}

public class SelectableFormCell: FormCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func didSelect(gestureRecognizer: UIGestureRecognizer) {
        guard let selected = (row as? SelectableFormRow)?.selected else {
            return
        }
        (row as? SelectableFormRow)!.selected = !selected
        row?.selection?(self)
        if let row = row {
            configure(row)
        }
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
        self.init(style: form.tableStyle)
        self.form = form
    }
    
    public init() {
        super.init(style: form.tableStyle)
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

class SelectionFormViewController<T: SelectableOption where T: Equatable>: FormViewController {
    var selectionRow: SelectionFormRow<T>
    var selectedOptionIndexPath: NSIndexPath?
    var allowsMultipleSelection = false
    
    init(selectionRow: SelectionFormRow<T>) {
        self.selectionRow = selectionRow
        super.init(style: selectionRow.tableStyle)
    }

    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectionRow.title
        
        var groupedOptions: [String: [T]] = [String: [T]]()
        for option in selectionRow.options {
            let sectionTitle = selectionRow.sectionTitles != nil ? option.selectableOptionSectionTitle() : ""
            var sectionArray = groupedOptions[sectionTitle]
            if sectionArray == nil {
                sectionArray = [T]()
            }
            sectionArray!.append(option)
            groupedOptions[sectionTitle] = sectionArray!
        }
        
        let sectionTitles = selectionRow.sectionTitles ?? groupedOptions.map({ (sectionTitle, options) in sectionTitle })
        for (sectionIndex, sectionTitle) in sectionTitles.enumerate() {
            var section = FormSection(title: sectionTitle)
            if let options = groupedOptions[sectionTitle] {
                for (rowIndex, option) in options.enumerate() {
                    section.rows.append(SelectableFormRow(title: option.selectableOptionTitle(), selected: self.selectionRow.selectedOption == option, cellSelection: { (cell) in
                        self.selectionRow.selectedOption = option
                        if self.allowsMultipleSelection == false {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }, valueChanged: nil))
                    if self.selectionRow.selectedOption == option {
                        self.selectedOptionIndexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                    }
                }
            }
            form.sections.append(section)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.selectRowAtIndexPath(self.selectedOptionIndexPath, animated: false, scrollPosition: .Middle)
        }
    }
}
