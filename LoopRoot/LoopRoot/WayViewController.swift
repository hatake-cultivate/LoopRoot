//
//  WayViewController.swift
//  LoopRoot
//
//  Created by Takeuchi Haruki on 2016/02/25.
//  Copyright © 2016年 Takeuchi Haruki. All rights reserved.
//

import UIKit

//地図のルートの検索結果を表示する予定
class WayViewController: UIViewController {

    var text1: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myLabel = UILabel(frame: CGRectMake(0,0,300,100))
        myLabel.layer.position = CGPoint(x: 155,y: 115)
        
        // テキスト
        myLabel.text = text1
        
        myLabel.numberOfLines = 0
        myLabel.sizeToFit()
        
        self.view.addSubview(myLabel)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
