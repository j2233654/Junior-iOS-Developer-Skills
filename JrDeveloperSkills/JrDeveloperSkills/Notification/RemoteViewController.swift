//
//  RemoteViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/5/23.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit
import FirebaseMessaging

class RemoteViewController: UIViewController, MessagingDelegate {
    
    @IBOutlet weak var messageLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        Messaging.messaging().delegate = self
        messageLabel.text = "Notification Counts : \(AppDelegate.notifyCount)"
        //Renew UI while back to app.
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive , object: nil, queue: .main) { [weak self] _ in
            if let weakSelf = self{
                weakSelf.messageLabel.text = "Notification Counts : \(AppDelegate.notifyCount)"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController{
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
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
