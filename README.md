# pass2csv

This script converts a collection of GPG-encrypted files from `pass`, the standard Unix password manager (https://www.passwordstore.org/), into a CSV file that can be read by the `convert_to_1p4` 1Password Utility using the `csv` converter: https://discussions.agilebits.com/discussion/30286/mrcs-convert-to-1password-utility

It currently supports building a CSV file with data for the following 1Password fields:

- Title
- Username
- Password
- Notes
- Modified Date

## Assumptions

There are several assumptions made by this script:

- The name of the `.gpg` file is used as the Title
- The password is assumed to be on the first line of the encrypted `.gpg` file
- The username is assumed to be on the second line of the encrypted `.gpg` file
- Everything after the second line of the `.gpg` file is assumed to be a note

## Password files in subdirectories are not supported!

The path you provide to this script should be a directory that contains `.gpg` files. If you organized your passwords like `~.password-store/Companies/XYZ/email_login.gpg`, and you pass `~/.password-store/Companies` to this script, the metadata about the `XYZ` subdirectory will be lost. Instead, you should use `~.password-store/Companies/XYZ` and then use the tagging feature of `convert_to_1p4` to tag those passwords with an appropriate tag, e.g., `-t XYZ` so that when they're imported into 1Password you retain that organizational metadata.

## Examples

Example command for turning the export CSV file into a 1Password 1PIF file using the `convert_to_1p4` utility:

```
/usr/bin/perl convert_to_1p4.pl csv '~/Projects/pass2csv/export_1547584081.csv' -v -t Example,Tags,Here
```

This script requires one argument: a directory that contains `.gpg` files.

Example: `pass2csv.sh ~.password-store/Logins`
