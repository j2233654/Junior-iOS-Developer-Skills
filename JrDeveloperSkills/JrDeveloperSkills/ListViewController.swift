//
//  ViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/4/17.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let sectionTitles = ["Local Functions", "External Functions"]
    let rowTitles = [ ["QRCode/BarCode Scanner","Multilingual","Push Notification","BLE", "AV Foundation"],
                            ["Parse JSON/XML", "Google Drive", "Google Sheet"] ]
    let signInBtn = GIDSignInButton()
    
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var signInView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "🛠 Junior Skills"
        setUpSignInBtn()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setUpSignInBtn(){
        signInView.layer.cornerRadius = 5
        signInBtn.style = .wide
        signInView.addSubview(signInBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = rowTitles[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            if indexPath.row == 0{
                performSegue(withIdentifier: "qrCode", sender: self)
            }
            if indexPath.row == 2{
                let storyboard = UIStoryboard(name: "PushNotification", bundle: nil)
                if let notifyVC = storyboard.instantiateViewController(withIdentifier: "notify") as? NotifyViewController{
                    self.show(notifyVC, sender: self)
                }
            }
        }

    }
    
}

