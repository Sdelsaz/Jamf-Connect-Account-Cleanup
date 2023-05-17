# Jamf Connect Account Cleanup

This script is partially based on Sean Rabbitt's JIT-user-deletion-with-jamf-connect script:

https://github.com/sean-rabbitt/JIT-user-deletion-with-jamf-connect


This Jamf Pro script will check for Jamf Connect accounts that haven't logged in in X amount of days and delete them. The amount of days can be customized by passing a number in $4. If no number is passed in $4 the script will exit. If no last sign-in information is found for an account the account stays intact. 

NOTE: The actual deletion is commented so that the script can be tested without deletion first.


## Parameters

$4 = Maximum age of accounts in number of days

## Background

This script is designed to be used in the context of shared computer environments where files do not get stored locally and users do not use the same computer every time.  It aims to solve the problem of users logging back in on a computer after a long time and not remembering their previous password.

