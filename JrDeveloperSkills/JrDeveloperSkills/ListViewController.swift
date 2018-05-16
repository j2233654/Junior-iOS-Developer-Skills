//
//  ViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/4/17.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import SDWebImage
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInUIDelegate, GIDSignInDelegate{
    
    let sectionTitles = ["Local Functions", "External Functions"]
    let rowTitles = [ ["QRCode / BarCode Scanner","Multilingual","Push Notification","BLE", "AV Foundation"],
                            ["Parse JSON/XML", "Google Drive", "Google Sheet"] ]

    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly, kGTLRAuthScopeDriveReadonly]
    private let service = GTLRSheetsService()
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var signInBtn : GIDSignInButton!
    @IBOutlet weak var userImageView : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var logOutBtn : UIButton!
    @IBOutlet weak var testLabel : UILabel!

    //MARK: - Settings and Btn.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "🛠 Junior Skills"
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpAccount()
    }
    
    func setUpAccount(){
    // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        signInBtn.style = .wide
        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            GIDSignIn.sharedInstance().signIn()
            signInBtn.isHidden = true
        }else{
            userImageView.isHidden = true
            nameLabel.isHidden = true
            logOutBtn.isHidden = true
        }
    }
    
    @IBAction func logOutBtnPressed(sender: UIButton){
        let alert = UIAlertController(title: "Log Out", message: "You will log out from Google.", preferredStyle: UIAlertControllerStyle.alert)
    //Log out.
        let logOut = UIAlertAction(title: "LogOut", style: .destructive){_ in
            GIDSignIn.sharedInstance().signOut()
            self.signInBtn.isHidden = false
            self.userImageView.isHidden = true
            self.nameLabel.isHidden = true
            sender.isHidden = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(logOut)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource / Delegate
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
        //QRCode / BarCode Scanner.
            if indexPath.row == 0{
                performSegue(withIdentifier: "qrCode", sender: self)
            }
        //Push Notification.
            if indexPath.row == 2{
                let storyboard = UIStoryboard(name: "PushNotification", bundle: nil)
                if let notifyVC = storyboard.instantiateViewController(withIdentifier: "notify") as? NotifyViewController{
                    self.show(notifyVC, sender: self)
                }
            }
        }
        if indexPath.section == 1{
        //Google Drive
            if indexPath.row == 1{
                let storyboard = UIStoryboard(name: "GDrive", bundle: nil)
                if let GDriveVC = storyboard.instantiateViewController(withIdentifier: "GDrive") as? GDriveViewController{
                    self.show(GDriveVC, sender: self)
                }
            }
        }
    }
    
    //MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        }else{
        //Show profile after login.
            nameLabel.text = user.profile.name
            if let imageURL = user.profile.imageURL(withDimension: 44){
                userImageView.sd_setImage(with: imageURL, completed: nil)
            }
            signInBtn.isHidden = true
            userImageView.isHidden = false
            nameLabel.isHidden = false
            logOutBtn.isHidden = false
        //Get service authorizer.
            self.service.authorizer = user.authentication.fetcherAuthorizer()
//            listMajors()
        }
    }
    
//MARK: - Testing Code for query Google Sheet
    func listMajors() {
        let spreadsheetId = "1nIiw4D7CTxb_sKjYqssrk6GLP4-s_DEeVXqPhi6N7mM"
    //Query the first colume.
        let range = "A1:Z1"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else{
                return
            }
        //Query the first colume.
            let row = result.values!.first!
            var majorsString = ""
            if row.isEmpty {
                self.testLabel.text = "No data found."
                return
            }
            for i in 0..<row.count {
                majorsString += "\(row[i]), "
            }
            self.testLabel.text = majorsString
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}

