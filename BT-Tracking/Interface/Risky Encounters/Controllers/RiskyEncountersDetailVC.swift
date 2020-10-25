//
//  RiskyEncountersDetailVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersDetailVC: UITableViewController {

    private enum Row: Int, CaseIterable {
        case date
        case duration
        case totlaRiskScore
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

        title = "Detail"
    }

    // MARK: - UITableViewDetaSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell()
        cell.detailTextLabel?.numberOfLines = 0

        guard let exposure = exposure else { return cell }

        switch Row(rawValue: indexPath.row) {
        case .date:
            cell.textLabel?.text = "Date"
            cell.detailTextLabel?.text = DateFormatter.baseDateFormatter.string(from: exposure.date)
        case .duration:
            cell.textLabel?.text = "Duration"
            cell.detailTextLabel?.text = "\(exposure.duration)"
        case .totlaRiskScore:
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
        default:
            break
        }
        return cell
    }

}
