# Sincerely
## Introduction
Sincerely is a versatile Ruby gem designed for ...

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

1. First, you need to run the install generator, which will create the initializer for you:
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
delivery_methods:
  email:
    class_name: Sincerely::DeliveryMethods::EmailAwsSes
    options:
  sms:
```

2. You need to set the delivery method for each delivery options (email/sms/push) by setting the `delivery_methods` option in the `config/sincerely.yml` file:

```
notification_model_name: Notification
```

## Usage
1. For a detailed description of configuring AWS SES email sending see the following blog post:

2. Once the email delivery method is configured you need to create an email template which is used to generate the email content:

```
Sincerely::Templates::EmailLiquidTemplate.create(
  name: 'test',
  subject: 'template for sending messages',
  sender: 'john.doe@gmail.com'
  html_content: 'hi {{name}}',
  text_content: 'hi {{name}}'
)
```

* name: unique id of the template
* subject: subject of the generated email (can be overwritten in the notification)
* sender: email address of the sender
* html_content: html content of the generated email, you can use the liquid syntax to use variables in the content, see [liquid](https://github.com/Shopify/liquid) for details
* text_content: text content of the generated email, you can use the liquid syntax to use variables in the content, see [liquid](https://github.com/Shopify/liquid) for details

3. You need to create the notification:

```
Notification.create(
  recipient: 'jane.doe@gmail.com',
  notification_type: 'email',
  template: template,
  delivery_options: {
    template_data: {
      name: 'John Doe'
    },
    subject: 'subject'
  }
)
```
* recipient: recipient of the notification
* notification_type: email|sms|push
* template: template to generate the notification content
* delivery_options: options for the associated template (ie `template_data` contains the variable for the liquid template, `subject` overwrites the subject defined in the associated template)

4. You need to send the notification:

```
notification.deliver
```

## Notification statuses
* draft: default status, notification is not yet sent
* accepted: notification is accepted by the delivery system
* rejected: notification is rejected by the delivery system
* delivered: notification is delivered by the delivery system
* bounced: notification is bounced (ie when an email cannot be delivered to the recipient)
* opened: notification is opened
* clicked: notification is clicked
* complained: notification is complained (ie when the recipient of your email marks your email as spam)

## Callbacks

For a detailed description of AWS SES email callbacks see the following blog post

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