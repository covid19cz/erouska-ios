//
//  Localization.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/09/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

// MARK: - Localizable enum

enum Localization {

    /// eRouška
    static let app_name = "app_name"

    /// Nápověda
    static let help = "help"

    /// Zpět
    static let back = "back"

    /// OK
    static let ok = "ok"

    /// Chyba
    static let error = "error"

    /// Test
    static let debug = "debug"

    /// O aplikaci
    static let about = "about"

    /// Zavřít
    static let close = "close"

    /// Zapnout
    static let turn_on = "turn_on"

    /// Jak to funguje
    static let welcome_help = "welcome_help"

    /// Pokračovat k aktivaci
    static let welcome_activation = "welcome_activation"

    /// Díky eRoušce ochráníte sebe i ostatní ve svém okolí
    static let welcome_title = "welcome_title"

    /// Aplikace bude nepřetržitě monitorovat vaše okolí a zaznamenávat všechny ostatní telefony s aplikací eRouška, ke kterým se přiblížíte.\n\nPokud se u majitele kteréhokoliv z nich potvrdí onemocnění COVID-19, eRouška vyhodnotí, zda se jedná o rizikový kontakt a upozorní vás.\n\nKdyž se potvrdí nákaza u vás, eRouška upozorní všechny ostatní uživatele aplikace, se kterými jste se potkali.
    static let welcome_body = "welcome_body"

    /// Více o nezávislých auditech
    static let welcome_body_more = "welcome_body_more"

    /// Oznámení
    static let exposure_notification_title = "exposure_notification_title"

    /// eRouška potřebuje pro správné fungování zapnuté oznámení o kontaktu s COVID-19
    static let exposure_notification_headline = "exposure_notification_headline"

    /// Tato oznámení vás upozorní, pokud jste byli v blízkosti uživatele eRoušky s pozitivním testem na onemocnění COVID-19.\n\nPodstatou správného fungování je sdílení a shromažďování náhodných identifikačních čísel, která se automaticky mění. Uživatele eRoušky není možno podle těchto identifikátorů rozpoznat.
    static let exposure_notification_body = "exposure_notification_body"

    /// Zapnout
    static let exposure_notification_continue = "exposure_notification_continue"

    /// Soukromí
    static let privacy_title = "privacy_title"

    /// Myslíme na vaše soukromí, odesílání dat máte vždy pod kontrolou
    static let privacy_headline = "privacy_headline"

    /// eRouška neobsahuje žádné vaše osobní údaje a sbírá pouze anonymní data o ostatních eRouškách, se kterými se setkáte.\n\nDetailní informace o zpracování osobních údajů a další podmínky používání aplikace najdete v podmínkách používání.
    static let privacy_body = "privacy_body"

    /// podmínkách používání
    static let privacy_body_link = "privacy_body_link"

    /// Dokončit aktivaci
    static let privacy_continue = "privacy_continue"

    /// eRouška je aktivní
    static let active_head_enabled = "active_head_enabled"

    /// eRouška je pozastavená
    static let active_head_paused = "active_head_paused"

    /// Zapněte Bluetooth
    static let active_head_disabled_bluetooth = "active_head_disabled_bluetooth"

    /// Zapněte Oznámení o kontaktu s COVID-19
    static let active_head_disabled_exposures = "active_head_disabled_exposures"

    /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
    static let active_title_highlighted_enabled = "active_title_highlighted_enabled"

    /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
    static let active_title_enabled = "active_title_enabled"

    /// Aplikace je aktuálně pozastavená a nesbírá žádná data o ostatních eRouškách ve vašem okolí.\n\nSpusťte znovu sběr dat a chraňte sebe i své okolí. Nezapomínejte na to zejména v situaci, kdy opouštíte svůj domov.
    static let active_title_paused = "active_title_paused"

    /// eRouška nyní nemůže komunikovat s jinými eRouškami ve vašem okolí.\n\nZapněte Oznámení o kontaktu s COVID-19 pomocí tlačítka \"Zapnout\".
    static let active_title_disabled_exposures = "active_title_disabled_exposures"

    /// Bez zapnutého Bluetooth nemůže eRouška vytvářet seznam eRoušek ve vašem okolí.\n\nZapněte jej pomocí tlačítka \"Zapnout Bluetooth\".
    static let active_title_disabled_bluetooth = "active_title_disabled_bluetooth"

    /// Pozastavit eRoušku
    static let active_button_enabled = "active_button_enabled"

    /// Spustit eRoušku
    static let active_button_paused = "active_button_paused"

    /// Zapnout Bluetooth
    static let active_button_disabled_bluetooth = "active_button_disabled_bluetooth"

    /// Zapnout
    static let active_button_disabled_exposures = "active_button_disabled_exposures"

    /// Upozorníme vás v případě možného podezření na setkání s COVID-19 a zobrazíme vám všechny potřebné informace.
    static let active_footer = "active_footer"

    /// Poslední aktualizace dat – %@. eRouška nezaznamenala nikoho nakaženého ve vašem okolí.
    static let active_data_update = "active_data_update"

    /// Aktualizace na pozadí
    static let active_background_mode_title = "active_background_mode_title"

    /// eRouška se potřebuje sama spustit i na pozadí, například po restartování telefonu, abyste na to nemuseli myslet vy.\n\nPovolte možnost 'Aktualizace na pozadí' v nastavení aplikace.
    static let active_background_mode_message = "active_background_mode_message"

    /// Upravit nastavení
    static let active_background_mode_settings = "active_background_mode_settings"

    /// Zavřít
    static let active_background_mode_cancel = "active_background_mode_cancel"

    /// Více informací
    static let active_exposure_more_info = "active_exposure_more_info"

    /// Zrušit aktivaci
    static let cancel_registration_button = "cancel_registration_button"

    /// Sdílet aplikaci
    static let share_app = "share_app"

    /// Ahoj, používám aplikaci eRouška. Nainstaluj si ji taky a společně pomozme zastavit šíření koronaviru. Aplikace sbírá anonymní údaje o telefonech v blízkosti, aby pracovníci hygieny mohli snadněji dohledat potencionálně nakažené. Čím víc nás bude, tím lépe to bude fungovat. Aplikaci najdeš na %@/
    static let share_app_message = "share_app_message"

    /// Aktuálně
    static let data_list_title = "data_list_title"

    /// Odeslat data
    static let data_list_send_title = "data_list_send_title"

    /// V případě potvrzené nákazy onemocněním COVID-19 vás bude kontaktovat pracovník hygienické stanice. Odešle vám SMS zprávu obsahující ověřovací kód pro povolení odeslání dat.
    static let data_list_send_headline = "data_list_send_headline"

    /// Ověřovací kód (povinné)
    static let data_list_send_placeholder = "data_list_send_placeholder"

    /// Ověřit a odeslat data
    static let data_list_send_action_title = "data_list_send_action_title"

    /// Nepodařilo se nám odeslat data
    static let data_list_send_error_failed_title = "data_list_send_error_failed_title"

    /// Zkontrolujte připojení k internetu a zkuste to znovu.
    static let data_list_send_error_failed_message = "data_list_send_error_failed_message"

    /// Nepodařilo se vytvořit soubor se setkáními
    static let data_list_send_error_file_title = "data_list_send_error_file_title"

    /// Nemáte žádné klíče k odeslání, zkuste to později.
    static let data_list_send_error_no_keys = "data_list_send_error_no_keys"

    /// Neplatný ověřovací kód
    static let data_list_send_error_wrong_code_title = "data_list_send_error_wrong_code_title"

    /// Požádejte pracovníka hygienické stanice o zaslání nové SMS zprávy s ověřovacím kódem.
    static let data_list_send_error_wrong_code_message = "data_list_send_error_wrong_code_message"

    /// Data nyní nemůžete odeslat
    static let data_list_send_error_disabled_title = "data_list_send_error_disabled_title"

    /// V sekci Nastavení svého zařízení zapněte Oznámení o kontaktu s COVID-19 a odesílání dat bude možné.
    static let data_list_send_error_disabled_message = "data_list_send_error_disabled_message"

    /// Odesláno
    static let data_send_title = "data_send_title"

    /// Data jste úspěsně odeslali
    static let data_send_title_label = "data_send_title_label"

    /// Děkujeme, že pomáháte bojovat proti šíření onemocnění COVID-19.
    static let data_send_headline = "data_send_headline"

    /// Spolupracujte prosím s pracovníky hygienické stanice na dohledání všech osob, se kterými jste byli v kontaktu.\n\nŘiďte se pokyny hygieniků a lékařů.
    static let data_send_body = "data_send_body"

    /// Zavřít
    static let data_send_close_button = "data_send_close_button"

    /// Kontakty
    static let contacts_title = "contacts_title"

    /// Máte podezření na koronavirus?
    static let contacts_important_headline = "contacts_important_headline"

    /// Zůstaňte doma a kontaktuje svého praktického lékaře nebo příslušnou hygienickou stanici.
    static let contacts_important_body = "contacts_important_body"

    /// Důležité kontakty
    static let contacts_important_button = "contacts_important_button"

    /// Potřebujete poradit?
    static let contacts_help_headline = "contacts_help_headline"

    /// Veškeré otázky a nejasnosti týkající se koronaviru by vám měli zodpovědět na webu MZČR.
    static let contacts_help_body = "contacts_help_body"

    /// Často kladené otázky
    static let contacts_help_faq_button = "contacts_help_faq_button"

    /// O aplikaci eRouška
    static let contacts_about_headline = "contacts_about_headline"

    /// Potřebujete poradit s aplikací nebo vás zajímá jak funguje? Podívejte se na web erouska.cz.
    static let contacts_about_body = "contacts_about_body"

    /// Přejít na web erouska.cz
    static let contacts_about_button = "contacts_about_button"

    /// Jak to funguje
    static let help_title = "help_title"

    /// Napište Anežce – podpoře eRoušky
    static let help_chatbot = "help_chatbot"

    /// Nápověda
    static let help_tab_title = "help_tab_title"

    /// O aplikaci
    static let about_title = "about_title"

    /// Aplikaci eRouška od verze 2.0 vyvíjí Ministerstvo zdravotnictví ve spolupráci s Národní agenturou pro komunikační a informační technologie (NAKIT). Předchozí verzi aplikace eRouška vytvořil tým dobrovolníků v rámci komunitní aktivity COVID19CZ. Většina z původních autorů eRoušky pokračuje na vývoji nových verzí v týmu NAKIT.\n\nDetailní informace o zpracování osobních údajů a další podmínky používání aplikace najdete v podmínkách používání.
    static let about_info = "about_info"

    /// podmínkách používání
    static let about_info_link = "about_info_link"

    /// Důležitá aktualizace eRoušky
    static let force_update_title = "force_update_title"

    /// Je připravená důležitá aktualizace eRoušky. Chcete-li pokračovat v jejím používání, proveďte aktualizaci na nejnovější verzi.
    static let force_update_body = "force_update_body"

    /// Aktualizovat
    static let force_update_button = "force_update_button"

    /// Aktualizujte telefon na nejnovější verzi iOS
    static let force_os_update_title = "force_os_update_title"

    /// Nejnovější verze operačního systému iOS (13.5 nebo novější) je nezbytná pro aktivaci oznámení o setkání s osobou, u které bylo potvrzeno onemocnění COVID-19.
    static let force_os_update_body = "force_os_update_body"

    /// Vaše zařízení nepodporuje iOS 13.5 nebo novější
    static let unsupported_device_title = "unsupported_device_title"

    /// Nejnovější verze operačního systému iOS (13.5 nebo novější) je nezbytná pro další fungování eRoušky.
    static let unsupported_device_body = "unsupported_device_body"

    /// Další informace
    static let unsupported_device_button = "unsupported_device_button"

    /// Tablety s operačním systémem iPadOS nejsou podporované
    static let unsupported_device_ipad_title = "unsupported_device_ipad_title"

    /// Nová verze aplikace eRoušky funguje pouze na telefonech s operačním systémem iOS a Android.
    static let unsupported_device_ipad_body = "unsupported_device_ipad_body"

    /// Zapněte Bluetooth
    static let bluetooth_off_title = "bluetooth_off_title"

    /// Bez zapnutého Bluetooth nemůžeme vytvářet seznam telefonů ve vašem okolí.\n\nZapněte jej pomocí tlačítka \"Zapnout\".
    static let bluetooth_off_body = "bluetooth_off_body"

    /// Novinky
    static let news_title = "news_title"

    /// Pokračovat
    static let news_button_continue = "news_button_continue"

    /// Zavřít
    static let news_button_close = "news_button_close"

    /// eRouška se chystá do světa
    static let news_to_the_world_title = "news_to_the_world_title"

    /// Připravujeme eRoušku na to, aby si rozuměla s podobnými aplikacemi na celém světě. Provedli jsme proto několik změn, které vám nyní představíme.
    static let news_to_the_world_body = "news_to_the_world_body"

    /// Přecházíme na aktivní oznámení
    static let news_exposure_notification_title = "news_exposure_notification_title"

    /// Pokud se setkáte s někým, u koho se potvrdí onemocnění COVID-19, eRouška vás bude informovat pomocí oznámení a poradí vám, jak postupovat dále.
    static let news_exposure_notification_body = "news_exposure_notification_body"

    /// Telefonní čísla už nebudeme potřebovat
    static let news_no_phone_number_title = "news_no_phone_number_title"

    /// Rušíme evidenci telefonních čísel, protože pro komunikaci s hygienickou stanicí již nejsou potřeba. Při rizikovém setkání vám eRouška doporučí další postup.
    static let news_no_phone_number_body = "news_no_phone_number_body"

    /// eRouška funguje vždy a všude
    static let news_always_active_title = "news_always_active_title"

    /// Telefon nemusíte nosit v kapse se zapnutou obrazovkou a pokládat obrazovkou na stůl. Normálně ho používejte a zamykejte, eRouška bude vždy aktivní.
    static let news_always_active_body = "news_always_active_body"

    /// Myslíme na vaše soukromí
    static let news_privacy_title = "news_privacy_title"

    /// S těmito úpravami se změnily i podmínky zpracování. Zásadní změnou je, že nadále nebudeme evidovat telefonní čísla žádného uživatele eRoušky a nebudeme ho vyžadovat při registraci.
    static let news_privacy_body = "news_privacy_body"

    /// podmínky zpracování
    static let news_privacy_body_link = "news_privacy_body_link"

    /// \n\nV případě, že vás bude kontaktovat pracovník hygienické stanice, postupujte podle jeho pokynů.
    static let risky_encounters_positive_title = "risky_encounters_positive_title"

    /// Mám příznaky
    static let risky_encounters_positive_with_symptoms_header = "risky_encounters_positive_with_symptoms_header"

    /// Nemám příznaky
    static let risky_encounters_positive_without_symptoms_header = "risky_encounters_positive_without_symptoms_header"

    /// Otevřete aplikaci eRouška
    static let deadman_notificaiton_title = "deadman_notificaiton_title"

    /// Zkontrolujete tak, zda jste se setkali s osobou u níž bylo potvrzeno onemocnění COVID-19.
    static let deadman_notificaiton_body = "deadman_notificaiton_body"

    /// Bez možnosti zasílat oznámení bude funkčnost eRoušky omezená
    static let exposure_activation_restricted_title = "exposure_activation_restricted_title"

    /// Povolte prosím příjem oznámení, eRouška vás může lépe informovat o rizikového setkání.
    static let exposure_activation_restricted_body = "exposure_activation_restricted_body"

    /// Přejít do nastavení
    static let exposure_activation_restricted_settings_action = "exposure_activation_restricted_settings_action"

    /// Nyní ne
    static let exposure_activation_restricted_cancel_action = "exposure_activation_restricted_cancel_action"

    /// Nepodařilo se aktivovat oznámení
    static let exposure_activation_unknown_title = "exposure_activation_unknown_title"

    /// eRoušce se nepodařilo aktivovat oznámení o kontaktu s COVID-19. Zkontrolujte si vaše nastavení. Pokud problém přetrvává, kontaktujte nás na info@erouska.cz. (Kód chyby: %@)
    static let exposure_activation_unknown_body = "exposure_activation_unknown_body"

    /// Nepodařilo se aktivovat oznámení
    static let exposure_activation_storage_title = "exposure_activation_storage_title"

    /// Oznámení o kontaktech s nákazou nelze aktivovat, protože máte nedostatek místa v zařízení. Uvolněte místo například odstraněním nevyužívaných aplikací a aktivaci proveďte znovu.
    static let exposure_activation_storage_body = "exposure_activation_storage_body"

    /// Nepodařilo se deaktivovat oznámení
    static let exposure_deactivation_unknown_title = "exposure_deactivation_unknown_title"

    /// eRoušce se nepodařilo deaktivovat oznámení o kontaktu s COVID-19. Pokud problém přetrvává, kontaktujte nás na info@erouska.cz. (Kód chyby: %@)
    static let exposure_deactivation_unknown_body = "exposure_deactivation_unknown_body"

    /// Chyba
    static let error_title = "error_title"

    /// Nastala neočekávaná chyba
    static let error_unknown_headline = "error_unknown_headline"

    /// Za chvíli to zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
    static let error_unknown_text = "error_unknown_text"

    /// Zpět
    static let error_unknown_title_action = "error_unknown_title_action"

    /// Opakovat
    static let error_unknown_title_refresh = "error_unknown_title_refresh"

    /// Aktivaci aplikace nelze dokončit
    static let error_activation_internet_headline = "error_activation_internet_headline"

    /// Zkontrolujte připojení k internetu a aktivaci aplikace zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
    static let error_activation_internet_text = "error_activation_internet_text"

    /// Zkusit znovu
    static let error_activation_internet_title_action = "error_activation_internet_title_action"

    /// Setkali jste se s osobou, u které bylo potvrzeno onemocenění COVID-19
    static let exposure_detected_title = "exposure_detected_title"

    /// Poslední aktualizace %@
    static let current_data_footer = "current_data_footer"

    /// Aktuální opatření
    static let current_data_measures = "current_data_measures"

    /// Aktuální situace v číslech
    static let current_data_item_header = "current_data_item_header"

    /// %@ provedených testů
    static let current_data_item_tests = "current_data_item_tests"

    /// %@ celkem potvrzených případů
    static let current_data_item_confirmed = "current_data_item_confirmed"

    /// %@ aktivních případů
    static let current_data_item_active = "current_data_item_active"

    /// %@ vyléčených
    static let current_data_item_healthy = "current_data_item_healthy"

    /// %@ úmrtí
    static let current_data_item_deaths = "current_data_item_deaths"

    /// %@ aktuálně hospitalizovaných
    static let current_data_item_hospitalized = "current_data_item_hospitalized"

    /// Za včerejší den %@
    static let current_data_item_yesterday = "current_data_item_yesterday"

}
