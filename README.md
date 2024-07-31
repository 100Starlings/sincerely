# Sincerely
## Introduction
Sincerely is a versatile Ruby gem designed for creating, delivering and monitoring email, sms or push notifications.

## Table of Contents
1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [Notification statuses](#notification-statuses)
6. [Callbacks](#callbacks)
7. [How to Run Tests](#how-to-run-tests)
8. [Guide for Contributing](#guide-for-contributing)
9. [How to Contact Us](#how-to-contact-us)
10. [License](#license)

## Installation
Sincerely 1.0 works with Rails 6.0 onwards. Run:
```bash
bundle add sincerely
```

## Getting Started

1. First, you need to run the install generator, which will create the `config/sincerely.yml` initializer file for you:
```bash
rails g sincerely:install
```

2. You need to generate and run a migration to create the `notifications` and `notification_templates` tables and the `Notification` and the `NotificationTemplate` model:
```bash
rails g sincerely:migration Notification

rails db:migrate
```

3. If you want to enable event callbacks you need to run the `events` task to create the `sincerely_delivery_events` table and the `Sincerely::DeliveryEvent` model:
```bash
rails g sincerely:events

rails db:migrate
```

## Configuration
1. You need to set the notification model generated in the previous step by setting the `notification_model_name` option in the `config/sincerely.yml` file:

```
# config/sincerely.yml
defaults: &defaults
  notification_model_name: Notification
```

2. You need to set the delivery system for each delivery methods (email/sms/push) by setting the `delivery_methods` option in the `config/sincerely.yml` file. Please note that right now the gem supports only AWS SES email notification (`Sincerely::DeliverySystems::EmailAwsSes` module).

```
# config/sincerely.yml
defaults: &defaults
  delivery_methods:
    email:
      delivery_system: Sincerely::DeliverySystems::EmailAwsSes
      options:
        region: region
        access_key_id: your_access_key_id
        secret_access_key: your_secret_access_key
        configuration_set_name: config_set
    sms:
```

* `region`: the AWS region to connect to
* `access_key_id`: AWS access key id
* `secret_access_key`: AWS secret access key
* `configuration_set_name`: the name of the configuration set to use when sending the email, you don't need to specify the configuration set option if you don't want to handle SES email sending events

Sincerely uses the `aws-sdk-sesv2` gem to send emails. See [sesv2](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SESV2.html) for details.

## Usage

1. Once the email delivery method is configured you need to create an email template which is used to generate the email content:

```
Sincerely::Templates::EmailLiquidTemplate.create(
  name: 'test',
  subject: 'template for sending messages',
  sender: 'john.doe@gmail.com'
  html_content: 'hi {{name}}',
  text_content: 'hi {{name}}'
)
```

* `name`: unique id of the template
* `subject`: subject of the generated email (can be overwritten in the notification)
* `sender`: email address of the sender
* `html_content`: html content of the generated email, you can use the liquid syntax to use variables in the content, see [liquid](https://github.com/Shopify/liquid) for details
* `text_content`: text content of the generated email, you can use the liquid syntax to use variables in the content, see [liquid](https://github.com/Shopify/liquid) for details

2. You need to create the notification:

```
Notification.create(
  recipient: 'jane.doe@gmail.com',
  notification_type: 'email',
  template: Sincerely::Templates::EmailLiquidTemplate.first,
  delivery_options: {
    template_data: {
      name: 'John Doe'
    },
    subject: 'subject'
  }
)
```
* `recipient`: recipient of the notification
* `notification_type`: email/sms/push (please note that right now the gem supports only AWS SES email notifications)
* `template`: template to generate the notification content
* `delivery_options`: options for the associated template (`EmailLiquidTemplate` supports (i) the `template_data` option which contains the parameter hash for the liquid template defined in the html_content field of the associated template, (ii) the `subject` option which overwrites the subject defined in the associated template)


3. You need to send the notification:

```
notification.deliver
```

## Notification statuses
* `draft`: default status, notification is not yet sent
* `accepted`: the send request was successful and the delivery system will attempt to deliver the message to the recipient’s mail server
* `rejected`: notification is rejected by the delivery system
* `delivered`: notification is successfully delivered by the delivery system
* `bounced`: notification is bounced (ie when an email cannot be delivered to the recipient)
* `opened`: notification is opened
* `clicked`: notification is clicked
* `complained`: notification is complained (ie when the recipient of your email marks your email as spam)

Please note that the notification status is updated only if the event callback is configured. 

## Callbacks

`EmailAwsSes` delivery system supports SES email sending events. To enable it make sure:
* you have run the `events` task described in the `Getting Started` section
* you have set the `configuration_set_name` option described in the `Configuration` section
* you have run the following task that generates the webhook controller for you
```bash
rails g sincerely:aws_ses_webhook_controller SES_WEBHOOK
```

Furthermore you need to configure Amazon SES to be able to send emails, see [SES](https://docs.aws.amazon.com/ses/latest/dg/Welcome.html) for details.

Once the webhook controller is in place, it will:
* update the status of the notifications
* create event records for the bounce/complaint/open/click events

## How to Run Tests
You can run unit tests for RubyBlok with the following command:
```
bundle exec rspec
```

## Guide for Contributing
Contributions are made to this repository via Issues and Pull Requests (PRs).
Issues should be used to report bugs, request a new feature, or to discuss potential changes before a PR is created.

## How to Contact Us
For any inquiries, reach out to us at: info@rubyblok.com

## License
RubyBlok is released under the MIT License.