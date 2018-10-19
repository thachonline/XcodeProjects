//
//  AboutController.swift
//  Settings
//
//  Created by Bondar Yaroslav on 18/10/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class AboutController: UIViewController, BackButtonActions {
    
    private enum RawType {
        case feedback
        case privacyPolicy
        case rateApp
        case appStorePage
        case developerPage
    }
    
    private let raws: [RawType] = [.feedback, .privacyPolicy, .rateApp, .appStorePage, .developerPage]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        title = "About".localized
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeBackButtonTitle()
        
        view.addSubview(tableView)
        
        /// need for iOS 10, don't need for iOS 11
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /// need for iOS 11(maybe others too. iOS 10 don't need) split controller, opened in landscape with large text accessibility
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    private func sendFeedback() {
        EmailSender.shared.send(message: "",
                                subject: "Settings feedback",
                                to: [EmailSender.devEmail],
                                presentIn: self)
    }
}

extension AboutController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raws.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
//    }
}

extension AboutController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let raw = raws[indexPath.row]
//
        switch raw {
        case .feedback:
            cell.accessoryType = .none
            cell.textLabel?.text = "Send feedback"
        case .privacyPolicy:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Privacy Policy"
        case .rateApp:
            cell.accessoryType = .none
            cell.textLabel?.text = "Rate Us"
        case .appStorePage:
            cell.accessoryType = .none
            cell.textLabel?.text = "Open in App Store"
        case .developerPage:
            cell.accessoryType = .none
            cell.textLabel?.text = "More apps from me"
        }
        
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        /// need only for iOS 9 and 10. don't need for iOS 11
        cell.textLabel?.numberOfLines = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let raw = raws[indexPath.row]

        switch raw {
        case .feedback:
            sendFeedback()
        case .privacyPolicy:
            let vc = PrivacyPolicyController()
            navigationController?.pushViewController(vc, animated: true)
        case .rateApp:
            RateAppManager.googleApp.rateInAppOrRedirectToStore()
        case .appStorePage:
            RateAppManager.googleApp.openAppStorePage()
        case .developerPage:
            RateAppManager.googleApp.openDeveloperAppStorePage(devId: "id281956209")
        }
    }
}
