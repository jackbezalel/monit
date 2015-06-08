#!/bin/sh

# Author: Jack Bezalel
# Module: watchsvc-restart.sh

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
# This specific part deals with the restart attempt of a failed service and it should be activated
# by the "watchsvc.sh" process

# Initialization
#

. ./watchsvc-setup.sh


# Try to restart a service that was down, up to MAX_RESTARTS trials and MAX_TIMEOUT seconds

SVC=$1 # Which service we want to restart

MAX_RESTARTS=4
RESTARTS=1

while [ $RESTARTS -le $MAX_RESTARTS ];
do
	service "$SVC" restart 1>/dev/null 2>1
        RESTART_OK="$?"

	# Service is considered as up only if the restart command seem to have
	# completed OK and then we actually verify if service is up
	# by reviewing the service status command
	# Assuming format: [ F ] servicename
	# Where F is +, -, ?

        if      [ "$RESTART_OK" = "$TRUE" ];
        then
		# This additional check covers situations where the service restart was OK
		# Yet the service is not up (sudo service which is unconfigured for example)

		SRVC_STAT="`service --status-all 2>1`"
		SRVC_FLAG="`echo "$SRVC_STAT" | grep "$SVC" | awk '{ print $2 }'`"	

		if	[ "$SRVC_FLAG" = "+" ]
		then
                       	exit $TRUE
		fi
        fi

        RESTARTS=$((RESTARTS+1))
done

# Tried to restart MAX RESTARTS times, so declare failure

exit $FALSE

