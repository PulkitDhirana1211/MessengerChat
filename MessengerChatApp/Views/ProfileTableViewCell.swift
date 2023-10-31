//
//  ProfileTableViewCell.swift
//  MessengerChatApp
//
//  Created by Pulkit Dhirana on 31/10/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    
    public func setup(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title

        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }

}
