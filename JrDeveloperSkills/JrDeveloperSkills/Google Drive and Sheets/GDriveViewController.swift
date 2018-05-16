//
//  GDriveViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/5/16.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class GDriveViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private let drive = GTLRDriveService()
    var objects = [GTLRDrive_File]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        setupGDrive()
    }

    func setupGDrive(){
        // Check whether login.
        let signin = GIDSignIn.sharedInstance()
        guard let auth = signin?.currentUser?.authentication.fetcherAuthorizer() else{
            showAlert(title: "Log In!", message: "You should log in to connect the Google Drive")
            return
        }
        drive.authorizer = auth
        guard let canAuthorize = drive.authorizer?.canAuthorize else {
            showAlert(title: "Log In!", message: "You should log in to connect the Google Drive")
            return
        }
        if canAuthorize == false {
            showAlert(title: "Log In!", message: "You should log in to connect the Google Drive")
        }else{
            downloadFileList()
        }
    }
    
    
    func downloadFileList(){
        // Download File List.
        drive.shouldFetchNextPages = true
        let query = GTLRDriveQuery_FilesList.query()
        drive.executeQuery(query) { (ticket, result, error) in
            if let error = error{
                print("Download File List Error: \(error)")
                return
            }
            guard let files = (result as? GTLRDrive_FileList)?.files else{
                assertionFailure("Invalid result of File List.")
                return
            }
            let sheetFiles = files.filter({$0.mimeType == "application/vnd.google-apps.spreadsheet" })
            self.objects = sheetFiles
            self.tableView.reloadData() //GDrive此方法在main thread，故可直接更新UI
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){_ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let file = objects[indexPath.row]
        cell.textLabel!.text = file.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let identifier = objects[indexPath.row].identifier else{
                assertionFailure("Invalid identifier")
                return
            }
            let query = GTLRDriveQuery_FilesDelete.query(withFileId: identifier)
            drive.executeQuery(query) { (ticker, file, error) in
                if let error = error {
                    print("Delete file error: \(error)")
                    return
                }
                print("Delete OK.")
                self.downloadFileList()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
