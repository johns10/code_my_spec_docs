# Faker.Internet.UserAgent

Functions for generating user agent strings

## user_agent/0

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