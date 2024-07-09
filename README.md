# Sincerely
## Introduction
Sincerely is a versatile Ruby gem designed for ...

## Table of Contents
1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [How to Run Tests](#how-to-run-tests)
4. [Guide for Contributing](#guide-for-contributing)
5. [How to Contact Us](#how-to-contact-us)
6. [License](#license)

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

2. Now let's generate and run a migration to create the `notifications` table and the `Notification` model:
```bash
rails g sincerely:migration NOTIFICATION

rails db:migrate
```

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