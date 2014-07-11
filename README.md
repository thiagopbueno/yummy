## yummy

> A CLI-based tool in Ruby for managing your social bookmarkings, because you're just looking delicious...

### Features

It supports Delicious [OAuth 2.0](https://github.com/SciDevs/delicious-api/blob/master/api/oauth.md), given that you already have your **ACCESS_TOKEN**.

_See below for more information on how to get you one!_

Currently supported API requests (through the [DeliciousAPI wrapper](https://github.com/thiagopbueno/yummy/blob/master/lib/delicious.rb)):
* [/v1/posts/all?](https://github.com/SciDevs/delicious-api/blob/master/api/posts.md#v1postsall) for getting posts for a list of tags (i.e. ruby+delicious+api)
* [/v1/posts/dates?](https://github.com/SciDevs/delicious-api/blob/master/api/posts.md#v1postsdates) for getting dates and counts for a tag
* [/v1/tags/get](https://github.com/SciDevs/delicious-api/blob/master/api/tags.md#v1tagsget) for getting a list of tags and counts

### Config && Install

Create a config.yml file containing your **ACCESS_TOKEN** and run bundle install.

`$ echo >config.yml "ACCESS_TOKEN: YOUR_ACCESS_TOKEN"`

`$ bundle install`

### Usage

`$ ./yummy [OPTIONS]`

**OPTIONS**

    -o, --object (tags|posts|dates)  Choose between list of 'tags', 'posts' or 'posts/dates'
    -t, --tags tag1+tag2+...         Set list of tags (separated by '+') for posts
    -n, --max MAX                    Set maximum number of tags/posts
    -s, --start-date START_DATE      Set start date for all API requests
    -e, --end-date END_DATE          Set end date for all API requests
    -h, --help                       Display this information

All dates must be provided in the format 'YYYY-MM-DD'


### Getting your ACCESS_TOKEN

These instructions are based on [Delicious'](https://github.com/SciDevs/delicious-api/blob/master/api/oauth.md). Please feel free to report to it in case of difficulties or problems.

1. Set a new app at [https://delicious.com/settings/developer](https://delicious.com/settings/developer)
1. Get your **Client ID** and **Client Secret**
1. Send a request to Delicious for users' authorization
    * `https://delicious.com/auth/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=http://www.example.com/redirect`
1. Get your **REQUEST_TOKEN**
1. Exchange ACCESS_TOKEN with REQUEST_TOKEN returned to you in last step
    * `https://avosapi.delicious.com/api/v1/oauth/token?client_id=YOUR_CLIENT_ID&client_secret=YOUR_SECRET_ID&grant_type=code&code=YOUR_REQUEST_TOKEN`
1. Get your **ACCESS_TOKEN**

Please note that step 5. needs to be done using a [POST request](https://en.wikipedia.org/wiki/POST_(HTTP)).
You can use the [Firefox addon poster](https://addons.mozilla.org/en-US/firefox/addon/poster/), [hurl.it](http://www.hurl.it/) or any other tools you might like.

Finally, you cant test it with cURL

`curl -v -H "Authorization: Bearer YOUR_ACCESS_TOKEN" --url "https://api.delicious.com/v1/posts/all?tag=ruby&results=5"`