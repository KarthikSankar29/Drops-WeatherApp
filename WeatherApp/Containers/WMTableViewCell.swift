//
//  WMTableViewCell.swift
//  WeatherApp
//
//  Created by karthik_sa on 10/23/16.
//  Copyright © 2016 KarthikSankar. All rights reserved.
//

import UIKit

class WMTableViewCell: UITableViewCell {

  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var lowerTempLabel: UILabel!
  @IBOutlet weak var upperTempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var weatherDescription: UILabel!
  @IBOutlet weak var todayMarker: UIView!
  @IBOutlet weak var weatherTemp: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
