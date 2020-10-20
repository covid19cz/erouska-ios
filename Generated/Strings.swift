// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// O aplikaci
  internal static let about = L10n.tr("Localizable", "about")
  /// Aplikaci eRouška od verze 2.0 vyvíjí Ministerstvo zdravotnictví ve spolupráci s Národní agenturou pro komunikační a informační technologie (NAKIT). Předchozí verzi aplikace eRouška vytvořil tým dobrovolníků v rámci komunitní aktivity COVID19CZ. Většina z původních autorů eRoušky pokračuje na vývoji nových verzí v týmu NAKIT.\n\nDetailní informace o zpracování osobních údajů a další podmínky používání aplikace najdete v podmínkách používání.
  internal static let aboutInfo = L10n.tr("Localizable", "about_info")
  /// podmínkách používání
  internal static let aboutInfoLink = L10n.tr("Localizable", "about_info_link")
  /// O aplikaci
  internal static let aboutTitle = L10n.tr("Localizable", "about_title")
  /// Zavřít
  internal static let activeBackgroundModeCancel = L10n.tr("Localizable", "active_background_mode_cancel")
  /// eRouška se potřebuje sama spustit i na pozadí, například po restartování telefonu, abyste na to nemuseli myslet vy.\n\nPovolte možnost 'Aktualizace na pozadí' v nastavení aplikace.
  internal static let activeBackgroundModeMessage = L10n.tr("Localizable", "active_background_mode_message")
  /// Upravit nastavení
  internal static let activeBackgroundModeSettings = L10n.tr("Localizable", "active_background_mode_settings")
  /// Aktualizace na pozadí
  internal static let activeBackgroundModeTitle = L10n.tr("Localizable", "active_background_mode_title")
  /// Zapnout Bluetooth
  internal static let activeButtonDisabledBluetooth = L10n.tr("Localizable", "active_button_disabled_bluetooth")
  /// Zapnout
  internal static let activeButtonDisabledExposures = L10n.tr("Localizable", "active_button_disabled_exposures")
  /// Pozastavit eRoušku
  internal static let activeButtonEnabled = L10n.tr("Localizable", "active_button_enabled")
  /// Spustit eRoušku
  internal static let activeButtonPaused = L10n.tr("Localizable", "active_button_paused")
  /// Poslední aktualizace dat – %@.
  internal static func activeDataUpdate(_ p1: Any) -> String {
    return L10n.tr("Localizable", "active_data_update", String(describing: p1))
  }
  /// Více informací
  internal static let activeExposureMoreInfo = L10n.tr("Localizable", "active_exposure_more_info")
  /// Upozorníme vás v případě možného podezření na setkání s COVID-19 a zobrazíme vám všechny potřebné informace.
  internal static let activeFooter = L10n.tr("Localizable", "active_footer")
  /// Zapněte Bluetooth
  internal static let activeHeadDisabledBluetooth = L10n.tr("Localizable", "active_head_disabled_bluetooth")
  /// Zapněte Oznámení o kontaktu s COVID-19
  internal static let activeHeadDisabledExposures = L10n.tr("Localizable", "active_head_disabled_exposures")
  /// eRouška je aktivní
  internal static let activeHeadEnabled = L10n.tr("Localizable", "active_head_enabled")
  /// eRouška je pozastavená
  internal static let activeHeadPaused = L10n.tr("Localizable", "active_head_paused")
  /// Bez zapnutého Bluetooth nemůže eRouška vytvářet seznam eRoušek ve vašem okolí.\n\nZapněte jej pomocí tlačítka "Zapnout Bluetooth".
  internal static let activeTitleDisabledBluetooth = L10n.tr("Localizable", "active_title_disabled_bluetooth")
  /// eRouška nyní nemůže komunikovat s jinými eRouškami ve vašem okolí.\n\nZapněte Oznámení o kontaktu s COVID-19 pomocí tlačítka "Zapnout".
  internal static let activeTitleDisabledExposures = L10n.tr("Localizable", "active_title_disabled_exposures")
  /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
  internal static let activeTitleEnabled = L10n.tr("Localizable", "active_title_enabled")
  /// Aplikace pracuje na pozadí a monitoruje okolí, prosím neukončujte ji. Nechte zapnuté Bluetooth a s telefonem pracujte jako obvykle.
  internal static let activeTitleHighlightedEnabled = L10n.tr("Localizable", "active_title_highlighted_enabled")
  /// Aplikace je aktuálně pozastavená a nesbírá žádná data o ostatních eRouškách ve vašem okolí.\n\nSpusťte znovu sběr dat a chraňte sebe i své okolí. Nezapomínejte na to zejména v situaci, kdy opouštíte svůj domov.
  internal static let activeTitlePaused = L10n.tr("Localizable", "active_title_paused")
  /// eRouška
  internal static let appName = L10n.tr("Localizable", "app_name")
  /// Zpět
  internal static let back = L10n.tr("Localizable", "back")
  /// Bez zapnutého Bluetooth nemůžeme vytvářet seznam telefonů ve vašem okolí.\n\nZapněte jej pomocí tlačítka "Zapnout".
  internal static let bluetoothOffBody = L10n.tr("Localizable", "bluetooth_off_body")
  /// Zapněte Bluetooth
  internal static let bluetoothOffTitle = L10n.tr("Localizable", "bluetooth_off_title")
  /// Zrušit aktivaci
  internal static let cancelRegistrationButton = L10n.tr("Localizable", "cancel_registration_button")
  /// Zavřít
  internal static let close = L10n.tr("Localizable", "close")
  /// Potřebujete poradit s aplikací nebo vás zajímá jak funguje? Podívejte se na web erouska.cz.
  internal static let contactsAboutBody = L10n.tr("Localizable", "contacts_about_body")
  /// Přejít na web erouska.cz
  internal static let contactsAboutButton = L10n.tr("Localizable", "contacts_about_button")
  /// O aplikaci eRouška
  internal static let contactsAboutHeadline = L10n.tr("Localizable", "contacts_about_headline")
  /// Veškeré otázky a nejasnosti týkající se koronaviru by vám měli zodpovědět na webu MZČR.
  internal static let contactsHelpBody = L10n.tr("Localizable", "contacts_help_body")
  /// Často kladené otázky
  internal static let contactsHelpFaqButton = L10n.tr("Localizable", "contacts_help_faq_button")
  /// Potřebujete poradit?
  internal static let contactsHelpHeadline = L10n.tr("Localizable", "contacts_help_headline")
  /// Zůstaňte doma a kontaktuje svého praktického lékaře nebo příslušnou hygienickou stanici.
  internal static let contactsImportantBody = L10n.tr("Localizable", "contacts_important_body")
  /// Důležité kontakty
  internal static let contactsImportantButton = L10n.tr("Localizable", "contacts_important_button")
  /// Máte podezření na koronavirus?
  internal static let contactsImportantHeadline = L10n.tr("Localizable", "contacts_important_headline")
  /// Kontakty
  internal static let contactsTitle = L10n.tr("Localizable", "contacts_title")
  /// Poslední aktualizace %@
  internal static func currentDataFooter(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_footer", String(describing: p1))
  }
  /// %@ aktivních případů
  internal static func currentDataItemActive(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_active", String(describing: p1))
  }
  /// %@ celkem potvrzených případů
  internal static func currentDataItemConfirmed(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_confirmed", String(describing: p1))
  }
  /// %@ úmrtí
  internal static func currentDataItemDeaths(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_deaths", String(describing: p1))
  }
  /// Aktuální situace v číslech
  internal static let currentDataItemHeader = L10n.tr("Localizable", "current_data_item_header")
  /// %@ vyléčených
  internal static func currentDataItemHealthy(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_healthy", String(describing: p1))
  }
  /// %@ aktuálně hospitalizovaných
  internal static func currentDataItemHospitalized(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_hospitalized", String(describing: p1))
  }
  /// %@ provedených testů
  internal static func currentDataItemTests(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_tests", String(describing: p1))
  }
  /// Za včerejší den %@
  internal static func currentDataItemYesterday(_ p1: Any) -> String {
    return L10n.tr("Localizable", "current_data_item_yesterday", String(describing: p1))
  }
  /// Aktuální opatření
  internal static let currentDataMeasures = L10n.tr("Localizable", "current_data_measures")
  /// Riziková setkání zjištěná
  internal static let dataListPreviousHeader = L10n.tr("Localizable", "data_list_previous_header")
  /// Ověřit a odeslat data
  internal static let dataListSendActionTitle = L10n.tr("Localizable", "data_list_send_action_title")
  /// V sekci Nastavení svého zařízení zapněte Oznámení o kontaktu s COVID-19 a odesílání dat bude možné.
  internal static let dataListSendErrorDisabledMessage = L10n.tr("Localizable", "data_list_send_error_disabled_message")
  /// Data nyní nemůžete odeslat
  internal static let dataListSendErrorDisabledTitle = L10n.tr("Localizable", "data_list_send_error_disabled_title")
  /// Požádejte pracovníka hygienické stanice o zaslání nové SMS zprávy s ověřovacím kódem.
  internal static let dataListSendErrorExpiredCodeMessage = L10n.tr("Localizable", "data_list_send_error_expired_code_message")
  /// Vypršela platnost ověřovacího kódu.
  internal static let dataListSendErrorExpiredCodeTitle = L10n.tr("Localizable", "data_list_send_error_expired_code_title")
  /// Zkontrolujte připojení k internetu a zkuste to znovu.
  internal static let dataListSendErrorFailedMessage = L10n.tr("Localizable", "data_list_send_error_failed_message")
  /// Nepodařilo se nám odeslat data
  internal static let dataListSendErrorFailedTitle = L10n.tr("Localizable", "data_list_send_error_failed_title")
  /// Nepodařilo se vytvořit soubor se setkáními
  internal static let dataListSendErrorFileTitle = L10n.tr("Localizable", "data_list_send_error_file_title")
  /// Zkontrolujte zda máte aktivované oznámení o kontaktech s nákazou.\nPřípadně kontaktujte prosím podporu na info@erouska.cz a do e-mailu uveďte následující kód chyby: %@.
  internal static func dataListSendErrorFrameworkMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "data_list_send_error_framework_message", String(describing: p1))
  }
  /// Nepodařilo se nám získat data.
  internal static let dataListSendErrorFrameworkTitle = L10n.tr("Localizable", "data_list_send_error_framework_title")
  /// Kontaktujte prosím podporu na info@erouska.cz a do e-mailu uveďte následující kód chyby: %@.
  internal static func dataListSendErrorMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "data_list_send_error_message", String(describing: p1))
  }
  /// Nemáte žádné klíče k odeslání, zkuste to později.
  internal static let dataListSendErrorNoKeys = L10n.tr("Localizable", "data_list_send_error_no_keys")
  /// Kontaktujte prosím podporu na info@erouska.cz a do e-mailu uveďte následující kód chyby: %@.
  internal static func dataListSendErrorSaveMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "data_list_send_error_save_message", String(describing: p1))
  }
  /// Nepodařilo se nám odeslat data na server.
  internal static let dataListSendErrorSaveTitle = L10n.tr("Localizable", "data_list_send_error_save_title")
  /// Nepodařilo se nám odeslat data.
  internal static let dataListSendErrorTitle = L10n.tr("Localizable", "data_list_send_error_title")
  /// Ověřovací kód není správně zadaný, zkuste to znovu.
  internal static let dataListSendErrorWrongCodeTitle = L10n.tr("Localizable", "data_list_send_error_wrong_code_title")
  /// V případě potvrzené nákazy onemocněním COVID-19 obdržíte SMS zprávu obsahující ověřovací kód pro upozornění ostatních uživatelů eRoušky.
  internal static let dataListSendHeadline = L10n.tr("Localizable", "data_list_send_headline")
  /// Ověřovací kód (povinné)
  internal static let dataListSendPlaceholder = L10n.tr("Localizable", "data_list_send_placeholder")
  /// Odeslat data
  internal static let dataListSendTitle = L10n.tr("Localizable", "data_list_send_title")
  /// Aktuálně
  internal static let dataListTitle = L10n.tr("Localizable", "data_list_title")
  /// Spolupracujte prosím s pracovníky hygienické stanice na dohledání všech osob, se kterými jste byli v kontaktu.\n\nŘiďte se pokyny hygieniků a lékařů.
  internal static let dataSendBody = L10n.tr("Localizable", "data_send_body")
  /// Zavřít
  internal static let dataSendCloseButton = L10n.tr("Localizable", "data_send_close_button")
  /// Děkujeme, že pomáháte bojovat proti šíření onemocnění COVID-19.
  internal static let dataSendHeadline = L10n.tr("Localizable", "data_send_headline")
  /// Odesláno
  internal static let dataSendTitle = L10n.tr("Localizable", "data_send_title")
  /// Data jste úspěsně odeslali
  internal static let dataSendTitleLabel = L10n.tr("Localizable", "data_send_title_label")
  /// Zkontrolujete tak, zda jste se setkali s osobou u níž bylo potvrzeno onemocnění COVID-19.
  internal static let deadmanNotificaitonBody = L10n.tr("Localizable", "deadman_notificaiton_body")
  /// Otevřete aplikaci eRouška
  internal static let deadmanNotificaitonTitle = L10n.tr("Localizable", "deadman_notificaiton_title")
  /// Test
  internal static let debug = L10n.tr("Localizable", "debug")
  /// Chyba
  internal static let error = L10n.tr("Localizable", "error")
  /// Aktivaci aplikace nelze dokončit
  internal static let errorActivationInternetHeadline = L10n.tr("Localizable", "error_activation_internet_headline")
  /// Zkontrolujte připojení k internetu a aktivaci aplikace zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
  internal static let errorActivationInternetText = L10n.tr("Localizable", "error_activation_internet_text")
  /// Zkusit znovu
  internal static let errorActivationInternetTitleAction = L10n.tr("Localizable", "error_activation_internet_title_action")
  /// Chyba
  internal static let errorTitle = L10n.tr("Localizable", "error_title")
  /// Nastala neočekávaná chyba
  internal static let errorUnknownHeadline = L10n.tr("Localizable", "error_unknown_headline")
  /// Za chvíli to zkuste znovu. Pokud chyba přetrvává, kontaktujte nás na info@erouska.cz.
  internal static let errorUnknownText = L10n.tr("Localizable", "error_unknown_text")
  /// Zpět
  internal static let errorUnknownTitleAction = L10n.tr("Localizable", "error_unknown_title_action")
  /// Opakovat
  internal static let errorUnknownTitleRefresh = L10n.tr("Localizable", "error_unknown_title_refresh")
  /// Povolte prosím příjem oznámení, eRouška vás může lépe informovat o rizikového setkání.
  internal static let exposureActivationRestrictedBody = L10n.tr("Localizable", "exposure_activation_restricted_body")
  /// Nyní ne
  internal static let exposureActivationRestrictedCancelAction = L10n.tr("Localizable", "exposure_activation_restricted_cancel_action")
  /// Přejít do nastavení
  internal static let exposureActivationRestrictedSettingsAction = L10n.tr("Localizable", "exposure_activation_restricted_settings_action")
  /// Bez možnosti zasílat oznámení bude funkčnost eRoušky omezená
  internal static let exposureActivationRestrictedTitle = L10n.tr("Localizable", "exposure_activation_restricted_title")
  /// Oznámení o kontaktech s nákazou nelze aktivovat, protože máte nedostatek místa v zařízení. Uvolněte místo například odstraněním nevyužívaných aplikací a aktivaci proveďte znovu.
  internal static let exposureActivationStorageBody = L10n.tr("Localizable", "exposure_activation_storage_body")
  /// Nepodařilo se aktivovat oznámení
  internal static let exposureActivationStorageTitle = L10n.tr("Localizable", "exposure_activation_storage_title")
  /// eRoušce se nepodařilo aktivovat oznámení o kontaktu s COVID-19. Zkontrolujte si vaše nastavení. Pokud problém přetrvává, kontaktujte nás na info@erouska.cz. (Kód chyby: %@)
  internal static func exposureActivationUnknownBody(_ p1: Any) -> String {
    return L10n.tr("Localizable", "exposure_activation_unknown_body", String(describing: p1))
  }
  /// Nepodařilo se aktivovat oznámení
  internal static let exposureActivationUnknownTitle = L10n.tr("Localizable", "exposure_activation_unknown_title")
  /// eRoušce se nepodařilo deaktivovat oznámení o kontaktu s COVID-19. Pokud problém přetrvává, kontaktujte nás na info@erouska.cz. (Kód chyby: %@)
  internal static func exposureDeactivationUnknownBody(_ p1: Any) -> String {
    return L10n.tr("Localizable", "exposure_deactivation_unknown_body", String(describing: p1))
  }
  /// Nepodařilo se deaktivovat oznámení
  internal static let exposureDeactivationUnknownTitle = L10n.tr("Localizable", "exposure_deactivation_unknown_title")
  /// Setkali jste se s osobou, u které bylo potvrzeno onemocenění COVID-19
  internal static let exposureDetectedTitle = L10n.tr("Localizable", "exposure_detected_title")
  /// Tato oznámení vás upozorní, pokud jste byli v blízkosti uživatele eRoušky s pozitivním testem na onemocnění COVID-19.\n\nPodstatou správného fungování je sdílení a shromažďování náhodných identifikačních čísel, která se automaticky mění. Uživatele eRoušky není možno podle těchto identifikátorů rozpoznat.
  internal static let exposureNotificationBody = L10n.tr("Localizable", "exposure_notification_body")
  /// Zapnout
  internal static let exposureNotificationContinue = L10n.tr("Localizable", "exposure_notification_continue")
  /// eRouška potřebuje pro správné fungování zapnuté oznámení o kontaktu s COVID-19
  internal static let exposureNotificationHeadline = L10n.tr("Localizable", "exposure_notification_headline")
  /// Oznámení
  internal static let exposureNotificationTitle = L10n.tr("Localizable", "exposure_notification_title")
  /// Nejnovější verze operačního systému iOS (13.5 nebo novější) je nezbytná pro aktivaci oznámení o setkání s osobou, u které bylo potvrzeno onemocnění COVID-19.
  internal static let forceOsUpdateBody = L10n.tr("Localizable", "force_os_update_body")
  /// Aktualizujte telefon na nejnovější verzi iOS
  internal static let forceOsUpdateTitle = L10n.tr("Localizable", "force_os_update_title")
  /// Je připravená důležitá aktualizace eRoušky. Chcete-li pokračovat v jejím používání, proveďte aktualizaci na nejnovější verzi.
  internal static let forceUpdateBody = L10n.tr("Localizable", "force_update_body")
  /// Aktualizovat
  internal static let forceUpdateButton = L10n.tr("Localizable", "force_update_button")
  /// Důležitá aktualizace eRoušky
  internal static let forceUpdateTitle = L10n.tr("Localizable", "force_update_title")
  /// Nápověda
  internal static let help = L10n.tr("Localizable", "help")
  /// Napište Anežce – podpoře eRoušky
  internal static let helpChatbot = L10n.tr("Localizable", "help_chatbot")
  /// Nápověda
  internal static let helpTabTitle = L10n.tr("Localizable", "help_tab_title")
  /// Jak to funguje
  internal static let helpTitle = L10n.tr("Localizable", "help_title")
  /// Telefon nemusíte nosit v kapse se zapnutou obrazovkou a pokládat obrazovkou na stůl. Normálně ho používejte a zamykejte, eRouška bude vždy aktivní.
  internal static let newsAlwaysActiveBody = L10n.tr("Localizable", "news_always_active_body")
  /// eRouška funguje vždy a všude
  internal static let newsAlwaysActiveTitle = L10n.tr("Localizable", "news_always_active_title")
  /// Zavřít
  internal static let newsButtonClose = L10n.tr("Localizable", "news_button_close")
  /// Pokračovat
  internal static let newsButtonContinue = L10n.tr("Localizable", "news_button_continue")
  /// Pokud se setkáte s někým, u koho se potvrdí onemocnění COVID-19, eRouška vás bude informovat pomocí oznámení a poradí vám, jak postupovat dále.
  internal static let newsExposureNotificationBody = L10n.tr("Localizable", "news_exposure_notification_body")
  /// Přecházíme na aktivní oznámení
  internal static let newsExposureNotificationTitle = L10n.tr("Localizable", "news_exposure_notification_title")
  /// Rušíme evidenci telefonních čísel, protože pro komunikaci s hygienickou stanicí již nejsou potřeba. Při rizikovém setkání vám eRouška doporučí další postup.
  internal static let newsNoPhoneNumberBody = L10n.tr("Localizable", "news_no_phone_number_body")
  /// Telefonní čísla už nebudeme potřebovat
  internal static let newsNoPhoneNumberTitle = L10n.tr("Localizable", "news_no_phone_number_title")
  /// S těmito úpravami se změnily i podmínky zpracování. Zásadní změnou je, že nadále nebudeme evidovat telefonní čísla žádného uživatele eRoušky a nebudeme ho vyžadovat při registraci.
  internal static let newsPrivacyBody = L10n.tr("Localizable", "news_privacy_body")
  /// podmínky zpracování
  internal static let newsPrivacyBodyLink = L10n.tr("Localizable", "news_privacy_body_link")
  /// Myslíme na vaše soukromí
  internal static let newsPrivacyTitle = L10n.tr("Localizable", "news_privacy_title")
  /// Novinky
  internal static let newsTitle = L10n.tr("Localizable", "news_title")
  /// Připravujeme eRoušku na to, aby si rozuměla s podobnými aplikacemi na celém světě. Provedli jsme proto několik změn, které vám nyní představíme.
  internal static let newsToTheWorldBody = L10n.tr("Localizable", "news_to_the_world_body")
  /// eRouška se chystá do světa
  internal static let newsToTheWorldTitle = L10n.tr("Localizable", "news_to_the_world_title")
  /// OK
  internal static let ok = L10n.tr("Localizable", "ok")
  /// eRouška neobsahuje žádné vaše osobní údaje a sbírá pouze anonymní data o ostatních eRouškách, se kterými se setkáte.\n\nDetailní informace o zpracování osobních údajů a další podmínky používání aplikace najdete v podmínkách používání.
  internal static let privacyBody = L10n.tr("Localizable", "privacy_body")
  /// podmínkách používání
  internal static let privacyBodyLink = L10n.tr("Localizable", "privacy_body_link")
  /// Dokončit aktivaci
  internal static let privacyContinue = L10n.tr("Localizable", "privacy_continue")
  /// Myslíme na vaše soukromí, odesílání dat máte vždy pod kontrolou
  internal static let privacyHeadline = L10n.tr("Localizable", "privacy_headline")
  /// Soukromí
  internal static let privacyTitle = L10n.tr("Localizable", "privacy_title")
  /// \n\nV případě, že vás bude kontaktovat pracovník hygienické stanice, postupujte podle jeho pokynů.
  internal static let riskyEncountersPositiveTitle = L10n.tr("Localizable", "risky_encounters_positive_title")
  /// Mám příznaky
  internal static let riskyEncountersPositiveWithSymptomsHeader = L10n.tr("Localizable", "risky_encounters_positive_with_symptoms_header")
  /// Nemám příznaky
  internal static let riskyEncountersPositiveWithoutSymptomsHeader = L10n.tr("Localizable", "risky_encounters_positive_without_symptoms_header")
  /// Sdílet aplikaci
  internal static let shareApp = L10n.tr("Localizable", "share_app")
  /// Ahoj, používám aplikaci eRouška. Nainstaluj si ji taky a společně pomozme zastavit šíření onemocnění COVID-19. Aplikace dokáže anonymně a včas upozornit na rizikové setkání s nakaženým uživatelem a doporučit další postup. Najdeš ji na %@/
  internal static func shareAppMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "share_app_message", String(describing: p1))
  }
  /// Zapnout
  internal static let turnOn = L10n.tr("Localizable", "turn_on")
  /// Nejnovější verze operačního systému iOS (13.5 nebo novější) je nezbytná pro další fungování eRoušky.
  internal static let unsupportedDeviceBody = L10n.tr("Localizable", "unsupported_device_body")
  /// Další informace
  internal static let unsupportedDeviceButton = L10n.tr("Localizable", "unsupported_device_button")
  /// Nová verze aplikace eRoušky funguje pouze na telefonech s operačním systémem iOS a Android.
  internal static let unsupportedDeviceIpadBody = L10n.tr("Localizable", "unsupported_device_ipad_body")
  /// Tablety s operačním systémem iPadOS nejsou podporované
  internal static let unsupportedDeviceIpadTitle = L10n.tr("Localizable", "unsupported_device_ipad_title")
  /// Vaše zařízení nepodporuje iOS 13.5 nebo novější
  internal static let unsupportedDeviceTitle = L10n.tr("Localizable", "unsupported_device_title")
  /// verze
  internal static let version = L10n.tr("Localizable", "version")
  /// Pokračovat k aktivaci
  internal static let welcomeActivation = L10n.tr("Localizable", "welcome_activation")
  /// Aplikace bude nepřetržitě monitorovat vaše okolí a zaznamenávat všechny ostatní telefony s aplikací eRouška, ke kterým se přiblížíte.\n\nPokud se u majitele kteréhokoliv z nich potvrdí onemocnění COVID-19, eRouška vyhodnotí, zda se jedná o rizikový kontakt a upozorní vás.\n\nKdyž se potvrdí nákaza u vás, eRouška upozorní všechny ostatní uživatele aplikace, se kterými jste se potkali.
  internal static let welcomeBody = L10n.tr("Localizable", "welcome_body")
  /// Více o nezávislých auditech
  internal static let welcomeBodyMore = L10n.tr("Localizable", "welcome_body_more")
  /// Jak to funguje
  internal static let welcomeHelp = L10n.tr("Localizable", "welcome_help")
  /// Díky eRoušce ochráníte sebe i ostatní ve svém okolí
  internal static let welcomeTitle = L10n.tr("Localizable", "welcome_title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
