//
//  ChartController.swift
//  Snore
//
//  Created by Dmitry Talisman on 11/15/15.
//  Copyright © 2015 Dmitry Talisman. All rights reserved.
//

import Foundation
import Charts
import UIKit


class ChartViewController : UIViewController {
    
    @IBOutlet weak var chartView: LineChartView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        chartView.noDataText = "Empty?"
        chartView.descriptionText = "Description"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}