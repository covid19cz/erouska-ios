//
//  RiskyEncountersDetailVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersV2DetailVC: BaseTableViewController {

    private enum Row: Int, CaseIterable {
        case date
        case calibrationConfidence
        case diagnosisReportType
        case infectiousness
        case minimumAttenuation
        case typicalAttenuation
        case secondsSinceLastScan

        case maximumScore
        case scoreSum
        case weightedDurationSum
    }

    var exposure: ExposureWindow?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debug V2 Detail"
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
        case .calibrationConfidence:
            cell.textLabel?.text = "Calibration Confidence"
            cell.detailTextLabel?.text = "\(exposure.calibrationConfidence)"
        case .diagnosisReportType:
            cell.textLabel?.text = "Diagnosis Report Type"
            cell.detailTextLabel?.text = "\(exposure.diagnosisReportType)"
        case .infectiousness:
            cell.textLabel?.text = "Infectiousness"
            cell.detailTextLabel?.text = "\(exposure.infectiousness)"
        case .minimumAttenuation:
            cell.textLabel?.text = "Scan Minimum Attenuation"
            cell.detailTextLabel?.text = exposure.scanInstances.map { String($0.minimumAttenuation) }.joined(separator: ", ")
        case .typicalAttenuation:
            cell.textLabel?.text = "Scan Typical Attenuation"
            cell.detailTextLabel?.text = exposure.scanInstances.map { String($0.typicalAttenuation) }.joined(separator: ", ")
        case .secondsSinceLastScan:
            cell.textLabel?.text = "Seconds Since Last Scan"
            cell.detailTextLabel?.text = exposure.scanInstances.map { String($0.secondsSinceLastScan) }.joined(separator: ", ")
        case .maximumScore:
            cell.textLabel?.text = "Highest score of all exposures (at day)"
            cell.detailTextLabel?.text = "\(exposure.daySummary?.maximumScore ?? 0)"
        case .scoreSum:
            cell.textLabel?.text = "Sum of scores for all exposure (at day)"
            cell.detailTextLabel?.text = "\(exposure.daySummary?.scoreSum ?? 0)"
        case .weightedDurationSum:
            cell.textLabel?.text = "Sum of exposure durations weighted by their attenuation (at day)"
            cell.detailTextLabel?.text = "\(exposure.daySummary?.weightedDurationSum ?? 0)"
        }
        return cell
    }

}
