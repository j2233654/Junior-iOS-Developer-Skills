//
//  RemoteViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/5/23.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit

class RemoteViewController: UIViewController {
    
    @IBOutlet weak var messageLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "Number of Firebase Messages : \(AppDelegate.notifyCount)"
        //Renew UI while back to app.
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive , object: nil, queue: .main) { [weak self] _ in
            if let weakSelf = self{
                weakSelf.messageLabel.text = "Number of Firebase Messages : \(AppDelegate.notifyCount)"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController{
            NotificationCenter.default.removeObserver(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
