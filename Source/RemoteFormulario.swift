//
//  RemoteFormulario.swift
//  Formulario
//
//  Created by Andreas Alfarè on 29.04.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

public class RemoteForm: Form {
    var formUrl: String {
        didSet {
            parameters.removeAll()
        }
    }
    var title: String?
    var responseUrl: String?
    var action: String?
    var parameters = [String: AnyObject]()
    
    public init(formUrl: String) {
        self.formUrl = formUrl
        super.init(sections: [])
    }
    
    func loadForm() {
        guard let url = NSURL(string: formUrl) else {
            return
        }
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(url) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else {
                    return
                }
                self.title = json["title"] as? String
                self.responseUrl = json["responseUrl"] as? String
                self.action = json["action"] as? String
                
                guard let jsonSections = json["sections"] as? Array<[String: AnyObject]> else {
                    return
                }
                var sections = [FormSection]()
                for section in jsonSections {
                    var rows = [FormRow]()
                    if let jsonRows = section["rows"] as? Array<[String: AnyObject]> {
                        for row in jsonRows {
                            let name = row["name"] as? String
                            var value = row["value"] as? String
                            if let name = name, let oldValue = self.parameters[name] as? String {
                                value = oldValue
                            }
                            rows.append(TextFieldFormRow(title: row["label"] as? String, value: value, placeholder: row["placeholder"] as? String, cellSelection: nil, valueChanged: { r in
                                if let name = name {
                                    self.parameters[name] = r.value as? AnyObject
                                }
                            }))
                        }
                    }
                    sections.append(Formulario.FormSection(title: section["title"] as? String, rows: rows))
                }
                self.sections = sections
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView?.reloadData()
                    self.formViewController?.title = self.title
                })
                
            } catch {
                
            }
        }.resume()
    }
    
    public func submit() {
        guard let responseUrl = responseUrl else {
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: responseUrl)!)
        request.HTTPMethod = action ?? "GET"
        
        print(parameters)
        
        var paramString = ""
        for (key, value) in parameters {
            let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            paramString += "\(escapedKey)=\(escapedValue)&"
        }
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithRequest(request) { (data, response, error) in
            
        }.resume()
    }
}

public class RemoteFormViewController: FormViewController {
    public var remoteForm: RemoteForm? {
        get {
            return form as? RemoteForm
        }
        set {
            if let newValue = newValue{
                form = newValue
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = remoteForm?.title
        remoteForm?.loadForm()
    }
}
