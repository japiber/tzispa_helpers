Tzispa Helpers

## v0.3.3
- added str_to_integer text helper macro

## v0.3.2
- added before / after hook helpers

## v0.3.1
- added json fields support to request_data_object
- added yesno_list builder method

## v0.3.0
- bug fixes
- code refactoring

## v0.2.2
- unscape html request form values
- added not_authorized alias method
- transform empty strings into nil for date/time methods
- bug fixes

## v0.2.1
- added html_disabled helper method

## v0.2.0
- move some helpers to experts avoiding excesive gem dependencies

## v0.1.21
- added requirer and sign_requirer dsl helpers
- added provider dsl helper

## v0.1.20
- fix rack 2.0 incompatibility errors in response send_file

## v0.1.19
- added DateTime helper module

## v0.1.18
- add str_time_ellapsed method in text helper

## v0.1.17
- add require tzispa/version in error_view
- fix nokogiri required version in gemspec

## v0.1.16
- add charset parameter in mail helper / send_smtp_mail

## v0.1.15
- add permanent_redirect method to provide http 301 response

## v0.1.14
- fix error in crawler_table_to_list

## v0.1.13
- amount minimum precision 0 discards fraction part

## v0.1.12
- minimal securize crawler_save_file verifying url

## v0.1.11
- in error_view module rename error_report to debug_info
- add support for http/2 in redirect

## v0.1.10
- response class add absolute parameter in redirect method

## v0.1.9
- Set default value for status parameter in error_page

## v0.1.8
- Add error_view module

## v0.1.7
- Fix error in mime_formatter text/x-markdown when text is nil

## v0.1.6
- Add raise exception for debug in send_smtp_mail

## v0.1.4
- Fix secret generator in security

## v0.1.3
- Added mime module, code moved partially from response
- Added 2 crawler functions: crawler_to_markdown, crawler_table_to_dl

## v0.1.2
- Added amount formatter in text helper with i18n support

## v0.1.1
- Added exception rescue in Mail.send_smtp_mail
- Added pattern Helper
- Added web crawler helper

## v0.1.0
- Initial release: code split from tzispa main gem
