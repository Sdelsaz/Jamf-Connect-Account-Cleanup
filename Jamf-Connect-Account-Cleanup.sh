#!/bin/bash

###########################################################################################################################
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###########################################################################################################################
#
#
# The script will check for Jamf Connect accounts that haven't logged in in X amount of days and delete them. 
# The  deletion (line 125) is commented out so the script can be tested without deleting accounts first.
#
# Created by Sebastien Del Saz Alvarez on 29th of December 2022
#
###########################################################################################################################
#
# Script Parameters
# 
# $4 =  Maximum age in days
#
###########################################################################################################################

# List all users who have a password

AllUsers=$(/usr/bin/dscl . list /Users Password | /usr/bin/awk '$2 != "*" {print $1}')

# Start loop to do checks on all users who have a password

for user in $AllUsers

do
	
# If a user has the attribute "OIDCProvider" in their user record, they are a Jamf Connect user.
	
MigrateStatus=($(/usr/bin/dscl . -read /Users/$user | grep "OIDCProvider: " | /usr/bin/awk {'print $2'}))

# If we didn't get a result, the variable is empty.  Thus that user is not a Jamf Connect Login user.
	
if [[ -z $MigrateStatus ]]; 
	
then
				
echo "$user is Not a Jamf Connect User"
	
else

echo "$user is a Jamf Connect User"

# Check the last login for the user

LastLogin=$(/usr/libexec/PlistBuddy -c "Print :LastSignIn" /Users/$user/Library/Preferences/com.jamf.connect.state.plist || echo "Does not exist")

if [[ $LastLogin ==  *"Does not exist"* ]]
	
then

echo "No Last Login information found"

else

# Convert the date of the last login to epoch

LastLoginEpoch=$(date -j -f "%a %b %d %T %Z %Y" "$LastLogin" +"%s")

# Check if a value is passed in Parameter $4.

if [ -z "$4" ]

then

MaximumDays="No value Provided"

else
		
MaximumDays="$4"
		
fi

# Check if the value provided is a number
	
re='^[0-9]+$'

if ! [[ $MaximumDays =~ $re ]] ; then
	
# If no value is provided or the value provided is not a number, exit

echo "No value provided for the maximum age in days or the value is not a number" >&2; exit 1

else

# Convert the number of days to seconds

MaximumDaysInSeconds=$(( MaximumDays * 86400 ))

# Get the current epoch time

CurrentTime=$(date +%s)

# get the maximum login age by subsstracting the maximum days from the current time

MaximumLoginAge=$(( $CurrentTime - $MaximumDaysInSeconds ))
	
# Check if the last login was more or less than the maximum amount of days ago.
	
if [[ $LastLoginEpoch > $MaximumLoginAge ]]
	
then
	
echo "Last Login less than $MaximumDays days ago: $LastLogin" Account untouched.

else
	
echo "Last Login for $user was on $LastLogin"

echo "deleting account $user as this user hasn't logged in in $MaximumDays days or more"

# Delete the accounts. The deletion is comented so as to test and make sure the accounts are fetched as expected. Remove the hashtag from the following command once this has been verified.

#/usr/bin/dscl . -delete /Users/$user

fi
	
fi

fi 

fi

done

exit 0
