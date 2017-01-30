//
//  Formulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit
import MapKit

open class Form: NSObject {
    open var title: String?
    open var formViewController: UIViewController?
    var tableStyle: UITableViewStyle = .plain
    open var minimalRowHeight: CGFloat = 44.5
    open var layoutAxis: UILayoutConstraintAxis = .horizontal
    
    open var sections: [FormSection] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    open var tableView: UITableView? {
        willSet {
            tableView?.dataSource = nil
            tableView?.delegate = nil
        }
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.keyboardDismissMode = .onDrag
            tableView?.rowHeight = UITableViewAutomaticDimension
            tableView?.estimatedRowHeight = 50
            
            for cellClass in Form.registeredCellClasses {
                tableView?.register(cellClass, forCellReuseIdentifier: cellClass.cellIdentifier())
            }
        }
    }
    
    fileprivate static var registeredCellClasses: [Cell.Type] = [
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
    
    open class func registerCellClass(_ cellClass: Cell.Type) {
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
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? Cell {
            row.selection?(cell)
        }
    }
}

extension Form: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].visibleRows.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.form = self
        
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellClass.cellIdentifier(), for: indexPath)
        if let cell = cell as? Cell {
            cell.row = row
            cell.configure(row)
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.cell = cell as? Cell
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section < sections.count else {
            return
        }
        guard indexPath.row < sections[indexPath.section].visibleRows.count else {
            return
        }
        let row = sections[indexPath.section].visibleRows[indexPath.row]
        row.cell = nil
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
    
//    open func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

public typealias FormCellSelectionClosureType = ((Cell) -> Void)

open class FormRow: NSObject {
    weak open var form: Form?
    open var title: String?
    open var value: Any? {
        didSet {
            cell?.configure(self)
            valueChanged?(self)
        }
    }
    open var cellHeight: CGFloat = 44
    open weak var cell: Cell?
    open var cellClass: Cell.Type
    open var selection: FormCellSelectionClosureType?
    open var valueChanged: ((FormRow)->Void)?
    open var hidden: Bool = false
    
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

open class TextFieldFormRow: FormRow {
    open var placeholder: String?
    open var textFieldDidEndEditing: (() -> Void)?
    
    public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = TextFieldFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.textFieldDidEndEditing = textFieldDidEndEditing
        super.init(title: title, value: value, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

open class EmailFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = EmailFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class PasswordFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = PasswordFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class PhoneFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = PhoneFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class DecimalFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = DecimalFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class CurrencyFormRow: TextFieldFormRow {
    override public init(title: String?, value: AnyObject?, placeholder: String?, cellClass: Cell.Type = CurrencyFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class DatePickerFormRow: FormRow {
    open var datePickerMode: UIDatePickerMode
    open var formatter: DateFormatter?
    
    open class func defaultFormatter(_ datePickerMode: UIDatePickerMode) -> DateFormatter {
        let formatter = DateFormatter()
        var dateStyle = DateFormatter.Style.none
        var timeStyle = DateFormatter.Style.none
        switch datePickerMode {
        case .date:
            dateStyle = .long
        case .time:
            timeStyle = .short
        case .dateAndTime:
            dateStyle = .long
            timeStyle = .short
        case .countDownTimer:
            timeStyle = .none
        }
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
    
    public init(title: String?, value: Date?, datePickerMode: UIDatePickerMode = .date, dateFormatter: DateFormatter? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.datePickerMode = datePickerMode
        super.init(title: title, value: value, cellClass: DatePickerFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        self.formatter = dateFormatter
    }
}

open class SwitchFormRow: FormRow {
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

open class OptionsFormRow<T: SelectableOption>: FormRow {
    open var options: [T]
    open var selectedOption: T? {
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

open class SelectionFormRow<T: SelectableOption>: OptionsFormRow<T> where T: Equatable {
    var sectionTitles: [String]?
    var tableStyle: UITableViewStyle
    
    public init(title: String?, options: [T], selectedOption: T?, sectionTitles: [String]? = nil, tableStyle: UITableViewStyle = .plain, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
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

open class SelectableFormRow: FormRow {
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

open class DropdownFormRow<T: SelectableOption>: OptionsFormRow<T>, UIPickerViewDataSource, UIPickerViewDelegate where T: Equatable {
    override open var cell: Cell? {
        didSet {
            let dropdownCell = cell as? DropdownFormCell
            dropdownCell?.picker.dataSource = self
            dropdownCell?.picker.delegate = self
            
            if let selectedOption = selectedOption, let selectedOptionIndex = options.index(of: selectedOption) {
                dropdownCell?.picker.selectRow(selectedOptionIndex, inComponent: 0, animated: false)
            }
        }
    }
    public override init(title: String?, options: [T], selectedOption: T?, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, options: options, selectedOption: selectedOption, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = DropdownFormCell.self
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].selectableOptionTitle()
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    public init(mapType: MKMapType = .standard,
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

open class MapFormRow: FormRow {
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

open class Cell: UITableViewCell {
    open var row: FormRow?
    
    class func cellIdentifier() -> String {
        return String(cString: class_getName(self))
    }
    
    open func configure(_ row: FormRow) {
        
    }
}

open class FormCell: Cell {
    
    open var container: UIView!
    open var titleContainer: UIView!
    open var titleLabel: UILabel!
    open var fieldContainer: UIView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    open func setupUI() {
        
        selectionStyle = .none
        
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
    
    open override func updateConstraints() {
        guard let row = row else {
            return
        }
        
        let views: [String: Any] = [
            "contentView": contentView,
            "container": container,
            "titleContainer": titleContainer,
            "titleLabel": titleLabel,
            "fieldContainer": fieldContainer
        ]
        
        contentView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: row.form?.minimalRowHeight ?? 44.5))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[container]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[container]-|", options: [], metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[titleLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: nil, views: views))
        
        switch row.form?.layoutAxis {
        case .horizontal?:
            container.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            container.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
            
            titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
            titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
            
            fieldContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[titleContainer][fieldContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[fieldContainer]-|", options: [], metrics: nil, views: views))
        case .vertical?:
            container.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            container.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[titleContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[fieldContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleContainer][fieldContainer]-|", options: [], metrics: nil, views: views))
        default: ()
        }
        
        super.updateConstraints()
    }
    
    open override func configure(_ row: FormRow) {
        setNeedsUpdateConstraints()
        
        container.layoutMargins = UIEdgeInsets()
        titleContainer.layoutMargins = UIEdgeInsets()
        fieldContainer.layoutMargins = UIEdgeInsets()
        
        titleLabel.text = row.title
        
        if let layoutAxis = row.form?.layoutAxis {
            titleLabel.font = UIFont.systemFont(ofSize: layoutAxis == .vertical ? 14 : 17)
            switch layoutAxis {
            case .horizontal:
                titleContainer.layoutMargins.right = row.title == nil ? 0 : 10
            case .vertical:
                titleContainer.layoutMargins.bottom = row.title == nil ? 0 : 5
            }
        }
    }
}

open class LabelFormCell: FormCell {
    open var label: UILabel!
    
    override open func setupUI() {
        super.setupUI()
        
        fieldContainer.layoutMargins.top = 10
        fieldContainer.layoutMargins.bottom = 10
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        fieldContainer.addSubview(label)
        
        let views: [String: Any] = [
            "label": label
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[label]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", options: [], metrics: nil, views: views))
    }
    
    open override func configure(_ row: FormRow) {
        super.configure(row)
        
        label.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        
        if let attributedString = row.value as? NSAttributedString {
            label.attributedText = attributedString
        } else {
            label.text = row.value as? String
        }
        
    }
}

open class MultiLineLabelFormCell: LabelFormCell {
    override open func setupUI() {
        super.setupUI()
        
        label.numberOfLines = 0
    }
}

open class SubtitleFormCell: FormCell {
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class TextFieldFormCell: FormCell, UITextFieldDelegate {
    open var textField = UITextField()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        textField.addTarget(self, action: #selector(TextFieldFormCell.textFieldValueChanged(_:)), for: .editingChanged)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        fieldContainer.addSubview(textField)
        
        let views: [String: Any] = [
            "textField": textField
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[textField]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        textField.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        textField.text = row.value as? String
        textField.placeholder = (row as? TextFieldFormRow)?.placeholder
    }
    
    func textFieldValueChanged(_ textField: UITextField) {
        row?.value = textField.text
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        (row as? TextFieldFormRow)?.textFieldDidEndEditing?()
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            textField.becomeFirstResponder()
        }
    }
}

open class EmailFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }
}

open class PasswordFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.isSecureTextEntry = true
    }
}

open class PhoneFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .phonePad
    }
}

open class DecimalFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .decimalPad
    }
}

open class CurrencyFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.keyboardType = .numberPad
    }
    
    override func textFieldValueChanged(_ textField: UITextField) {
        if let centString = textField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""), centString.isEmpty == false {
            let centValue = (centString as NSString).doubleValue
            let number = NSDecimalNumber(value: centValue/100.0 as Double)
            row?.value = number
        } else {
            row?.value = nil
        }
    }
    
    open override func configure(_ row: FormRow) {
        super.configure(row)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let number = row.value as? NSDecimalNumber
        textField.text = number != nil ? formatter.string(from: number!) : nil
    }
}

open class DatePickerFormCell: TextFieldFormCell {
    open let datePicker = UIDatePicker()
    open let dateLabel = UILabel()
    open let clearButton = UIButton()
    open var clearButtonWidthConstraint: NSLayoutConstraint!
    
    override open func setupUI() {
        super.setupUI()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        textField.inputView = datePicker
        textField.delegate = self
        textField.isHidden = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .right
        fieldContainer.addSubview(dateLabel)
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("✕", for: UIControlState())
        clearButton.setTitleColor(UIColor.lightGray, for: UIControlState())
        clearButton.addTarget(self, action: #selector(clearButtonTapped(_:)), for: .touchUpInside)
        clearButton.contentHorizontalAlignment = .right
        fieldContainer.addSubview(clearButton)
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))]
        
        let views: [String: Any] = [
            "textLabel": textLabel!,
            "dateLabel": dateLabel,
            "clearButton": clearButton,
            "textField": textField
        ]
        self.clearButtonWidthConstraint = NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        contentView.addConstraint(clearButtonWidthConstraint!)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[dateLabel][clearButton]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[clearButton]-|", options: [], metrics: nil, views: views))
    }
    
    func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        row?.value = datePicker.date
    }
    
    func datePickerValueChanged(_ datePicker: UIDatePicker) {
        row?.value = datePicker.date
    }
    
    func clearButtonTapped(_ sender: AnyObject) {
        row?.value = nil
        textField.resignFirstResponder()
    }
    
    open override func configure(_ row: FormRow) {
        super.configure(row)
        
        dateLabel.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        
        if let row = row as? DatePickerFormRow {
            datePicker.datePickerMode = row.datePickerMode
        }
        
        if let date = row.value as? Date {
            let formatter = (row as? DatePickerFormRow)?.formatter ?? DatePickerFormRow.defaultFormatter(datePicker.datePickerMode)
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        clearButtonWidthConstraint.constant = row.value != nil ? 25 : 0
        contentView.layoutIfNeeded()
    }
}

open class DropdownFormCell: TextFieldFormCell {
    open let picker = UIPickerView()
    open let label = UILabel()
    
    override open func setupUI() {
        super.setupUI()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        fieldContainer.addSubview(label)
        
        textField.inputView = picker
        textField.delegate = self
        textField.isHidden = true
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))]
        
        let views: [String: Any] = [
            "label": label
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[label]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", options: [], metrics: nil, views: views))
    }
    
    func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    open override func configure(_ row: FormRow) {
        super.configure(row)
        
        label.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        label.text = (row.value as? SelectableOption)?.selectableOptionTitle()
    }
}

open class SliderFormCell: FormCell {
    var slider = UISlider()
    
    override open func setupUI() {
        super.setupUI()
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(SliderFormCell.sliderChanged(_:)), for: .valueChanged)
        fieldContainer.addSubview(slider)
        
        let views: [String: Any] = [
            "slider": slider
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[slider]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[slider]-|", options: [], metrics: nil, views: views))
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        if let value = row.value as? Float {
            slider.value = value
        }
    }
    
    func sliderChanged(_ slider: UISlider) {
        row?.value = slider.value
    }
}

open class SwitchFormCell: FormCell {
    var switchControl = UISwitch()
    
    override open func setupUI() {
        super.setupUI()
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(SwitchFormCell.switched(_:)), for: .valueChanged)
        fieldContainer.addSubview(switchControl)
        
        let views: [String: Any] = [
            "textLabel": textLabel!,
            "switchControl": switchControl
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[switchControl]-|", options: [], metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: switchControl, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        if let value = row.value as? Bool {
            switchControl.isOn = value
        }
    }
    
    func switched(_ control: UISwitch) {
        row?.value = control.isOn
    }
}

open class SelectionFormCell: LabelFormCell {
    override open func setupUI() {
        super.setupUI()
        
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
        
        contentView.layoutMargins.right = 0
    }
    
    func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        row?.selection?(self)
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        if let option = row.value as? SelectableOption {
            label.text = option.selectableOptionTitle()
        }
    }
}

open class SelectableFormCell: FormCell {
    override open func setupUI() {
        super.setupUI()
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(SelectionFormCell.didSelect(_:)))]
    }
    
    func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        guard let selected = (row as? SelectableFormRow)?.selected else {
            return
        }
        (row as? SelectableFormRow)!.selected = !selected
        row?.selection?(self)
        if let row = row {
            configure(row)
        }
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        if let row = row as? SelectableFormRow {
            accessoryType = row.selected == true ? .checkmark : .none
        }
    }
}

open class MapFormPin: NSObject, MKAnnotation {
    open var coordinate: CLLocationCoordinate2D
    var color: UIColor
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.color = UIView().tintColor
        super.init()
    }
}

open class MapFormCell: FormCell, MKMapViewDelegate {
    var mapView: MKMapView!
    var mapInitialized = false
    
    override open func setupUI() {
        super.setupUI()
        
        mapView = MKMapView(frame: CGRect.zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectMap(_:))))
        fieldContainer.addSubview(mapView)
        
        let views: [String: Any] = [
            "mapView": mapView
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[mapView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[mapView]-|", options: [], metrics: nil, views: views))
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        layoutMargins = UIEdgeInsets()
        preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets()
        container.layoutMargins = UIEdgeInsets()
        fieldContainer.layoutMargins = UIEdgeInsets()
        
        var shouldAnimateRegionChange = false
        
        if let mapConfiguration = (row as? MapFormRow)?.mapConfiguration {
            mapView.mapType = mapConfiguration.mapType
            mapView.isZoomEnabled = mapConfiguration.zoomEnabled
            mapView.isScrollEnabled = mapConfiguration.scrollEnabled
            mapView.isPitchEnabled = mapConfiguration.pitchEnabled
            mapView.isRotateEnabled = mapConfiguration.rotateEnabled
            shouldAnimateRegionChange = !mapInitialized ? mapConfiguration.shouldAnimateInitially : mapConfiguration.shouldAnimateOnCoordinateChange
        }
        
        var coordinate: CLLocationCoordinate2D?
        
        if let location = row.value as? CLLocation {
            coordinate = location.coordinate
        } else if let locationCoordinate = row.value as? CLLocationCoordinate2D {
            coordinate = locationCoordinate
        }
        
        if let coordinate = coordinate, CLLocationCoordinate2DIsValid(coordinate) {
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
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        if let annotation = annotation as? MapFormPin {
            if #available(iOS 9.0, *) {
                annotationView?.pinTintColor = annotation.color
            } else {
                annotationView?.pinColor = .red
            }
        }
        annotationView?.annotation = annotation
        
        return annotationView
    }
    
    func didSelectMap(_ recognizer: UITapGestureRecognizer) {
        row?.selection?(self)
    }
}

// MARK: - FormViewController

open class FormViewController: UITableViewController {
    open var form = Form() {
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        form.tableView = tableView
        form.formViewController = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = form.title
        tableView.reloadData()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class SelectionFormViewController<T: SelectableOption>: FormViewController where T: Equatable {
    var selectionRow: SelectionFormRow<T>
    var selectedOptionIndexPath: IndexPath?
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
        for (sectionIndex, sectionTitle) in sectionTitles.enumerated() {
            var section = FormSection(title: sectionTitle)
            if let options = groupedOptions[sectionTitle] {
                for (rowIndex, option) in options.enumerated() {
                    section.rows.append(SelectableFormRow(title: option.selectableOptionTitle(), selected: self.selectionRow.selectedOption == option, cellSelection: { (cell) in
                        self.selectionRow.selectedOption = option
                        if self.allowsMultipleSelection == false {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }, valueChanged: nil))
                    if self.selectionRow.selectedOption == option {
                        self.selectedOptionIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    }
                }
            }
            form.sections.append(section)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { 
            self.tableView.selectRow(at: self.selectedOptionIndexPath, animated: false, scrollPosition: .middle)
        }
    }
}
