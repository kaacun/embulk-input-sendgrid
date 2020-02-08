# Sendgrid input plugin for Embulk

Embulk input plugin for SendGrid stats

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **api_key**: SendGrid API Key that requires Stats read permission (string, required)
- **start_date**: Start date for loading data, e.g. 2020-01-01(string, required)
- **end_date**: End date for loading data, e.g. 2020-02-01 (string, default: `today`)

## Example

```yaml
in:
  type: sendgrid
  api_key: YourAPIKey
  start_date: 2020-01-01
  end_date: 2020-02-01
```


## Build

```
$ rake build
```
