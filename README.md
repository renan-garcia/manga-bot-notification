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

Create an .env file and add TELEGRAM_TOKEN, NEOX_COOKIE, FIREBASE_URL, FIREBASE_PRIVATE_KEY_BASE64 and CHAT_ID inside them.

## Run

```shell
bundle exec unicorn -c config/unicorn.rb
```

## Deploy

### With Heroku pipeline (recommended)

Push to Heroku staging remote:

```shell
git push heroku-staging
```

Go to the Heroku Dashboard and [promote the app to production](https://devcenter.heroku.com/articles/pipelines) or use Heroku CLI:

```shell
heroku pipelines:promote -a project-staging
```

### Directly to production (not recommended)

Push to Heroku production remote:

```shell
git push heroku
```
