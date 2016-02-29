//
//  Formulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

public class Form: NSObject {
    public var sections = [FormSection]() {
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
            
            for cellClass in Form.registeredCellClasses {
                tableView?.registerClass(cellClass, forCellReuseIdentifier: cellClass.cellIdentifier())
                print(cellClass.cellIdentifier())
            }
        }
    }
    private static var registeredCellClasses = [
        FormCell.self,
        TextFieldFormCell.self,
        SliderFormCell.self
    ]
    
    public class func registerCellClass(cellClass: FormCell.Type) {
        registeredCellClasses.append(cellClass)
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

public class FormCell: UITableViewCell {
    public var row: FormRow?
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func cellIdentifier() -> String {
        return String.fromCString(class_getName(self)) ?? "FormCell"
    }
    
    public func configure(row: FormRow) {
        self.row = row
        self.textLabel?.text = row.title
        self.detailTextLabel?.text = row.value as? String
    }
}

public class TextFieldFormCell: FormCell, UITextFieldDelegate {
    var textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        textField.addTarget(self, action: "textFieldValueChanged:", forControlEvents: .EditingChanged)
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

public class SliderFormCell: FormCell {
    var slider = UISlider()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: "sliderChanged:", forControlEvents: .ValueChanged)
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

public class FormViewController: UIViewController {
    public var form = Form() {
        willSet {
            form.tableView = nil
        }
        didSet {
            form.tableView = tableView
        }
    }
    var tableView: UITableView!
    
    // MARK: - Initialization
    
    public init(style: UITableViewStyle) {
        tableView = UITableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        form.tableView = tableView
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        tableView = UITableView(frame: .zero, style: .Plain)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        form.tableView = tableView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: .zero, style: .Plain)
        super.init(coder: aDecoder)
        form.tableView = tableView
    }
    
    convenience public init() {
        self.init(style: .Plain)
    }
    
    override public func loadView() {
        view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        form.tableView = tableView
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
