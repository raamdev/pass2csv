#!/bin/bash

# ---------------------------------------------------------------------------
# @(#)$Id$
#
# Author:       Raam Dev <raam@raamdev.com>
# Created:      2019-01-16
# Version:      20190116
#
# This script converts a collection of GPG-encrypted files from `pass`, the standard
# Unix password manager (https://www.passwordstore.org/), into a CSV file that can be
# read by the `convert_to_1p4` 1Password Utility using the `csv` converter:
# https://discussions.agilebits.com/discussion/30286/mrcs-convert-to-1password-utility
# 
# Assumptions of this script:
#
# The name of the .gpg file is used as the Title, the password is assumed to be on
# the first line of the encrypted .gpg file, and the username is assumed to be on
# the second line of the encrypted .gpg file. Everything after the second line is
# assumed to be a note.
#
# Password files in subdirectories are not supported! The path you pass to this
# script must be a directory that contains .gpg files. If you organized your
# passwords like `~.password-store/Companies/XYZ/email_login.gpg`, and you pass
# `~/.password-store/Companies` to this script, the metadata about the `XYZ`
# subdirectory will be lost. Instead, you should use `~.password-store/Companies/XYZ`
# and then use the tagging feature of `convert_to_1p4` to tag those passwords
# with an appropriate tag, e.g., `-t XYZ` so that when they're imported into 1Password
# you retain that organizational metadata.
#
# Example command for turning the export CSV file into a 1Password 1PIF file:
# /usr/bin/perl convert_to_1p4.pl csv '~/Projects/pass2csv/export_1547584081.csv' -v -t Example,Tags,Here
#
# This script requires one argument: a directory that contains .gpg files.
#
# Example: <script> <directory>
#
# ---------------------------------------------------------------------------

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ] || [ ! -d $1 ]; then
        echo "Error: You must pass a directory to this script."
        echo "Example: $0 ~/.password-store/Logins"
        echo ""
        exit 1
fi

echo 
echo "Finding .gpg files in $1..."
echo 
FILES=`find $1 -iname \*.gpg`

# Create a unique filename for the export CSV file
CSV="export_$(date +%s).csv"

# Create the header for the CSV file
echo '"title","login password","login username","notes","modified"' > $CSV

# Iterate over the .gpg files, extracting the necessary data to build the CSV
for f in $FILES
do
  echo "Processing $f file..."

  # Use the .gpg filename as the title
  # Remove the .gpg extension and replace underscores in filename with spaces
  TITLE=`basename $f | sed 's,\.gpg,,' | sed 's,_, ,g'`

  # Password is assumed to be on first line
  PASS=`gpg -q -d $f | sed -n 1p`

  # Username is assumed to be on second line
  USER=`gpg -q -d $f | sed -n 2p`

  # Everything after the second line is assumed to be notes
  NOTES=`gpg -q -d $f | tail -n +3`

  # Record the modified date of the file for the export
  MODIFIED_DATE=`stat -f %m $f`

  # Append a comma-delimited line of data to the CSV file
  echo "\"$TITLE\",\"$PASS\",\"$USER\",\"$NOTES\",\"$MODIFIED_DATE\"" >> $CSV
done

echo 
echo "Done!"
echo "Password data exported to $(pwd)/$CSV"
