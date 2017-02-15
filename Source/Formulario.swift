//
//  Formulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import MapKit

public class Form: NSObject {
    public var title: String?
    public var formViewController: UIViewController?
    var tableStyle: UITableViewStyle = .Plain
    public var minimalRowHeight: CGFloat = 44.5
    public var layoutAxis: UILayoutConstraintAxis = .Horizontal
    
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
            tableView?.rowHeight = UITableViewAutomaticDimension
            tableView?.estimatedRowHeight = 50
            
            for cellClass in Form.registeredCellClasses {
                tableView?.registerClass(cellClass, forCellReuseIdentifier: cellClass.cellIdentifier())
            }
        }
    }
    
    private static var registeredCellClasses: [Cell.Type] = [
        Cell.self,
        FormCell.self,
        LabelFormCell.self,
        MultiLineLabelFormCell.self,
        SubtitleFormCell.self,
        TextFieldFormCell.self,
        EmailFormCell.self,
        PasswordFormCell.self,
        PhoneFormCell.self,
        DecimalFormCell.self,
        CurrencyFormCell.self,
        DatePickerFormCell.self,
        SliderFormCell.self,
        SwitchFormCell.self,
        SelectionFormCell.self,
        SelectableFormCell.self,
        DropdownFormCell.self,
        MapFormCell.self
    ]
    
    public class func registerCellClass(cellClass: Cell.Type) {
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
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell {
            row.selection?(cell)
        }
    }
}

extension Form: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].visibleRows.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.form = self
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.cellClass.cellIdentifier(), forIndexPath: indexPath)
        if let cell = cell as? Cell {
            cell.row = row
            cell.configure(row)
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.cell = cell as? Cell
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section < sections.count else {
            return
        }
        guard indexPath.row < sections[indexPath.section].visibleRows.count else {
            return
        }
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.cell = nil
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
    
//    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let section = sections[indexPath.section]
//        return section.rows[indexPath.row].cellHeight
//    }
}

public struct FormSection {
    public var rows: [FormRow]
    public var visibleRows: [FormRow] {
        return rows.filter({ $0.hidden == false })
    }
    public var title: String?
    public init(title: String? = nil, rows: [FormRow] = []) {
        self.title = title
        self.rows = rows
    }
}

// MARK: - Rows

public typealias FormCellSelectionClosureType = (Cell -> Void)

public class FormRow: NSObject {
    weak public var form: Form?
    public var title: String?
    public var value: Any? {
        didSet {
            cell?.configure(self)
            valueChanged?(self)
        }
    }
    public var cellHeight: CGFloat = 44
    public weak var cell: Cell?
    public var cellClass: Cell.Type
    public var selection: FormCellSelectionClosureType?
    public var valueChanged: ((FormRow)->Void)?
    public var hidden: Bool = false
    
    public init(title: String?, value: Any?, cellClass: Cell.Type = LabelFormCell.self, cellHeight: CGFloat? = nil, cellSelection: FormCellSelectionClosureType? = nil, valueChanged: ((FormRow)->Void)? = nil) {
        self.title = title
        self.value = value
        self.cellClass = cellClass
        if let cellHeight = cellHeight {
            self.cellHeight = cellHeight
        }
        self.selection = cellSelection
        self.valueChanged = valueChanged
        super.init()
    }
    
}

public class TextFieldFormRow: FormRow {
    public var placeholder: String?
    public var textFieldDidEndEditing: (() -> Void)?
    
    public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = TextFieldFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.textFieldDidEndEditing = textFieldDidEndEditing
        super.init(title: title, value: value, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

public class EmailFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = EmailFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

public class PasswordFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = PasswordFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

public class PhoneFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = PhoneFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

public class DecimalFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = DecimalFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

public class CurrencyFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = CurrencyFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

public class DatePickerFormRow: FormRow {
    public var datePickerMode: UIDatePickerMode
    public var formatter: NSDateFormatter?
    
    public class func defaultFormatter(datePickerMode: UIDatePickerMode) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        var dateStyle = NSDateFormatterStyle.NoStyle
        var timeStyle = NSDateFormatterStyle.NoStyle
        switch datePickerMode {
        case .Date:
            dateStyle = .LongStyle
        case .Time:
            timeStyle = .ShortStyle
        case .DateAndTime:
            dateStyle = .LongStyle
            timeStyle = .ShortStyle
        case .CountDownTimer:
            timeStyle = .NoStyle
        }
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
    
    public init(title: String?, value: NSDate?, datePickerMode: UIDatePickerMode = .Date, dateFormatter: NSDateFormatter? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.datePickerMode = datePickerMode
        super.init(title: title, value: value, cellClass: DatePickerFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        self.formatter = dateFormatter
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
    public var options: [T]
    public var selectedOption: T? {
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

public class DropdownFormRow<T: SelectableOption where T: Equatable>: OptionsFormRow<T>, UIPickerViewDataSource, UIPickerViewDelegate {
    override public var cell: Cell? {
        didSet {
            let dropdownCell = cell as? DropdownFormCell
            dropdownCell?.picker.dataSource = self
            dropdownCell?.picker.delegate = self
            
            if let selectedOption = selectedOption, let selectedOptionIndex = options.indexOf(selectedOption) {
                dropdownCell?.picker.selectRow(selectedOptionIndex, inComponent: 0, animated: false)
            }
        }
    }
    public override init(title: String?, options: [T], selectedOption: T?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, options: options, selectedOption: selectedOption, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = DropdownFormCell.self
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].selectableOptionTitle()
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = options[row]
    }
}

public struct MapConfiguration {
    public var mapType: MKMapType
    public var shouldAnimateInitially: Bool
    public var shouldAnimateOnCoordinateChange: Bool
    public var zoomEnabled: Bool
    public var scrollEnabled: Bool
    public var pitchEnabled: Bool
    public var rotateEnabled: Bool
    
    public init(mapType: MKMapType = .Standard,
         shouldAnimateInitially: Bool = false,
         shouldAnimateOnCoordinateChange: Bool = true,
         zoomEnabled: Bool = false,
         scrollEnabled: Bool = false,
         pitchEnabled: Bool = false,
         rotateEnabled: Bool = false)
    {
        self.mapType = mapType
        self.shouldAnimateInitially = shouldAnimateInitially
        self.shouldAnimateOnCoordinateChange = shouldAnimateOnCoordinateChange
        self.zoomEnabled = zoomEnabled
        self.scrollEnabled = scrollEnabled
        self.pitchEnabled = pitchEnabled
        self.rotateEnabled = rotateEnabled
    }
}

public class MapFormRow: FormRow {
    var mapConfiguration: MapConfiguration
    public init(coordinate: CLLocationCoordinate2D?, cellHeight: CGFloat? = nil, mapConfiguration: MapConfiguration? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.mapConfiguration = mapConfiguration ?? MapConfiguration()
        super.init(title: nil, value: coordinate, cellClass: MapFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        if let cellHeight = cellHeight {
            self.cellHeight = cellHeight
        }
    }
    public init(location: CLLocation?, cellHeight: CGFloat? = nil, mapConfiguration: MapConfiguration? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.mapConfiguration = mapConfiguration ?? MapConfiguration()
        super.init(title: nil, value: location, cellClass: MapFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        if let cellHeight = cellHeight {
            self.cellHeight = cellHeight
        }
    }
}

// MARK: - Cells

public class Cell: UITableViewCell {
    public var row: FormRow?
    
    class func cellIdentifier() -> String {
        return String.fromCString(class_getName(self)) ?? "Cell"
    }
    
    public func configure(row: FormRow) {
        
    }
}

public class FormCell: Cell {
    
    public var container: UIView!
    public var titleContainer: UIView!
    public var titleLabel: UILabel!
    public var fieldContainer: UIView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public func setupUI() {
        
        selectionStyle = .None
        
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.preservesSuperviewLayoutMargins = false
        contentView.addSubview(container)
        
        titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.preservesSuperviewLayoutMargins = false
        container.addSubview(titleContainer)
        
        titleLabel = UILabel()
        titleLabel.font = textLabel?.font
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        fieldContainer = UIView()
        fieldContainer.translatesAutoresizingMaskIntoConstraints = false
        fieldContainer.preservesSuperviewLayoutMargins = false
        container.addSubview(fieldContainer)
    }
    
    public override func updateConstraints() {
        guard let row = row else {
            return
        }
        
        let views = [
            "contentView": contentView,
            "container": container,
            "titleContainer": titleContainer,
            "titleLabel": titleLabel,
            "fieldContainer": fieldContainer
        ]
        
        contentView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: row.form?.minimalRowHeight ?? 44.5))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[container]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[container]-|", options: [], metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[titleLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-|", options: [], metrics: nil, views: views))
        
        switch row.form?.layoutAxis {
        case .Horizontal?:
            container.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            container.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
            titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
            fieldContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[titleContainer][fieldContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[fieldContainer]-|", options: [], metrics: nil, views: views))
        case .Vertical?:
            container.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            container.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[titleContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[fieldContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleContainer][fieldContainer]-|", options: [], metrics: nil, views: views))
        default: ()
        }
        
        super.updateConstraints()
    }
    
    public override func configure(row: FormRow) {
        setNeedsUpdateConstraints()
        
        container.layoutMargins = UIEdgeInsets()
        titleContainer.layoutMargins = UIEdgeInsets()
        fieldContainer.layoutMargins = UIEdgeInsets()
        
        titleLabel.text = row.title
        
        if let layoutAxis = row.form?.layoutAxis {
            titleLabel.font = UIFont.systemFontOfSize(layoutAxis == .Vertical ? 14 : 17)
            switch layoutAxis {
            case .Horizontal:
                titleContainer.layoutMargins.right = row.title == nil ? 0 : 10
            case .Vertical:
                titleContainer.layoutMargins.bottom = row.title == nil ? 0 : 5
            }
        }
    }
}

public class LabelFormCell: FormCell {
    public var label: UILabel!
    
    override public func setupUI() {
        super.setupUI()
        
        fieldContainer.layoutMargins.top = 10
        fieldContainer.layoutMargins.bottom = 10
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.grayColor()
        fieldContainer.addSubview(label)
        
        let views = [
            "label": label
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[label]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]-|", options: [], metrics: nil, views: views))
    }
    
    public override func configure(row: FormRow) {
        super.configure(row)
        
        label.textAlignment = row.form?.layoutAxis == .Horizontal ? .Right : .Left
        
        if let attributedString = row.value as? NSAttributedString {
            label.attributedText = attributedString
        } else {
            label.text = row.value as? String
        }
        
    }
}

public class MultiLineLabelFormCell: LabelFormCell {
    override public func setupUI() {
        super.setupUI()
        
        label.numberOfLines = 0
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
    public var textField = UITextField()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        textField.addTarget(self, action: #selector(TextFieldFormCell.textFieldValueChanged(_:)), forControlEvents: .EditingChanged)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        fieldContainer.addSubview(textField)
        
        let views = [
            "textField": textField
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textField]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textField]-|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func configure(row: FormRow) {
        super.configure(row)
        
        textField.textAlignment = row.form?.layoutAxis == .Horizontal ? .Right : .Left
        textField.text = row.value as? String
        textField.placeholder = (row as? TextFieldFormRow)?.placeholder
    }
    
    func textFieldValueChanged(textField: UITextField) {
        row?.value = textField.text
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        (row as? TextFieldFormRow)?.textFieldDidEndEditing?()
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        if selected {
            textField.becomeFirstResponder()
        }
    }
}

public class EmailFormCell: TextFieldFormCell {
    override public func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .EmailAddress
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
    }
}

public class PasswordFormCell: TextFieldFormCell {
    override public func setupUI() {
        super.setupUI()
        
        textField.secureTextEntry = true
    }
}

public class PhoneFormCell: TextFieldFormCell {
    override public func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .PhonePad
    }
}

public class DecimalFormCell: TextFieldFormCell {
    override public func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .DecimalPad
    }
}

public class CurrencyFormCell: TextFieldFormCell {
    override public func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .NumberPad
    }
    
    override func textFieldValueChanged(textField: UITextField) {
        if let centString = textField.text?.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("") where centString.isEmpty == false {
            let centValue = (centString as NSString).doubleValue
            let number = NSDecimalNumber(double: centValue/100.0)
            row?.value = number
        } else {
            row?.value = nil
        }
    }
    
    public override func configure(row: FormRow) {
        super.configure(row)
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        
        let number = row.value as? NSDecimalNumber
        textField.text = number != nil ? formatter.stringFromNumber(number!) : nil
    }
}

public class DatePickerFormCell: TextFieldFormCell {
    public let datePicker = UIDatePicker()
    public let dateLabel = UILabel()
    public let clearButton = UIButton()
    public var clearButtonWidthConstraint: NSLayoutConstraint!
    
    override public func setupUI() {
        super.setupUI()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        textField.inputView = datePicker
        textField.delegate = self
        textField.hidden = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .Right
        fieldContainer.addSubview(dateLabel)
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("✕", forState: .Normal)
        clearButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        clearButton.addTarget(self, action: #selector(clearButtonTapped(_:)), forControlEvents: .TouchUpInside)
        clearButton.contentHorizontalAlignment = .Right
        fieldContainer.addSubview(clearButton)
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))]
        
        let views: [String: AnyObject] = [
            "textLabel": textLabel!,
            "dateLabel": dateLabel,
            "clearButton": clearButton,
            "textField": textField
        ]
        self.clearButtonWidthConstraint = NSLayoutConstraint(item: clearButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        contentView.addConstraint(clearButtonWidthConstraint!)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[dateLabel][clearButton]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[dateLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[clearButton]-|", options: [], metrics: nil, views: views))
    }
    
    func didSelect(gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        row?.value = datePicker.date
    }
    
    func datePickerValueChanged(datePicker: UIDatePicker) {
        row?.value = datePicker.date
    }
    
    func clearButtonTapped(sender: AnyObject) {
        row?.value = nil
        textField.resignFirstResponder()
    }
    
    public override func configure(row: FormRow) {
        super.configure(row)
        
        dateLabel.textAlignment = row.form?.layoutAxis == .Horizontal ? .Right : .Left
        
        if let row = row as? DatePickerFormRow {
            datePicker.datePickerMode = row.datePickerMode
        }
        
        if let date = row.value as? NSDate {
            let formatter = (row as? DatePickerFormRow)?.formatter ?? DatePickerFormRow.defaultFormatter(datePicker.datePickerMode)
            dateLabel.text = formatter.stringFromDate(date)
        } else {
            dateLabel.text = nil
        }
        clearButtonWidthConstraint.constant = row.value != nil ? 25 : 0
        contentView.layoutIfNeeded()
    }
}

public class DropdownFormCell: TextFieldFormCell {
    public let picker = UIPickerView()
    public let label = UILabel()
    
    override public func setupUI() {
        super.setupUI()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Right
        fieldContainer.addSubview(label)
        
        textField.inputView = picker
        textField.delegate = self
        textField.hidden = true
        
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))]
        
        let views: [String: AnyObject] = [
            "label": label
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[label]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]-|", options: [], metrics: nil, views: views))
    }
    
    func didSelect(gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    public override func configure(row: FormRow) {
        super.configure(row)
        
        label.textAlignment = row.form?.layoutAxis == .Horizontal ? .Right : .Left
        label.text = (row.value as? SelectableOption)?.selectableOptionTitle()
    }
}

public class SliderFormCell: FormCell {
    var slider = UISlider()
    
    override public func setupUI() {
        super.setupUI()
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(SliderFormCell.sliderChanged(_:)), forControlEvents: .ValueChanged)
        fieldContainer.addSubview(slider)
        
        let views = [
            "slider": slider
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[slider]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[slider]-|", options: [], metrics: nil, views: views))
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
    
    override public func setupUI() {
        super.setupUI()
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(SwitchFormCell.switched(_:)), forControlEvents: .ValueChanged)
        fieldContainer.addSubview(switchControl)
        
        let views = [
            "textLabel": textLabel!,
            "switchControl": switchControl
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[switchControl]-|", options: [], metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: switchControl, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
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

public class SelectionFormCell: LabelFormCell {
    override public func setupUI() {
        super.setupUI()
        
        selectionStyle = .Default
        accessoryType = .DisclosureIndicator
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
        
        contentView.layoutMargins.right = 0
    }
    
    func didSelect(gestureRecognizer: UIGestureRecognizer) {
        row?.selection?(self)
    }
    
    override public func configure(row: FormRow) {
        super.configure(row)
        
        if let option = row.value as? SelectableOption {
            label.text = option.selectableOptionTitle()
        }
    }
}

public class SelectableFormCell: FormCell {
    override public func setupUI() {
        super.setupUI()
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
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
    
    override public func configure(row: FormRow) {
        super.configure(row)
        
        if let row = row as? SelectableFormRow {
            accessoryType = row.selected == true ? .Checkmark : .None
        }
    }
}

public class MapFormPin: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    var color: UIColor
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.color = UIView().tintColor
        super.init()
    }
}

public class MapFormCell: FormCell, MKMapViewDelegate {
    var mapView: MKMapView!
    var mapInitialized = false
    
    override public func setupUI() {
        super.setupUI()
        
        mapView = MKMapView(frame: CGRectZero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectMap(_:))))
        fieldContainer.addSubview(mapView)
        
        let views = [
            "mapView": mapView
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[mapView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[mapView]-|", options: [], metrics: nil, views: views))
    }
    
    override public func configure(row: FormRow) {
        super.configure(row)
        
        layoutMargins = UIEdgeInsets()
        preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets()
        container.layoutMargins = UIEdgeInsets()
        fieldContainer.layoutMargins = UIEdgeInsets()
        
        var shouldAnimateRegionChange = false
        
        if let mapConfiguration = (row as? MapFormRow)?.mapConfiguration {
            mapView.mapType = mapConfiguration.mapType
            mapView.zoomEnabled = mapConfiguration.zoomEnabled
            mapView.scrollEnabled = mapConfiguration.scrollEnabled
            mapView.pitchEnabled = mapConfiguration.pitchEnabled
            mapView.rotateEnabled = mapConfiguration.rotateEnabled
            shouldAnimateRegionChange = !mapInitialized ? mapConfiguration.shouldAnimateInitially : mapConfiguration.shouldAnimateOnCoordinateChange
        }
        
        var coordinate: CLLocationCoordinate2D?
        
        if let location = row.value as? CLLocation {
            coordinate = location.coordinate
        } else if let locationCoordinate = row.value as? CLLocationCoordinate2D {
            coordinate = locationCoordinate
        }
        
        if let coordinate = coordinate where CLLocationCoordinate2DIsValid(coordinate) {
            var span = mapView.region.span
            span.latitudeDelta = 0.01
            span.longitudeDelta = 0.01
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            if coordinate.latitude != mapView.centerCoordinate.latitude && coordinate.longitude != mapView.centerCoordinate.longitude {
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotation(MapFormPin(coordinate: coordinate))
                mapView.setRegion(region, animated: shouldAnimateRegionChange)
            }
        }
        mapInitialized = true
    }
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        if let annotation = annotation as? MapFormPin {
            if #available(iOS 9.0, *) {
                annotationView?.pinTintColor = annotation.color
            } else {
                annotationView?.pinColor = .Red
            }
        }
        annotationView?.annotation = annotation
        
        return annotationView
    }
    
    func didSelectMap(recognizer: UITapGestureRecognizer) {
        row?.selection?(self)
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
        
        title = form.title
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
        
        title = selectionRow.title
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.selectRowAtIndexPath(self.selectedOptionIndexPath, animated: false, scrollPosition: .Middle)
        }
    }
}
