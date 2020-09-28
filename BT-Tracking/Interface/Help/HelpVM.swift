//
//  HelpVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct HelpVM {

    let title = "help_title"

    let tabTitle = "help_tab_title"
    let tabIcon = UIImage(named: "Help")

    let about = "about"

    let chatbot = "help_chatbot"

    var chatbotLink: String {
        return RemoteValues.chatBotLink
    }

    var markdownContent: String {
        return RemoteValues.helpMarkdown
    }

}
