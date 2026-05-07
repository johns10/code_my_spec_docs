# Faker.Internet.UserAgent

Functions for generating user agent strings

## bot_user_agent()

Returns a user agent string for a bot/crawler

## Examples

    iex> Faker.Internet.UserAgent.bot_user_agent()
    "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
    iex> Faker.Internet.UserAgent.bot_user_agent()
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    iex> Faker.Internet.UserAgent.bot_user_agent()
    "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"
    iex> Faker.Internet.UserAgent.bot_user_agent()
    "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"

## desktop_user_agent()

Returns a user agent string for a desktop browser

## Examples

    iex> Faker.Internet.UserAgent.desktop_user_agent()
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"
    iex> Faker.Internet.UserAgent.desktop_user_agent()
    "Mozilla/5.0 (X11; CrOS x86_64 8172.45.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.64 Safari/537.36"
    iex> Faker.Internet.UserAgent.desktop_user_agent()
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"
    iex> Faker.Internet.UserAgent.desktop_user_agent()
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1"

## ereader_user_agent()

Returns a user agent string for an e-reader

## Examples

    iex> Faker.Internet.UserAgent.ereader_user_agent()
    "Mozilla/5.0 (X11; U; Linux armv7l like Android; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/533.2+ Kindle/3.0+"
    iex> Faker.Internet.UserAgent.ereader_user_agent()
    "Mozilla/5.0 (Linux; U; en-US) AppleWebKit/528.5+ (KHTML, like Gecko, Safari/528.5+) Version/4.0 Kindle/3.0 (screen 600x800; rotate)"
    iex> Faker.Internet.UserAgent.ereader_user_agent()
    "Mozilla/5.0 (Linux; U; en-US) AppleWebKit/528.5+ (KHTML, like Gecko, Safari/528.5+) Version/4.0 Kindle/3.0 (screen 600x800; rotate)"
    iex> Faker.Internet.UserAgent.ereader_user_agent()
    "Mozilla/5.0 (X11; U; Linux armv7l like Android; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/533.2+ Kindle/3.0+"

## game_console_user_agent()

Returns a user agent string for a game console

## Examples

    iex> Faker.Internet.UserAgent.game_console_user_agent()
    "Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.12 NintendoBrowser/4.3.1.11264.US"
    iex> Faker.Internet.UserAgent.game_console_user_agent()
    "Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/13.10586"
    iex> Faker.Internet.UserAgent.game_console_user_agent()
    "Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.12 NintendoBrowser/4.3.1.11264.US"
    iex> Faker.Internet.UserAgent.game_console_user_agent()
    "Mozilla/5.0 (Nintendo 3DS; U; ; en) Version/1.7412.EU"

## mobile_user_agent()

Returns a user agent string for a mobile device

## Examples

    iex> Faker.Internet.UserAgent.mobile_user_agent()
    "Mozilla/5.0 (Linux; Android 6.0.1; SM-G920V Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.36"
    iex> Faker.Internet.UserAgent.mobile_user_agent()
    "Mozilla/5.0 (Linux; Android 6.0; HTC One M9 Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.36"
    iex> Faker.Internet.UserAgent.mobile_user_agent()
    "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 6P Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.83 Mobile Safari/537.36"
    iex> Faker.Internet.UserAgent.mobile_user_agent()
    "Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/13.10586"

## set_top_user_agent()

Returns a user agent string for a set top device

## Examples

    iex> Faker.Internet.UserAgent.set_top_user_agent()
    "Mozilla/5.0 (CrKey armv7l 1.5.16041) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.0 Safari/537.36"
    iex> Faker.Internet.UserAgent.set_top_user_agent()
    "Mozilla/5.0 (Linux; U; Android 4.2.2; he-il; NEO-X5-116A Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"
    iex> Faker.Internet.UserAgent.set_top_user_agent()
    "Mozilla/5.0 (CrKey armv7l 1.5.16041) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.0 Safari/537.36"
    iex> Faker.Internet.UserAgent.set_top_user_agent()
    "AppleTV5,3/9.1.1"

## tablet_user_agent()

Returns a user agent string for a tablet

## Examples

    iex> Faker.Internet.UserAgent.tablet_user_agent()
    "Mozilla/5.0 (Linux; Android 7.0; Pixel C Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/52.0.2743.98 Safari/537.36"
    iex> Faker.Internet.UserAgent.tablet_user_agent()
    "Mozilla/5.0 (Linux; Android 5.0.2; LG-V410/V41020c Build/LRX22G) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/34.0.1847.118 Safari/537.36"
    iex> Faker.Internet.UserAgent.tablet_user_agent()
    "Mozilla/5.0 (Linux; Android 5.0.2; SAMSUNG SM-T550 Build/LRX22G) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/3.3 Chrome/38.0.2125.102 Safari/537.36"
    iex> Faker.Internet.UserAgent.tablet_user_agent()
    "Mozilla/5.0 (Linux; Android 5.1.1; SHIELD Tablet Build/LMY48C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Safari/537.36"

## user_agent()

Returns a user agent string

## Examples

    iex> Faker.Internet.UserAgent.user_agent()
    "Mozilla/5.0 (Linux; Android 6.0; HTC One M9 Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.36"
    iex> Faker.Internet.UserAgent.user_agent()
    "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
    iex> Faker.Internet.UserAgent.user_agent()
    "Mozilla/5.0 (X11; U; Linux armv7l like Android; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/533.2+ Kindle/3.0+"
    iex> Faker.Internet.UserAgent.user_agent()
    "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"