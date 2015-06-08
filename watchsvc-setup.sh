#!/bin/sh

# Author: Jack Bezalel
# Module: watchsvc-setup.sh

# Purpose:
# 
# This is part of a "watchdog" process aiming to keep a service running
# The name of the service to "watch for" is provided on the "watchdog" activation
# Firstly we try to verify if the service exists and then what is its state
# All monitoring and service state is based on the "service" command, for which some systems
# and services may not be managed by it
# In such cases the "watchdog" process should be re-adjusted
# We have pre-configured the number of trials to start the "watched" service to 4 and the
# alloted time for this operation to 60 seconds and all both those parameters could be modified
#
# This specific part deals with the environment setup for the other scripts of this solution

# Initialization
#

FALSE=1
TRUE=0
MAX_TIMEOUT=60
SVC_RESTART_TIMEOUT=124

#Functions

EXIT_MAIN()
{
	# Exit from the main program in case of a fatal error

	local EXIT_MSG
        EXIT_MSG=$1

        echo "$0 Fatal Error - $EXIT_MSG"
        exit $FALSE
}

display_message()
{
	# Echo a general message

	local DISPLAY_MSG
        DISPLAY_MSG=$1

        echo "$0 $DISPLAY_MSG"
        return 
}

