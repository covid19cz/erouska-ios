![# eRouška](https://erouska.cz/img/logo.svg)

![Platform: iOS](https://img.shields.io/badge/platform-ios-brightgreen)

[![Download on the App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/cz/app/erouška/id1509210215)

Read our **FAQ**: [Czech](https://erouska.cz/caste-dotazy), [English](https://erouska.cz/en/caste-dotazy)

eRouška (_rouška_ = _face mask_ in Czech) helps to fight against COVID-19.

eRouška uses Bluetooth to scan the area around the device for other eRouška users and saves the data of these encounters.

It's the only app in Czechia authorized to use Exposure Notifications API from Apple/Google.

## Who is developing eRouška?

Starting with version 2.0, the eRouška application is developed by the Ministry of Health in collaboration with the National Agency for Communication and Information Technologies ([NAKIT](https://nakit.cz/)). Earlier versions of eRouška application were developed by a team of volunteers from the [COVID19CZ](https://covid19cz.cz) community. Most of original eRouška developers continue to work on newer versions in the NAKIT team.

## International cooperation

We are open-source from day one and we will be happy to work with people in other countries if they want to develop a similar app. Contact [David Vávra](mailto:david.vavra@erouska.cz) for technical details.

## Building the App from the source code

Exposure notifications work only with approved Ministry account.

You can build using your own account when you delete `com.apple.developer.exposure-notification` entitlement from `project.yml` file under `targets` -> `eRouska Dev` -> `entitlements` -> `properties` and change code signing to your account.

### Command line dependencies

We use `Bundler` and `Mint` to manage command line tools. 

### Project generation

`xcodgen` is used to generate project files and etitlements. To generate a project workspace, run `./setup.sh` in the project root directory. It will generate project files and install all needed dependencies. Do not run `pod install` manually anymore. Use the `setup.sh` script or run `bundle pod install` instead.

### Code signing

To update your code signing settings, you would need to copy template `.xcconfig` files from `Configs/Templates/` directory to `Configs/` directory and fill them with proper values. `xcodegen` is looking for these files in `Configs` directory and use them in project generation. All `.xcconfig` files in `Configs` directory are ignored by git, so you don't have to worry about accidentally pushing your code signing settings or pulling somebody elses.

## Contributing

We are happy to accept pull requests! See [Git Workflow](#user-content-git-workflow).

If you want to become a more permanent part of the team, join [our Slack](https://covid19cz.slack.com), channel _#erouska_.

## Translations

Help us translate to your language or if you see a problem with translation, fix it. Our translation is open to volunteers [at OneSky](https://covid19cz.oneskyapp.com/).

## Git workflow

- Work in a fork then send a pull request to the `develop` branch. 
- Releases are tagged.
