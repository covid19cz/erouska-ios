//
//  RiskyEncountersDetailVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersV1DetailVC: BaseTableViewController {

    private enum Row: Int, CaseIterable {
        case date
        case duration
        case totalRiskScore
        case transmissionRiskLevel
        case attenuationValue
        case attenuationDurations
        case computedThreshold
    }

    private let configuration = RemoteValues.exposureConfiguration

    var exposure: Exposure?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debug V1 Detail"
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell()
        cell.detailTextLabel?.numberOfLines = 0

        guard let exposure = exposure, let row = Row(rawValue: indexPath.row) else { return cell }

        switch row {
        case .date:
            cell.textLabel?.text = "Date"
            cell.detailTextLabel?.text = DateFormatter.baseDateFormatter.string(from: exposure.date)
        case .duration:
            cell.textLabel?.text = "Duration"
            cell.detailTextLabel?.text = "\(exposure.duration)"
        case .totalRiskScore:
            cell.textLabel?.text = "Total Risk Score"
            cell.detailTextLabel?.text = "\(exposure.totalRiskScore)"
        case .transmissionRiskLevel:
            cell.textLabel?.text = "Transmission Risk Level"
            cell.detailTextLabel?.text = "\(exposure.transmissionRiskLevel)"
        case .attenuationValue:
            cell.textLabel?.text = "Attenuation Value"
            cell.detailTextLabel?.text = "\(exposure.attenuationValue)"
        case .attenuationDurations:
            cell.textLabel?.text = "Attenuation Durations"
            cell.detailTextLabel?.text = exposure.attenuationDurations.map { "\($0)" }.joined(separator: ", ")
        case .computedThreshold:
            cell.textLabel?.text = "Computed Threshold"
            cell.detailTextLabel?.text = "\(exposure.computedThreshold(with: configuration))"
        }
        return cell
    }

}
