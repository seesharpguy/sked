.PHONY: build

clean:
	flutter clean
	flutter pub get

upgrade:
	flutter packages upgrade

start:
	 flutter run -d chrome --web-port=5000

build:
	 flutter build web

emulator:
	firebase emulators:start
