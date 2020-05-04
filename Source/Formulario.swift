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
    var tableStyle: UITableView.Style = .plain
    open var minimalRowHeight: CGFloat = 44.5
    open var layoutAxis: NSLayoutConstraint.Axis = .horizontal
    
    open var sections: [FormSection] {
        didSet {
            for section in sections {
                section.form = self
                for row in section.rows {
                    row.section = section
                    row.form = self
                }
            }
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
            tableView?.rowHeight = UITableView.automaticDimension
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
        TextViewFormCell.self,
        EmailFormCell.self,
        PasswordFormCell.self,
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

extension Form {
    public func scrollToRow(row: FormRow, at scrollPosition: UITableView.ScrollPosition = .none, animated: Bool = false) {
        guard let indexPath = row.indexPath else {
            return
        }
        tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    public func scrollToSection(section: FormSection, at scrollPosition: UITableView.ScrollPosition = .none, animated: Bool = false) {
        tableView?.scrollToRow(at: IndexPath(row: NSNotFound, section: section.index ?? NSNotFound), at: scrollPosition, animated: animated)
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

public class FormSection: NSObject {
    public var rows: [FormRow]
    public weak var form: Form?
    public var visibleRows: [FormRow] {
        return rows.filter({ $0.hidden == false })
    }
    public var title: String?
    var index: Int? {
        return form?.sections.firstIndex(of: self)
    }
    public init(title: String? = nil, rows: [FormRow] = []) {
        self.title = title
        self.rows = rows
        super.init()
    }
}

// MARK: - Rows

public typealias FormCellSelectionClosureType = ((Cell) -> Void)

open class FormRow: NSObject {
    open weak var form: Form?
    open var title: String?
    open weak var section: FormSection?
    open var value: Any? {
        didSet {
            cell?.configure(self)
            valueChanged?(self)
        }
    }
    open var cellHeight: CGFloat?
    open weak var cell: Cell?
    open var cellClass: Cell.Type
    open var selection: FormCellSelectionClosureType?
    open var valueChanged: ((FormRow)->Void)?
    
    fileprivate var oldIndexPath: IndexPath?
    var indexPath: IndexPath? {
        guard let section = section, let sectionIndex = form?.sections.firstIndex(of: section) else {
            return nil
        }
        guard let rowIndex = section.visibleRows.firstIndex(of: self) else {
            return nil
        }
        return IndexPath(row: rowIndex, section: sectionIndex)
        
    }
    
    public var hidden: Bool = false {
        willSet {
            oldIndexPath = indexPath
        }
        didSet {
            guard let tableView = self.form?.tableView else {
                return
            }
            
            if oldValue == false && hidden == true {
                if let oldIndexPath = oldIndexPath {
                    tableView.deleteRows(at: [oldIndexPath], with: .top)
                }
            } else if oldValue == true && hidden == false {
                if let indexPath = indexPath {
                    tableView.insertRows(at: [indexPath], with: .bottom)
                }
            }
        }
    }
    
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
    open var keyboardType: UIKeyboardType?
    open var numberFormatter: NumberFormatter?
    
    public init(title: String?, value: Any?, placeholder: String?, keyboardType: UIKeyboardType = .default, numberFormatter: NumberFormatter? = nil, cellClass: Cell.Type = TextFieldFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.textFieldDidEndEditing = textFieldDidEndEditing
        self.keyboardType = keyboardType
        self.numberFormatter = numberFormatter
        super.init(title: title, value: value, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

open class EmailFormRow: TextFieldFormRow {
    public init(title: String?, value: Any?, placeholder: String?, cellClass: Cell.Type = EmailFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, keyboardType: .emailAddress, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class PasswordFormRow: TextFieldFormRow {
    public init(title: String?, value: Any?, placeholder: String?, cellClass: Cell.Type = PasswordFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class PhoneFormRow: TextFieldFormRow {
    public init(title: String?, value: Any?, placeholder: String?, cellClass: Cell.Type = TextFieldFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, keyboardType: .phonePad, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class DecimalFormRow: TextFieldFormRow {
    public init(title: String?, value: Any?, placeholder: String?, cellClass: Cell.Type = TextFieldFormCell.self, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, keyboardType: .decimalPad, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class CurrencyFormRow: DecimalFormRow {
    public override init(title: String?, value: Any?, placeholder: String?, cellClass: Cell.Type = CurrencyFormCell.self,cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?, didEndEditing textFieldDidEndEditing: (() -> Void)? = nil) {
        super.init(title: title, value: value, placeholder: placeholder, cellClass: cellClass, cellSelection: cellSelection, valueChanged: valueChanged, didEndEditing: textFieldDidEndEditing)
    }
}

open class DatePickerFormRow: FormRow {
    open var datePickerMode: UIDatePicker.Mode
    open var formatter: DateFormatter?
    
    open class func defaultFormatter(_ datePickerMode: UIDatePicker.Mode) -> DateFormatter {
        let formatter = DateFormatter()
        var dateStyle: DateFormatter.Style = .none
        var timeStyle: DateFormatter.Style = .none
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
        @unknown default: ()
        }
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
    
    public init(title: String?, value: Date?, datePickerMode: UIDatePicker.Mode = .date, dateFormatter: DateFormatter? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
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
    public var requiresOption: Bool
    public var titleForNilOption: String?
    
    public init(title: String?, options: [T], selectedOption: T?, requiresOption: Bool = false, titleForNilOption: String? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.options = options
        self.requiresOption = requiresOption
        self.titleForNilOption = titleForNilOption
        super.init(title: title, value: selectedOption, cellClass: FormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
    }
}

open class SelectionFormRow<T: SelectableOption>: OptionsFormRow<T> where T: Equatable {
    var sectionTitles: [String]?
    var tableStyle: UITableView.Style
    
    public init(title: String?, options: [T], selectedOption: T?, sectionTitles: [String]? = nil, requiresOption: Bool = false, titleForNilOption: String? = nil, tableStyle: UITableView.Style = .plain, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.tableStyle = tableStyle
        super.init(title: title, options: options, selectedOption: selectedOption, requiresOption: requiresOption, titleForNilOption: titleForNilOption, cellSelection: nil, valueChanged: valueChanged)
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
            
            if let selectedOption = selectedOption, let selectedOptionIndex = options.firstIndex(of: selectedOption) {
                dropdownCell?.picker.selectRow(selectedOptionIndex, inComponent: 0, animated: false)
            }
        }
    }
    public override init(title: String?, options: [T], selectedOption: T?, requiresOption: Bool = false, titleForNilOption: String? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        super.init(title: title, options: options, selectedOption: selectedOption, requiresOption: requiresOption, titleForNilOption: titleForNilOption, cellSelection: cellSelection, valueChanged: valueChanged)
        self.cellClass = DropdownFormCell.self
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count + (requiresOption == false ? 1 : 0)
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if requiresOption == false && row == 0 {
            return titleForNilOption
        }
        return options[row + (requiresOption == false ? -1 : 0)].selectableOptionTitle()
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if requiresOption == false && row == 0 {
            selectedOption = nil
        } else {
            selectedOption = options[row + (requiresOption == false ? -1 : 0)]
        }
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
    public init(coordinate: CLLocationCoordinate2D?, cellHeight: CGFloat? = 80, mapConfiguration: MapConfiguration? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
        self.mapConfiguration = mapConfiguration ?? MapConfiguration()
        super.init(title: nil, value: coordinate, cellClass: MapFormCell.self, cellSelection: cellSelection, valueChanged: valueChanged)
        if let cellHeight = cellHeight {
            self.cellHeight = cellHeight
        }
    }
    public init(location: CLLocation?, cellHeight: CGFloat? = 80, mapConfiguration: MapConfiguration? = nil, cellSelection: FormCellSelectionClosureType?, valueChanged: ((FormRow) -> Void)?) {
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
    open var maximalHeightConstraint: NSLayoutConstraint!
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        maximalHeightConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
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
        
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: row.form?.minimalRowHeight ?? 44.5))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[container]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[container]-|", options: [], metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[titleLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: nil, views: views))
        
        switch row.form?.layoutAxis {
        case .horizontal?:
            container.setContentCompressionResistancePriority(.required, for: .vertical)
            container.setContentHuggingPriority(.defaultLow, for: .vertical)
            
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
            
            fieldContainer.setContentHuggingPriority(.defaultHigh, for: .vertical)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[titleContainer][fieldContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleContainer]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[fieldContainer]-|", options: [], metrics: nil, views: views))
        case .vertical?:
            container.setContentCompressionResistancePriority(.required, for: .vertical)
            container.setContentHuggingPriority(.defaultLow, for: .vertical)
            
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
        
        maximalHeightConstraint.constant = row.cellHeight ?? 0
        maximalHeightConstraint.isActive = !(row.cellHeight == nil)
        
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
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
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        fieldContainer.addSubview(label)
        
        let views = [
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
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class TextViewFormCell: FormCell, UITextViewDelegate {
    open var textView = UITextView()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        fieldContainer.addSubview(textView)
        
        let views: [String: Any] = [
            "textView": textView
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[textView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textView]-|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        row?.value = textView.text
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        textView.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        textView.text = row.value as? String
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            textView.becomeFirstResponder()
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        textView.text = nil
        textView.keyboardType = .default
    }
}

open class TextFieldFormCell: FormCell, UITextFieldDelegate {
    open var textField = UITextField()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let row = row as? TextFieldFormRow, let formatter = row.numberFormatter {
            let number = textField.text.map({ formatter.number(from: $0) }) ?? nil
            textField.text = number.map({ convertFormatter.string(from: $0) }) ?? nil
        }
    }
    
    @objc func textFieldValueChanged(_ textField: UITextField) {
        if (row as? TextFieldFormRow)?.numberFormatter == nil {
            row?.value = textField.text
        }
    }
    
    private let convertFormatter = NumberFormatter()
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        if let row = row as? TextFieldFormRow, let formatter = row.numberFormatter {
            convertFormatter.generatesDecimalNumbers = formatter.generatesDecimalNumbers
            row.value = textField.text.map({ convertFormatter.number(from: $0) }) ?? nil
        }
        (row as? TextFieldFormRow)?.textFieldDidEndEditing?()
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        textField.textAlignment = row.form?.layoutAxis == .horizontal ? .right : .left
        textField.text = row.value as? String
        
        if let row = row as? TextFieldFormRow {
            if let formatter = row.numberFormatter, let number = row.value as? NSNumber {
                textField.text = formatter.string(from: number)
            }
            textField.placeholder = row.placeholder
            row.keyboardType.map({ textField.keyboardType = $0 })
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            textField.becomeFirstResponder()
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.text = nil
        textField.keyboardType = .default
    }
}

open class EmailFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        if #available(iOS 11.0, *) {
            textField.autocorrectionType = .default
            textField.textContentType = .username
        }
    }
}

open class PasswordFormCell: TextFieldFormCell {
    override open func setupUI() {
        super.setupUI()
        
        textField.isSecureTextEntry = true
        if #available(iOS 11.0, *) {
            textField.textContentType = .password
        }
    }
}

open class CurrencyFormCell: TextFieldFormCell {
    let formatter = NumberFormatter()
    
    override open func setupUI() {
        super.setupUI()
        formatter.numberStyle = .currency
    }
    
    override func textFieldValueChanged(_ textField: UITextField) {
        
    }
    
    public override func textFieldDidBeginEditing(_ textField: UITextField) {
        let number = row?.value as? NSNumber
        textField.text = number?.stringValue
    }
    
    open override func textFieldDidEndEditing(_ textField: UITextField) {
        let number = NSDecimalNumber(string: textField.text)
        row?.value = number == NSDecimalNumber.notANumber ? nil : number
        super.textFieldDidEndEditing(textField)
    }
    
    open override func configure(_ row: FormRow) {
        super.configure(row)
        
        let number = row.value as? NSDecimalNumber
        textField.text = number.map({ formatter.string(from: $0) }) ?? nil
    }
}

open class DatePickerFormCell: TextFieldFormCell {
    public let datePicker = UIDatePicker()
    public let dateLabel = UILabel()
    public let clearButton = UIButton()
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
        clearButton.setTitle("✕", for: .init())
        clearButton.setTitleColor(UIColor.lightGray, for: .init())
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
    
    @objc func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    open override func textFieldDidBeginEditing(_ textField: UITextField) {
        row?.value = datePicker.date
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        row?.value = datePicker.date
    }
    
    @objc func clearButtonTapped(_ sender: AnyObject) {
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
    public let picker = UIPickerView()
    public let label = UILabel()
    
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
    
    @objc func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    open override func textFieldDidBeginEditing(_ textField: UITextField) {
        
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
    
    @objc func sliderChanged(_ slider: UISlider) {
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
    
    @objc func switched(_ control: UISwitch) {
        row?.value = control.isOn
    }
}

open class SelectionFormCell: LabelFormCell {
    override open func setupUI() {
        super.setupUI()
        
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        
//        contentView.layoutMargins.right = 0
    }
    
    override open func configure(_ row: FormRow) {
        super.configure(row)
        
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        
        if let option = row.value as? SelectableOption {
            label.text = option.selectableOptionTitle()
        }
    }
}

open class SelectableFormCell: FormCell {
    override open func setupUI() {
        super.setupUI()
        
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))]
    }
    
    @objc func didSelect(_ gestureRecognizer: UIGestureRecognizer) {
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
            titleLabel.minimumScaleFactor = 0.7
            titleLabel.adjustsFontSizeToFitWidth = true
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
        
        let views = [
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
    
    @objc func didSelectMap(_ recognizer: UITapGestureRecognizer) {
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
    
    public override init(style: UITableView.Style) {
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
            let section = FormSection(title: sectionTitle)
            
            if selectionRow.requiresOption == false && sectionIndex == 0 {
                let nilRow = SelectableFormRow(title: selectionRow.titleForNilOption, selected: self.selectionRow.selectedOption == nil, cellSelection: { [weak self] (cell) in
                    self?.didSelect(option: nil)
                }, valueChanged: nil)
                if sectionTitles.count > 1 {
                    form.sections.append(FormSection(title: nil, rows: [nilRow]))
                } else {
                    section.rows.append(nilRow)
                }
            }
            
            if let options = groupedOptions[sectionTitle] {
                for (rowIndex, option) in options.enumerated() {
                    section.rows.append(SelectableFormRow(title: option.selectableOptionTitle(), selected: self.selectionRow.selectedOption == option, cellSelection: { [weak self] (cell) in
                        self?.didSelect(option: option)
                    }, valueChanged: nil))
                    if self.selectionRow.selectedOption == option {
                        self.selectedOptionIndexPath = IndexPath(row: rowIndex, section: form.sections.count)
                    }
                }
            }
            form.sections.append(section)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = selectionRow.title
        
        DispatchQueue.main.async { 
            self.tableView.selectRow(at: self.selectedOptionIndexPath, animated: false, scrollPosition: .middle)
        }
    }
    
    func didSelect(option: T?) {
        self.selectionRow.selectedOption = option
        if self.allowsMultipleSelection == false {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
