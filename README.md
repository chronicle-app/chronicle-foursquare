# Chronicle::Foursquare
[![Gem Version](https://badge.fury.io/rb/chronicle-foursquare.svg)](https://badge.fury.io/rb/chronicle-foursquare)

Extract your Foursquare/Swarm history using the command line with this plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl).

## Usage

### 1. Install Chronicle-ETL and this plugin

```sh
# Install chronicle-etl and this plugin
$ gem install chronicle-etl
$ chronicle-etl plugins:install foursquare
```

### 2. Create a Foursquare App
To get access to the Foursquare API, you must first create an app. Press the "Create New Project" button in the [Developer Home](https://foursquare.com/developers/home).

In the app's setting, in the `Redirect URIs` field, add `http://localhost:4567/auth/foursquare/callback`. After your app has been saved, grab the `client_id` and `client_secret` credentials and save them to chronicle-etl secrets:

```sh
$ chronicle-etl secrets:set foursquare client_id
$ chronicle-etl secrets:set foursquare client_secret
```

### 3. Authorize Foursquare

Next, we need an access token for accessing your data. We can use the authorization flow:

```sh
$ chronicle-etl authorizations:new foursquare
```

This will open a browser window to authorize on foursquare.com. When the flow is complete, access/refresh tokens will be saved in the chronicle secret system under the "foursquare" namespace. It'll be available automatically whenever you use this plugin.

### 4. Use the the plugin
```sh
# Extract recent checkins
$ chronicle-etl --extractor foursquare --since 1w
# Transform as Chronicle Schema
$ chronicle-etl --extractor foursquare --since 1w --transformer foursquare --loader json
```

## Available Connectors

### Extractors

#### `checkins`

Extractor for your Foursquare (via the Swarm app) checkins

##### Settings
- `access_token`: (required) API access token for foursquare. By default, it's loaded from secrets under the `foursquare` namespace. You can check if it's available with `chronicle-etl secrets:list foursquare`

### Transformers

#### `visit`

Transform a visit into Chronicle Schema
