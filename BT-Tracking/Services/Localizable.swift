//
//  Localization.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/09/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

// MARK: - Localizable enum

enum Localization: String {

    /// eRouška
    case app_name = "app_name"

    /// Nápověda
    case help = "help"

    /// Zpět
    case back = "back"

    /// OK
    case ok = "ok"

    /// Chyba
    case error = "error"

    /// Test
    case debug = "debug"

    /// O aplikaci
    case about = "about"

    /// Zavřít
    case close = "close"

    /// Zapnout
    case turn_on = "turn_on"

    /// Jak to funguje
    case welcome_help = "welcome_help"

    /// Pokračovat k aktivaci
    case welcome_activation = "welcome_activation"

    /// Díky eRoušce ochráníte sebe i ostatní ve svém okolí
    case welcome_title = "welcome_title"

    case welcome_body = "welcome_body"

    /// Více o nezávislých auditech
    case welcome_body_more = "welcome_body_more"

    /// Oznámení
    case exposure_notification_title = "exposure_notification_title"

    /// eRouška potřebuje pro správné fungování zapnuté oznámení o kontaktu s COVID-19
    case exposure_notification_headline = "exposure_notification_headline"

    case exposure_notification_body = "exposure_notification_body"

    /// Zapnout
    case exposure_notification_continue = "exposure_notification_continue"

    /// Soukromí
    case privacy_title = "privacy_title"

    /// Myslíme na vaše soukromí, odesílání dat máte vždy pod kontrolou
    case privacy_headline = "privacy_headline"

    case privacy_body = "privacy_body"

    /// podmínkách používání
    case privacy_body_link = "privacy_body_link"

    /// Dokončit aktivaci
    case privacy_continue = "privacy_continue"

    /// eRouška je aktivní
    case active_head_enabled = "active_head_enabled"

    /// eRouška je pozastavená
    case active_head_paused = "active_head_paused"

    /// Zapněte Bluetooth
    case active_head_disabled_bluetooth = "active_head_disabled_bluetooth"

    /// Zapněte Oznámení o kontaktu s COVID-19
    case active_head_disabled_exposures = "active_head_disabled_exposures"

    /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
    case active_title_highlighted_enabled = "active_title_highlighted_enabled"

    /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
    case active_title_enabled = "active_title_enabled"

    case active_title_paused = "active_title_paused"

    /// eRouška nyní nemůže komunikovat s jinými eRouškami ve vašem okolí.\n\nZapněte Oznámení o kontaktu s COVID-19 pomocí tlačítka \"Zapnout\".
    case active_title_disabled_exposures = "active_title_disabled_exposures"

    /// Bez zapnutého Bluetooth nemůže eRouška vytvářet seznam eRoušek ve vašem okolí.\n\nZapněte jej pomocí tlačítka \"Zapnout Bluetooth\".
    case active_title_disabled_bluetooth = "active_title_disabled_bluetooth"

    /// Pozastavit eRoušku
    case active_button_enabled = "active_button_enabled"

    /// Spustit eRoušku
    case active_button_paused = "active_button_paused"

    /// Zapnout Bluetooth
    case active_button_disabled_bluetooth = "active_button_disabled_bluetooth"

    /// Zapnout
    case active_button_disabled_exposures = "active_button_disabled_exposures"

    /// Upozorníme vás v případě možného podezření na setkání s COVID-19 a zobrazíme vám všechny potřebné informace.
    case active_footer = "active_footer"

    /// Poslední aktualizace dat – %@. eRouška nezaznamenala nikoho nakaženého ve vašem okolí.
    case active_data_update = "active_data_update"

    /// Aktualizace na pozadí
    case active_background_mode_title = "active_background_mode_title"

    case active_background_mode_message = "active_background_mode_message"

    /// Upravit nastavení
    case active_background_mode_settings = "active_background_mode_settings"

    /// Zavřít
    case active_background_mode_cancel = "active_background_mode_cancel"

    /// Více informací
    case active_exposure_more_info = "active_exposure_more_info"

    /// Zrušit aktivaci
    case cancel_registration_button = "cancel_registration_button"

    /// Sdílet aplikaci
    case share_app = "share_app"

    case share_app_message = "share_app_message"

    /// Aktuálně
    case data_list_title = "data_list_title"

    /// Odeslat data
    case data_list_send_title = "data_list_send_title"

    case data_list_send_headline = "data_list_send_headline"

    /// Ověřovací kód (povinné)
    case data_list_send_placeholder = "data_list_send_placeholder"

    /// Ověřit a odeslat data
    case data_list_send_action_title = "data_list_send_action_title"

    /// Nepodařilo se nám odeslat data
    case data_list_send_error_failed_title = "data_list_send_error_failed_title"

    /// Zkontrolujte připojení k internetu a zkuste to znovu.
    case data_list_send_error_failed_message = "data_list_send_error_failed_message"

    /// Nepodařilo se vytvořit soubor se setkáními
    case data_list_send_error_file_title = "data_list_send_error_file_title"

    /// Nemáte žádné klíče k odeslání, zkuste to později.
    case data_list_send_error_no_keys = "data_list_send_error_no_keys"

    /// Neplatný ověřovací kód
    case data_list_send_error_wrong_code_title = "data_list_send_error_wrong_code_title"

    /// Požádejte pracovníka hygienické stanice o zaslání nové SMS zprávy s ověřovacím kódem.
    case data_list_send_error_wrong_code_message = "data_list_send_error_wrong_code_message"

    /// Data nyní nemůžete odeslat
    case data_list_send_error_disabled_title = "data_list_send_error_disabled_title"

    /// V sekci Nastavení svého zařízení zapněte Oznámení o kontaktu s COVID-19 a odesílání dat bude možné.
    case data_list_send_error_disabled_message = "data_list_send_error_disabled_message"

    /// Odesláno
    case data_send_title = "data_send_title"

    /// Data jste úspěsně odeslali
    case data_send_title_label = "data_send_title_label"

    /// Děkujeme, že pomáháte bojovat proti šíření onemocnění COVID-19.
    case data_send_headline = "data_send_headline"

    /// Spolupracujte prosím s pracovníky hygienické stanice na dohledání všech osob, se kterými jste byli v kontaktu.\n\nŘiďte se pokyny hygieniků a lékařů.
    case data_send_body = "data_send_body"

    /// Zavřít
    case data_send_close_button = "data_send_close_button"

    /// Kontakty
    case contacts_title = "contacts_title"

    /// Máte podezření na koronavirus?
    case contacts_important_headline = "contacts_important_headline"

    /// Zůstaňte doma a kontaktuje svého praktického lékaře nebo příslušnou hygienickou stanici.
    case contacts_important_body = "contacts_important_body"

    /// Důležité kontakty
    case contacts_important_button = "contacts_important_button"

    /// Potřebujete poradit?
    case contacts_help_headline = "contacts_help_headline"

    /// Veškeré otázky a nejasnosti týkající se koronaviru by vám měli zodpovědět na webu MZČR.
    case contacts_help_body = "contacts_help_body"

    /// Často kladené otázky
    case contacts_help_faq_button = "contacts_help_faq_button"

    /// O aplikaci eRouška
    case contacts_about_headline = "contacts_about_headline"

    /// Potřebujete poradit s aplikací nebo vás zajímá jak funguje? Podívejte se na web erouska.cz.
    case contacts_about_body = "contacts_about_body"

    /// Přejít na web erouska.cz
    case contacts_about_button = "contacts_about_button"

    /// Jak to funguje
    case help_title = "help_title"

    /// Napište Anežce – podpoře eRoušky
    case help_chatbot = "help_chatbot"

    /// Nápověda
    case help_tab_title = "help_tab_title"

    /// O aplikaci
    case about_title = "about_title"

    case about_info = "about_info"

    /// podmínkách používání
    case about_info_link = "about_info_link"

    /// Důležitá aktualizace eRoušky
    case force_update_title = "force_update_title"

    /// Je připravená důležitá aktualizace eRoušky. Chcete-li pokračovat v jejím používání, proveďte aktualizaci na nejnovější verzi.
    case force_update_body = "force_update_body"

    /// Aktualizovat
    case force_update_button = "force_update_button"

    /// Aktualizujte telefon na nejnovější verzi iOS
    case force_os_update_title = "force_os_update_title"

    case force_os_update_body = "force_os_update_body"

    /// Vaše zařízení nepodporuje iOS 13.5 nebo novější
    case unsupported_device_title = "unsupported_device_title"

    /// Nejnovější verze operačního systému iOS (13.5 nebo novější) je nezbytná pro další fungování eRoušky.
    case unsupported_device_body = "unsupported_device_body"

    /// Další informace
    case unsupported_device_button = "unsupported_device_button"

    /// Tablety s operačním systémem iPadOS nejsou podporované
    case unsupported_device_ipad_title = "unsupported_device_ipad_title"

    /// Nová verze aplikace eRoušky funguje pouze na telefonech s operačním systémem iOS a Android.
    case unsupported_device_ipad_body = "unsupported_device_ipad_body"

    /// Zapněte Bluetooth
    case bluetooth_off_title = "bluetooth_off_title"

    /// Bez zapnutého Bluetooth nemůžeme vytvářet seznam telefonů ve vašem okolí.\n\nZapněte jej pomocí tlačítka \"Zapnout\".
    case bluetooth_off_body = "bluetooth_off_body"

    /// Novinky
    case news_title = "news_title"

    /// Pokračovat
    case news_button_continue = "news_button_continue"

    /// Zavřít
    case news_button_close = "news_button_close"

    /// eRouška se chystá do světa
    case news_to_the_world_title = "news_to_the_world_title"

    /// Připravujeme eRoušku na to, aby si rozuměla s podobnými aplikacemi na celém světě. Provedli jsme proto několik změn, které vám nyní představíme.
    case news_to_the_world_body = "news_to_the_world_body"

    /// Přecházíme na aktivní oznámení
    case news_exposure_notification_title = "news_exposure_notification_title"

    /// Pokud se setkáte s někým, u koho se potvrdí onemocnění COVID-19, eRouška vás bude informovat pomocí oznámení a poradí vám, jak postupovat dále.
    case news_exposure_notification_body = "news_exposure_notification_body"

    /// Telefonní čísla už nebudeme potřebovat
    case news_no_phone_number_title = "news_no_phone_number_title"

    case news_no_phone_number_body = "news_no_phone_number_body"

    /// eRouška funguje vždy a všude
    case news_always_active_title = "news_always_active_title"

    /// Telefon nemusíte nosit v kapse se zapnutou obrazovkou a pokládat obrazovkou na stůl. Normálně ho používejte a zamykejte, eRouška bude vždy aktivní.
    case news_always_active_body = "news_always_active_body"

    /// Myslíme na vaše soukromí
    case news_privacy_title = "news_privacy_title"

    case news_privacy_body = "news_privacy_body"

    /// podmínky zpracování
    case news_privacy_body_link = "news_privacy_body_link"

    /// \n\nV případě, že vás bude kontaktovat pracovník hygienické stanice, postupujte podle jeho pokynů.
    case risky_encounters_positive_title = "risky_encounters_positive_title"

    /// Mám příznaky
    case risky_encounters_positive_with_symptoms_header = "risky_encounters_positive_with_symptoms_header"

    /// Nemám příznaky
    case risky_encounters_positive_without_symptoms_header = "risky_encounters_positive_without_symptoms_header"

    /// Otevřete aplikaci eRouška
    case deadman_notificaiton_title = "deadman_notificaiton_title"

    /// Zkontrolujete tak, zda jste se setkali s osobou u níž bylo potvrzeno onemocnění COVID-19.
    case deadman_notificaiton_body = "deadman_notificaiton_body"

    /// Bez možnosti zasílat oznámení bude funkčnost eRoušky omezená
    case exposure_activation_restricted_title = "exposure_activation_restricted_title"

    /// Povolte prosím příjem oznámení, eRouška vás může lépe informovat o rizikového setkání.
    case exposure_activation_restricted_body = "exposure_activation_restricted_body"

    /// Přejít do nastavení
    case exposure_activation_restricted_settings_action = "exposure_activation_restricted_settings_action"

    /// Nyní ne
    case exposure_activation_restricted_cancel_action = "exposure_activation_restricted_cancel_action"

    /// Nepodařilo se aktivovat oznámení
    case exposure_activation_unknown_title = "exposure_activation_unknown_title"

    case exposure_activation_unknown_body = "exposure_activation_unknown_body"

    /// Nepodařilo se aktivovat oznámení
    case exposure_activation_storage_title = "exposure_activation_storage_title"

    case exposure_activation_storage_body = "exposure_activation_storage_body"

    /// Nepodařilo se deaktivovat oznámení
    case exposure_deactivation_unknown_title = "exposure_deactivation_unknown_title"

    /// eRoušce se nepodařilo deaktivovat oznámení o kontaktu s COVID-19. Pokud problém přetrvává, kontaktujte nás na info@erouska.cz. (Kód chyby: %@)
    case exposure_deactivation_unknown_body = "exposure_deactivation_unknown_body"

    /// Chyba
    case error_title = "error_title"

    /// Nastala neočekávaná chyba
    case error_unknown_headline = "error_unknown_headline"

    /// Za chvíli to zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
    case error_unknown_text = "error_unknown_text"

    /// Zpět
    case error_unknown_title_action = "error_unknown_title_action"

    /// Opakovat
    case error_unknown_title_refresh = "error_unknown_title_refresh"

    /// Aktivaci aplikace nelze dokončit
    case error_activation_internet_headline = "error_activation_internet_headline"

    /// Zkontrolujte připojení k internetu a aktivaci aplikace zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
    case error_activation_internet_text = "error_activation_internet_text"

    /// Zkusit znovu
    case error_activation_internet_title_action = "error_activation_internet_title_action"

    /// Setkali jste se s osobou, u které bylo potvrzeno onemocenění COVID-19
    case exposure_detected_title = "exposure_detected_title"

    /// Poslední aktualizace %@
    case current_data_footer = "current_data_footer"

    /// Aktuální opatření
    case current_data_measures = "current_data_measures"

    /// Aktuální situace v číslech
    case current_data_item_header = "current_data_item_header"

    /// %@ provedených testů
    case current_data_item_tests = "current_data_item_tests"

    /// %@ celkem potvrzených případů
    case current_data_item_confirmed = "current_data_item_confirmed"

    /// %@ aktivních případů
    case current_data_item_active = "current_data_item_active"

    /// %@ vyléčených
    case current_data_item_healthy = "current_data_item_healthy"

    /// %@ úmrtí
    case current_data_item_deaths = "current_data_item_deaths"

    /// %@ aktuálně hospitalizovaných
    case current_data_item_hospitalized = "current_data_item_hospitalized"

    /// Za včerejší den %@
    case current_data_item_yesterday = "current_data_item_yesterday"

}
