# manga-bot-notification

## Install

### Clone the repository

```shell
git clone git@github.com:renan-garcia/manga-bot-notification.git
cd manga-bot-notification
```

### Check your Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.7.2`

If not, install the right ruby version using [rbenv](https://github.com/rbenv/rbenv) (it could take a while):

```shell
rbenv install 2.7.2
```

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler):

```shell
bundle install
```

### Set environment variables

Create an .env file and add TELEGRAM_TOKEN, NEOX_COOKIE and CHAT_ID inside them.

## Run

```shell
pry bot.rb
```

## Deploy

### In development, feel free to pull requests
