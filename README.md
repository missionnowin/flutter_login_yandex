# flutter_login_yandex
Originaly by spChief </br>
Flutter plugin for authorization with Yandex LoginSDK for iOS and Android

## Getting Started
1. Add flutter_login_yandex to your pubspec.yaml file
2. Register Yandex OAuth application, see [official docs](https://dev-id.docs-viewer.yandex.ru/ru/mobileauthsdk/ios/2.1.0/sdk-ios)
3. Setup android
4. Setup ios 

## YandexLoginSDK version in plugin:
- iOS: 3.0.1
- Android: 2.5.1

## Minimum requirements
- IOS 12.0
- ANDROID minSdkVersion 21

## SDK documentation
- https://yandex.ru/dev/id/doc/ru/mobileauthsdk/about

## Android setup
Add to your android/app/build.gradle default section this with replacement of yourClientId to Yandex OAuth app client id:
```
manifestPlaceholders += [YANDEX_CLIENT_ID:"yourClientId"]
```

It must looks like this:
```
defaultConfig {
    applicationId "com.example.flutter_login_yandex_example"
    minSdkVersion flutter.minSdkVersion
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
    manifestPlaceholders += [YANDEX_CLIENT_ID:"yourClientId"]
}
```

## iOS setup
Add this to your app Info.plist and replace "yourCientId" with Yandex client id from OAuth application
```xml
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>primaryyandexloginsdk</string>
		<string>secondaryyandexloginsdk</string>
	</array>
	<key>YAClientId</key>
	<string>yourClientId</string>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>YandexLoginSDK</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>yxyourClientId</string>
			</array>
		</dict>
	</array>
```

Also you need to set up Entitlements, add *Capability: Associated Domains* and enter domain with replaced yourClientId to your value:
```
applinks:yxyourClientId.oauth.yandex.ru
```

## Usage

```
final flutterLoginYandexPlugin = FlutterLoginYandex();
final response = await _flutterLoginYandexPlugin.signIn();
saveToken(response['token'] as String);
```
