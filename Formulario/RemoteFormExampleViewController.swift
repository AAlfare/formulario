//
//  RemoteFormExampleViewController.swift
//  Formulario
//
//  Created by Andreas Alfarè on 29.04.16.
//  Copyright © 2016 alfare.it. All rights reserved.
//

import UIKit

class RemoteFormExampleViewController: RemoteFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteForm = RemoteForm(formUrl: "https://gist.githubusercontent.com/AAlfare/855be7aac70506854ee9b860f14fce18/raw/bfb8c00e23f664f9a704ce143365b33c37624566/remoteForm.json")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(sendForm(_:)))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    func sendForm(sender: AnyObject) {
        remoteForm?.submit()
    }
}
