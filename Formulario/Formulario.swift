//
//  Formulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 26.02.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

class Form: NSObject {
    var sections: [FormSection]? {
        didSet {
            tableView?.reloadData()
        }
    }
    var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.registerClass(FormCell.self, forCellReuseIdentifier: FormCell.cellIdentifier())
            tableView?.registerClass(TextFieldFormCell.self, forCellReuseIdentifier: TextFieldFormCell.cellIdentifier())
        }
    }
}

extension Form: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = sections![indexPath.section].rows[indexPath.row]
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FormCell {
            row.selection?(cell)
        }
    }
}

extension Form: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections![section].rows.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = sections![indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.cellClass.cellIdentifier(), forIndexPath: indexPath) as! FormCell
        cell.configure(row)
        return cell
    }
}

struct FormSection {
    var rows: [FormRow]
    init(rows: [FormRow] = []) {
        self.rows = rows
    }
}



class FormRow: NSObject {
    var title: String?
    dynamic var value: AnyObject?
    var cellClass: FormCell.Type
    var selection: ((FormCell)->Void)?
    var valueChanged: ((FormRow)->Void)?
    
    init(title: String?, value: AnyObject?, cellClass: FormCell.Type? = nil, cellSelection: ((FormCell) -> Void)? = nil, valueChanged: ((FormRow)->Void)? = nil) {
        self.title = title
        self.value = value
        self.cellClass = cellClass ?? FormCell.self
        self.selection = cellSelection
        self.valueChanged = valueChanged
        super.init()
        self.addObserver(self, forKeyPath: "value", options: .New, context: nil)
    }
    deinit {
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "value" {
            valueChanged?(self)
        }
    }
}

class FormCell: UITableViewCell {
    var row: FormRow?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func cellIdentifier() -> String {
        return "FormCell"
    }
    func configure(row: FormRow) {
        self.row = row
        self.textLabel?.text = row.title
        self.detailTextLabel?.text = row.value as? String
    }
}

class TextFieldFormCell: FormCell, UITextFieldDelegate {
    var textField = UITextField()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        textField.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        textField.frame = contentView.frame
        textField.addTarget(self, action: "textFieldValueChanged:", forControlEvents: .EditingChanged)
        contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func cellIdentifier() -> String {
        return "TextFieldFormCell"
    }
    
    override func configure(row: FormRow) {
        self.row = row
        textField.text = row.value as? String
    }
    
    func textFieldValueChanged(textField: UITextField) {
        row?.value = textField.text
    }
}

class FormViewController: UIViewController {
    var form = Form() {
        willSet {
            form.tableView = nil
        }
        didSet {
            form.tableView = tableView
        }
    }
    var tableView: UITableView!
    
    // MARK: - Initialization
    
    init(style: UITableViewStyle) {
        tableView = UITableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        form.tableView = tableView
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        tableView = UITableView(frame: .zero, style: .Plain)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        form.tableView = tableView
    }
    
    required init?(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: .zero, style: .Plain)
        super.init(coder: aDecoder)
        form.tableView = tableView
    }
    
    convenience init() {
        self.init(style: .Plain)
    }
    override func loadView() {
        view = tableView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        form.tableView = tableView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



//
//
//class FormField: NSObject {
//    var label: String?
//    dynamic var data: AnyObject?
//    var cellClass: AnyClass?
//    var action: ((FormFieldCVCell)->())?
//    var automaticallyBecomeFirstResponder = false
//    convenience init(label: String) {
//        self.init()
//        self.label = label
//    }
//}
//
//@objc protocol MultiSelectionObject {
//    var titleMultiSelection: String? { get }
//}
//
//class MultiSelectionFormField: FormField {
//    dynamic var items: [MultiSelectionObject]?
//    dynamic var selectedItem: MultiSelectionObject?
//    var titleInMultiSelectionList: String?
//    override init() {
//        super.init()
//        cellClass = MultiSelectionFormFieldCVCell.self
//    }
//}
//
//class ZIPandCityFormField: FormField {
//    var cityLabel: String?
//    var zip: String?
//    dynamic var geoItems: [GeoItem]?
//    dynamic var selectedGeoItem: GeoItem?
//    var cityTappedHandler: ((ZIPCodeCityFormFieldCVCell)->())?
//    override init() {
//        super.init()
//        cellClass = ZIPCodeCityFormFieldCVCell.self
//        label = NSLocalizedString("Postleitzahl", comment: "")
//        cityLabel = NSLocalizedString("Ort", comment: "")
//    }
//}
//
//class SegmentedFormField: FormField {
//    var cityLabel: String?
//    var items: [String]?
//    var initialSelectedIndex: Int?
//    override init() {
//        super.init()
//        cellClass = SegmentedFormFieldCell.self
//    }
//    convenience init(label: String, items: [String]) {
//        self.init()
//        self.label = label
//        self.items = items
//    }
//}
//
//class KilowattHourPickerFormField: FormField {
//    var usage: Int {
//        get {
//            if let data = data as? Int {
//                return data
//            }
//            return 0
//        }
//        set {
//            data = newValue
//        }
//    }
//    override init() {
//        super.init()
//        cellClass = KilowattHourPickerFormFieldCVCell.self
//    }
//}
//
//protocol FormFieldCell {
//    static func cellReuseIdentifier() -> String
//}
//
//class FormFieldBaseCVCell: UICollectionViewCell, FormFieldCell {
//    class func cellReuseIdentifier() -> String {
//        return "FormFieldBaseCVCell"
//    }
//}
//
//
//
//class FormViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    var form: Form?
//    lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 16.0, left: 10, bottom: 16.0, right: 10)
//        layout.minimumLineSpacing = 15
//        let c = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
//        c.backgroundColor = UIColor.lightBackgroundColor()
//        c.translatesAutoresizingMaskIntoConstraints = false
//        return c
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        collectionView.registerClass(FormFieldCVCell.self, forCellWithReuseIdentifier: FormFieldCVCell.reuseIdentifier())
//        collectionView.registerClass(ZIPCodeCityFormFieldCVCell.self, forCellWithReuseIdentifier: ZIPCodeCityFormFieldCVCell.reuseIdentifier())
//        collectionView.registerClass(SegmentedFormFieldCell.self, forCellWithReuseIdentifier: SegmentedFormFieldCell.reuseIdentifier())
//        collectionView.registerClass(KilowattHourPickerFormFieldCVCell.self, forCellWithReuseIdentifier: KilowattHourPickerFormFieldCVCell.reuseIdentifier())
//        collectionView.registerClass(MultiSelectionFormFieldCVCell.self, forCellWithReuseIdentifier: MultiSelectionFormFieldCVCell.reuseIdentifier())
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        view.addSubview(collectionView)
//        
//        let views: [String: AnyObject] = [
//            "topLayoutGuide": topLayoutGuide,
//            "collectionView": collectionView]
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][collectionView]|", options: [], metrics: nil, views: views))
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    // MARK: - collection view delegate and datasource methods
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let fields = form?.fields {
//            return fields.count
//        }
//        return 0
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        if let field = form?.fields[indexPath.row] {
//            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(field.cellClass!.reuseIdentifier(), forIndexPath: indexPath) as! FormFieldCVCell
//            cell.field = field
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if let field = form?.fields[indexPath.row] {
//            if let field = field as? MultiSelectionFormField {
//                if field.action == nil && field.items != nil {
//                    let multiSelectionController = MultiSelectionItemsViewController(items: field.items!, tableHeaderTitle: field.titleInMultiSelectionList, selectionHandler: { (selectedItem, controller) -> () in
//                        field.selectedItem = selectedItem
//                        controller.navigationController?.popViewControllerAnimated(true)
//                    })
//                    navigationController?.pushViewController(multiSelectionController, animated: true)
//                }
//            } else if let field = field as? KilowattHourPickerFormField {
//                let kWhPicker = KilowattPickerController()
//                kWhPicker.usage = field.usage
//                kWhPicker.selectionHandler = { (selectedNumber) in
//                    field.usage = selectedNumber
//                }
//                kWhPicker.modalPresentationStyle = .OverCurrentContext
//                presentViewController(kWhPicker, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        var height: CGFloat = 74
//        if let field = form?.fields[indexPath.row] {
//            if field.isMemberOfClass(ZIPandCityFormField.self) {
//                
//            } else if field.isMemberOfClass(SegmentedFormField.self) {
//                height += 12
//            } else if field.isMemberOfClass(KilowattHourPickerFormField.self) {
//                
//            }
//            
//            if field.label == nil {
//                height -= 24
//            }
//        }
//        return CGSize(width: collectionView.bounds.width-layout.sectionInset.left-layout.sectionInset.right, height: height)
//    }
//}
