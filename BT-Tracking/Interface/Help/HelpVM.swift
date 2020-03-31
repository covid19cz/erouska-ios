//
//  HelpVM.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift

class HelpVM {

    struct HelpData {
        let index: Int
        let title: String
        let description: String
    }

    var notes: [HelpData] = []

    init() {
        notes = [
            "00Proč je eRouška potřeba? Dokáže mě vůbec efektivně uchránit před nákazou?":
            """
            Cílem aplikace eRouška je zpomalit a ideálně zastavit šíření nákazy. Pomáhá co nejdříve izolovat potenciálně nakažené osoby od ostatních. Tím přispívá k postupnému uvolňování celostátní karantény a snížení dopadů pandemie na společnost a ekonomiku ČR. Aplikace na podobném principu fungují i v dalších státech a většinou jsou velmi účinným prostředkem v boji proti šíření koronaviru.

            Aplikace eRouška je jeden ze tří konceptů, které COVID19CZ používá, a je z nich nejšetrnější k soukromí. Aplikace se přes Bluetooth spojí s dalšími telefony s eRouškou v nejbližším okolí a uloží jejich identifikátory. Pokud bude později některý z uživatelů eRoušky označen pracovníkem hygieny za pomoci testů jako nakažený, epidemiologický model vyhodnotí, zda jste s ním přišli do kontaktu dost dlouho na to, aby bylo nutné vás varovat a směřovat k dalšímu vyšetření.

            eRouška tedy pomáhá pracovníkům hygienické stanice co nejefektivněji identifikovat potenciální přenašeče viru a na dobu nezbytně nutnou je požádat o izolaci a opatrnost. Tím se sníží počet infikovaných ve společnosti a tím i vaše riziko infekce.
            """,
            "01Má smysl si eRoušku instalovat, když ji nebude používat dost lidí?":
            """
            Funguje to jako běžné roušky - čím více nás bude eRoušku používat, tím lépe bude fungovat. Spolupracujeme s vládou ČR a dalšími organizacemi tak, aby se o eRoušce dozvědělo co nejvíce lidí a začali ji používat. Pomozte nám i vy. Instalací aplikace se můžete aktivně zapojit do boje proti koronaviru.

            Požádejte také své okolí o instalaci aplikace, popřípadě jim s jejich souhlasem rovnou pomozte s instalací. Čím více lidí z vašeho přímého okolí bude aplikaci využívat, tím lépe se budete navzájem chránit.
            """,
            "02eRouška potřebuje běžet i když s ní právě nepracujete":
            """
            Váš telefon automaticky vypíná některé aplikace pokud s nimi nepracujete, kvůli úspoře baterie.

            Povolte běh aplikace na pozadí v nastavení telefonu. Návod pro svůj telefon najdete zde.
            """,
            "03Jak se eRouška liší od jiných podobných aplikací?":
            """
            Aplikace eRouška místo určení vaší polohy využívá princip mapování ostatních zařízení s aplikací eRouška v okolí využitím technologie Bluetooth. Tyto informace jsou anonymizované. Zapsaná informace vypadá např. takto: 31.3.2020 od 12:15 do 13:15 byla ve vaší blízkosti aplikace s identifikátorem ID 29091. Z dat aplikace eRouška nelze zjistit kdy a kde jste se pohybovali. Aplikace tedy funguje také tam, kde není signál GPS, např. v garážích, metru atd.

            Kromě toho eRouška sama od sebe informace nikam neodesílá, zůstávají uložené ve vašem zařízení. Ke sdílení dat s hygienickou stanicí může dojít až ve chvíli, kdy vás pracovník hygieny kontaktuje na základě pozitivního testu a požádá vás o souhlas se zpracováním dat, která aplikace sesbírala. Na základě tohoto požadavku pak přímo z aplikace odešlete vámi nasbíraná data do centralizované databáze hygienické stanice.

            Takto sdílená data vyhodnotí pověřený pracovník hygienické stanice. Registrované uživatele aplikace eRouška, kteří se od vás vyskytovali delší dobu v kritické vzdálenosti, kontaktuje pracovník hygienické stanice na jimi registrované číslo v aplikaci eRouška s pokyny dalšího postupu.
            """,
            "04Proč chce aplikace znát mé telefonní číslo?":
            "Telefonní číslo využije hygienická stanice, aby vás mohla v případě potřeby co nejdříve kontaktovat. To nastane jen tehdy, pokud bude mít na základě informací z eRoušky nakaženého člověka podezření, že jste s ním byli v rizikovém kontaktu. Proto telefonní číslo registrujete hned při první spuštění eRoušky.",
            "05Jak mám postupovat, když mi test potvrdí nákazu?":
            """
            V první řadě kontaktujte hygienickou stanici, pod kterou místně spadáte, pokud vás již nekontaktovala sama. Hygiena vám poskytne informace o tom, jak dále postupovat, a případně vás požádá o souhlas se sdílením dat z aplikace. Dále byste měli zavolat svému obvodnímu lékaři, který vám indikuje léčbu.

            V případě závažných zdravotních komplikací volejte linky 112 a 155.

            Aktuální informace se dozvíte vždy na celostátní informační telefonní lince: 1212 nebo na webu Ministerstva zdravotnictví ČR - https://koronavirus.mzcr.cz/.
            """,
            "06Takže všichni budou vědět, že mám COVID19? To mě zlynčují…":
            """
            Nebudou. Pracovník hygienické stanice kontaktuje registrované uživatele, se kterými přišel nakažený podle dat z aplikace do rizikového kontaktu, projde s nimi epidemiologické šetření a podle míry epidemiologické závažnosti kontaktu nastaví další opatření. Informaci o tom, kdo je nakažený, nesmí hygienická stanice bez vašeho souhlasu s nikým sdílet. Další uživatelé se ani nedozví kdy a kde přišli s nakaženým do kontaktu.
            """,
            "07Co když někdo nepřizná, že je nemocný?":
            "I to se může stát. Věříme však, že uživatelé eRoušky chtějí aktivně pomáhat se zastavením dalšího šíření nákazy a aplikaci využijí, aby mohli co nejdřívě varovat osoby, které s nimi přišly do rizikového kontaktu.  Záměrné šíření koronaviru je v ČR považováno za trestný čin.",
            "08Co je to inteligentní/chytrá karanténa? Jakou v ní hraje roli eRouška?":
            """
            Jde o soubor chytrých opatření, která chrání lidi před nákazou a ekonomiku před kolapsem. Místo toho, aby do karantény uvrhla celý národ, do striktní karantény izoluje pouze nemocné a z nemoci důvodně podezřelé lidi. Pomocí dostupných technologií pak následně můžeme aktivně upozornit rizikové jedince, kteří se setkali s nakaženým a i je dát do preventivní karantény, a tím zamezit skokovému šíření nákazy. Důsledné testování pak rozdělí zdravé od těch, kteří jsou nakažení a potřebují další zdravotnickou péči. Díky těmto krokům věříme, že se podaří zmírnit šíření nákazy a ušetřit zdravotnictví fatálního přetížení.

            eRouška je jeden z projektů, který vznikl na podporu chytré karantény.
            """,
            "09Pozná eRouška, když poruším lékařem nařízenou karanténu nebo třeba pojedu na chatu?":
            "Aplikace nesleduje vaši polohu, není to její účel a ani pro to není navržena. Nepozná tedy, zda jste porušili karanténní opatření nebo odjeli na chatu. Má naopak pomoci k tomu, aby v karanténě byly pouze osoby s diagnostikovaným onemocněním nebo s vážným podezřením nákazy.",
            "10Jak dlouho do minulosti jsou data k dispozici? Kdy a jak probíhá jejich mazání?":
            "Dobu, po kterou zůstávají sesbíraná data uložená ve vaší aplikaci eRouška, případně na serveru, pokud je tam odešlete, naleznete v Zásadách zpracování údajů. Jsou zde i informace o provozovatelích serverů a správcích dat.",
            "11Co když mi telefon ukradnou nebo ho ztratím?":
            "V aplikaci eRouška jsou lokálně uložené jen anonymní informace o dalších zařízeních, která eRouška zaznamenala ve svém okolí. Žádné riziko to nepřináší pro vás ani pro majitele takto zaznamenaných zařízení. Jiné aplikace, které běžně využíváte, ve vašem telefonu pravděpodobně ukládají mnohem citlivější údaje. Mějte proto svůj telefon chráněný kódem nebo biometricky (otiskem prstu nebo obličejem).",
            "12Je aplikace eRouška v souladu s GDPR?":
            "Celý systém aplikace eRouška včetně podpůrných webových stránek jsou navržené plně v souladu se Zákonem o ochraně osobních údajů a GDPR.",
            "13Na jakých telefonech aplikace eRouška funguje?":
            """
            Pokud váš telefon není s eRouškou kompatibilní, Google Play ani App Store vám neumožní aplikaci nainstalovat.
            Pro instalaci aplikace eRouška potřebujete chytrý telefon s těmito parametry:
            
            - iOS verze 11 a vyšší
            
            - OS Android verze 5.0 a vyšší s Google services (nemá jen malé procento telefonů Huawei)
            
            - Bluetooth LE (Low Energy)*
            
            *Některé starší modely telefonů (např. Google Nexus 5) mohou fungovat jen částečně - vidí přes Bluetooth telefony v okolí, ale ostatní smartphony je bohužel zpětně nevidí. Důvodem je, že ještě nejsou vybavené funkcí Bluetooth LE Advertising. I přesto má jejich použití smysl.
            """,
            "14Jak probíhá sběr dat a jejich zpracování?":
            """
            Chytrý telefon s aplikací eRouška zaznamená přes Bluetooth anonymní identifikátor (ID) z jiných zařízení s touto aplikací, pokud jsou blíže než cca 4 metry. Informaci o “setkání” a jeho délce ukládá do své vnitřní paměti. Zapsaná informace vypadá např. takto: 31.3.2020 od 12:15 do 13:15 byla ve vaší blízkosti aplikace s identifikátorem ID 29091.

            Seznam těchto “setkání” můžete odeslat do centrální databáze hygieny v případě, že budete osloveni hygienickou stanicí z důvodu pozitivního testu nebo kvůli podezření na rizikový kontakt s nakaženým. Do centrální databáze hygieny mají přístup jen její pověření pracovníci. Ti mohou spojit identifikátor aplikace s registrovaným telefonním číslem a upozornit ty uživatele eRoušky, kteří s vámi přišli do rizikového kontaktu.

            Pracovníci hygieny tedy vidí, že např. ID 29091 je propojeno s telefonním číslem 606 123 456.
            """,
            "15Musím mít Bluetooth zapnutý neustále?":
            "Ano. Bez zapnutého Bluetooth není možné zjišťovat blízkost dalších zařízení s nainstalovanou aplikací eRouška. Tuto funkci máte zapnutou možná i nyní, například v případě, že používáte bezdrátová sluchátka, připojení v autě, chytrý náramek nebo hodinky.",
            "16Kolik baterie aplikace a zapnutý Bluetooth spotřebují?":
            """
            Jestliže již nyní používáte telefon se stále zapnutým Bluetooth, spotřeba energie se nezvýší.

            Pokud Bluetooth nyní běžně nepoužíváte, podle výsledků našeho testování s neustále zapnutým Bluetooth a ukládáním dat do aplikace byla denní spotřeba energie v řádu jednotek procent. Ve většině případů to je méně než 15 % kapacity baterie za den. Záleží přitom na konkrétním chytrém telefonu, stylu jeho používání a stavu baterie.
            """,
            "17Proč aplikace používá zrovna Bluetooth? Neexistuje lepší řešení jako GPS nebo triangulace od operátorů?":
            "Soukromí uživatelů je pro nás na prvním místě a právě technologie Bluetooth nabízí nejvyváženější poměr přesnosti záznamu a minimálního zásahu do soukromí. Technologie GPS, ani triangulace vysílačů od operátorů nemohou poskytnout potřebné údaje s požadovanou přesností. Mimo jiné i proto, že jejich funkčnost je v budovách, garážích či metru velmi omezená. Aplikace eRouška potřebuje pro svoji funkci informace o tom, že došlo k setkání, na jakou vzdálenost a po jakou dobu. Není důležité, kde k setkání došlo.",
            "18Nemůže se stát, že eRouška mylně vyhodnotí kontakt s jinou osobou, která je například vedle v autě na křižovatce, za dveřmi nebo tenkou zdí?":
            "Aplikace eRouška funguje na principu měření síly signálu mezi dvěma zařízeními. Technicky nelze vyloučit, že dojde k mylné detekci - například blízký kontakt skrz tenkou zeď se podobá vzdálenějšímu kontaktu bez překážky. Těmto omylům, byť jsou výjimečné, se nedá úplně zabránit. Pracovníci hygienické stanice jsou s tímto jevem seznámeni a pracují s ním při telefonickém rozhovoru s rizikovými kontakty nakaženého.",
            "19Proč je potřeba aplikaci povolit přístup k GPS/polohovým/lokačním údajům?":
            "Aplikace eRouška nesbírá a neukládá data z GPS. Avšak operační systém Android zahrnuje pod určování polohy také některé služby Bluetooth LE (LE = low energy), které eRouška pro své fungování potřebuje. Proto je nutný souhlas uživatele s přístupem aplikace k polohovým údajům. V iOS tento souhlas nutný není. Více informací je k dispozici na webu OS Android pro vývojáře.",
            "20Může mě někdo pomocí aplikace eRouška sledovat?":
            "Ne. Aplikace nesbírá údaje o vaší poloze a k uloženým datům máte přístup pouze vy. Samotné údaje, které aplikace po vašem souhlasu odesílá, nemohou být použity k vašemu sledování. Aplikace automaticky ukládá pouze informace typu: 31.3.2020 od 12:15 do 13:15 byla ve vaší blízkosti aplikace s identifikátorem ID 29091.",
            "21Lze ověřit, že aplikace nezaznamenává moji polohu?":
            """
            Ano. Nasbíraná data lze kdykoli zobrazit v záložce Moje data. Aplikace eRouška je publikována s otevřeným zdrojovým kódem, takže znalý člověk může snadno ověřit, že údaje o poloze opravdu nesbíráme.

            Zdrojové kódy aplikace eRouška byly prověřeny nezávislými autoritami, jejichž kontrola potvrdila, že aplikace nesleduje polohu, sama automaticky data nikam neodesílá, funguje offline, detekuje jen další eRoušky v okolí a ne každé Bluetooth zařízení, atp.
            """,
            "22Lze identifikátor aplikace (ID) uživatele spárovat s konkrétní osobou?":
            "ID eRoušky lze spojit pouze s konkrétním zařízením a telefonním číslem uživatele. A to pouze u těch ID, které na základě sdílení dat od nakažených uživatelů pracovníci hygienické stanice vyhodnotí jako ohrožené nákazou koronavirem. Tuto pravomoc mají jenom určení pracovníci hygienické stanice. Do systému se přihlašují pomocí osobního uživatelského jména a zabezpečeného hesla.",
            "23Kdo má (může mít) přístup k mým datům?":
            "K seznamu setkání máte přístup pouze vy. Až když se dobrovolně na vyzvání rozhodnete odeslat tato data hygienické stanici, přístup získají také její pověření pracovníci.",
            "24Jak zjistím, která všechna data přesně aplikace ukládá a odesílá hygienické stanici?":
            "Nasbíraná data lze kdykoli v aplikaci zobrazit v záložce Moje data. Aplikace žádná data sama nikam neodesílá.",
            "25Jak uživatele chráníte před zneužitím dat?":
            "Uživatele chráníme především minimálním rozsahem zaznamenávaných dat a jejich ukládáním přímo do zařízení. Data uživatelů se bez jejich vědomí, aktivního odeslání a souhlasu nikam neposílají ani nezpracovávají. Do telefonu se zaznamenávají anonymní identifikátory (ID) zařízení s nainstalovanou aplikaci eRouška a informace o čase a délce jejich výskytu v blízkosti uživatele. Zpracovat je mohou po výslovném souhlasu uživatele jen určení pracovníci hygieny.",
            "26Dohlíží na zabezpečení dat z aplikace nějaká nezávislá organizace?":
            "Ano. Celý systém aplikace eRouška, včetně podpůrných webových stránek, je navržený plně v souladu se Zákonem o ochraně osobních údajů a GDPR. Kód aplikace je volně otevřený (open-source) a prošel auditem nezávislých vzdělávacích institucí. Další informace naleznete v Zásadách ochrany soukromí aplikace a webu eRouška a v Závazku datové důvěry iniciativy COVID19CZ.",
            "27Můžu si používání aplikace kdykoli rozmyslet? Budu moci smazat své telefonní číslo a data, která jsem předal hygienikům?":
            "Ano. V aplikaci je možné smazat veškerá nasbíraná data - jak z vašeho zařízení, tak i ze serveru hygieniků. Stejně tak je možné smazat telefonní číslo, které jste poskytli při aktivaci aplikace. Vám přidělené ID eRoušky ovšem zůstane zaznamenáno v eRouškách ostatních uživatelů, kteří vás potkali. Toto ID ale nebude nadále možné přiřadit k žádnému telefonu, telefonnímu číslu ani osobě.  Pamatujte ale, že po smazání čísla vás nebudou moci hygienici kontaktovat v případě podezření na rizikové setkání s nakaženou osobou.",
            "28Co se bude dít s daty, až pandemie skončí?":
            "Provozovatel aplikace všechna data smaže nejpozději po skončení pandemie. O ukončení pandemie, respektive možnosti odesílání dat a jejich ukládání do databáze, rozhodnou orgány státní správy. Vy můžete všechna sesbíraná data i registrované telefonní číslo smazat kdykoliv přímo z aplikace eRouška. Stejně tak se můžete kdykoliv rozhodnout a přestat aplikaci zcela používat."
            ]
            .map{ item in
                let indexString = String(item.key.prefix(2))
                let index = Int(indexString) ?? 0
                let title = String(item.key.dropFirst(2))
                return HelpData(index: index, title: title, description: item.value)
            }
            .sorted(by: { $0.index < $1.index })
    }

    var sections: Driver<[SectionModel]> {
        let items = notes.map { HelpVM.Section.Item.main($0) }
        return Driver.just([SectionModel(model: .list, items: items)])
    }
}

extension HelpVM {

    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    enum Section: IdentifiableType, Equatable {
        case list

        var identity: String {
            switch self {
            case .list:
                return "list"
            }
        }

        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }

        enum Item: IdentifiableType, Equatable {
            case main(HelpData)

            var identity: String {
                switch self {
                case .main(let data):
                    return data.title
                }
            }

            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity
            }
        }
    }
}
