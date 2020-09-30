//
//  HelpVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct HelpVM {

    var chatbotLink: String {
        RemoteValues.chatBotLink
    }

    var markdownContent: String {
        RemoteValues.helpMarkdown
    }

}
