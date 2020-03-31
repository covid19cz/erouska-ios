//
//  ActiveAppViewModel.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 25/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ActiveAppViewModel {

    enum State: String {
        case enabled
        case paused
        case disabled

        var tabBarIcon: UIImage? {
            if #available(iOS 13.0, *) {
                let name: String
                switch self {
                case .enabled:
                    name = "wifi"
                case .paused:
                    name = "wifi.slash"
                case .disabled:
                    name = "wifi.exclamationmark"
                }
                return UIImage(systemName: name)
            } else {
                return UIImage(named: "wifi")?.resize(toWidth: 30)
            }
        }

        var color: UIColor {
            switch self {
            case .enabled:
                return #colorLiteral(red: 0.6116178036, green: 0.7910612226, blue: 0.3123690188, alpha: 1)
            case .paused:
                return #colorLiteral(red: 0.8926691413, green: 0.5397555232, blue: 0.1979260743, alpha: 1)
            case .disabled:
                return #colorLiteral(red: 0.8860370517, green: 0.2113904059, blue: 0.3562591076, alpha: 1)
            }
        }

        var image: UIImage? {
            switch self {
            case .enabled:
                return UIImage(named: "ScanActiveIcon")
            case .paused:
                return UIImage(named: "BluetoothPaused")
            case .disabled:
                return UIImage(named: "BluetoothOffIcon")
            }
        }

        var head: String {
            switch self {
            case .enabled:
                return "Aplikace je aktivní"
            case .paused:
                return "Aplikace je pozastavená"
            case .disabled:
                return "Zapněte Bluetooth"
            }
        }

        var title: String {
            switch self {
            case .enabled:
                return "Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle."
            case .paused:
                return "Aplikace je aktuálně pozastavená a nesbírá žádná data o vašem okolí."
            case .disabled:
                return "Bez zapnutého Bluetooth nemůžeme vytvářet seznam telefonů ve vašem okolí."
            }
        }

        var text: String {
            switch self {
            case .enabled:
                return "Když budete označeni jako nakažení, kontaktujeme vás na čísle %@. Požádáme vás o zaslání anonymizovaného seznamu telefonů, který naleznete v sekci Moje data."
            case .paused:
                return "Spusťte znovu sběr dat a chraňte vás i vaše okolí. Nezapomínejte na to v momentě, kdy opouštíte svůj domov."
            case .disabled:
                return "Zapněte jej pomocí tlačítka \"Zapnout Bluetooth\"."
            }
        }

        var actionTitle: String {
            switch self {
            case .enabled:
                return "Pozastavit sbírání dat"
            case .paused:
                return "Spustit sbírání dat"
            case .disabled:
                return "Zapnout Bluetooth"
            }
        }

        var actionStyle: Button.Style {
            switch self {
            case .enabled:
                return .clear
            default:
                return .filled
            }
        }

    }

    private(set) var state: State

    init(bluetoothActive: Bool) {
        if !bluetoothActive {
            state = .disabled
        } else {
            state = (AppSettings.state == .disabled ? .enabled : AppSettings.state) ?? .enabled
        }
    }

}
