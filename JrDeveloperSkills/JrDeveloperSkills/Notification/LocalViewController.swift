//
//  LocalViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/5/23.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class LocalViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var switchLabel : UILabel!
    @IBOutlet weak var locationLabel : UILabel!
    var trackCount = 0
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Ask user's permission to show notification.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.badge,.sound]) { (grant, error) in
            print("User grant the permission: " + (grant ? "OK" : "NG"))
        }
        //Ask user's permission to updating location.
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
    }
    
    @IBAction func trackingSwitchPressed(sender:UISwitch){
        if sender.isOn{
            switchLabel.text = "Turn off tracking."
            trackCount = 0
            locationManager.startUpdatingHeading()
        }else{
            locationManager.stopUpdatingHeading()
            locationLabel.text = "Tracking had been stopped."
            switchLabel.text = "Turn on to track heading."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        trackCount += 1
        let x = newHeading.x
        let y = newHeading.y
        locationLabel.text = "headX: \(x), headY: \(y)    Times = \(trackCount)"
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
