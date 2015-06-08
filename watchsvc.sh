#!/bin/sh

# Author: Jack Bezalel
# Module: watchsvc.sh

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
# This specific part deals contains the main code, including service validation and activation of
# the external restart code when needed

# Initialization
#

. ./watchsvc-setup.sh

#Main

SRVC="$1"

if      [ -z "$SRVC" ]
then
        EXIT_MAIN "Usage: $0 ServiceName"
fi

# Get a complete service listing rather than just the one we are looking for
# So we can better analyze what manages this service and what is its state

SRVC_STAT="`service --status-all 2>&1 | grep $SRVC`"
SRVC_NAME="`echo "$SRVC_STAT" | awk '{ print $4 }'`"
SRVC_FLAG="`echo "$SRVC_STAT" | awk '{ print $2 }'`"

if      [ "$SRVC_NAME" != "$SRVC" ]
then
        EXIT_MAIN "Looks like Service $SRVC does not exist"
fi

case "$SRVC_FLAG" in

\+)
        display_message "Service $SRVC up!";
;;

\-)     display_message "Looks like Service $SRVC is down" ;
        display_message "Trying to restart $SRVC" ;
	timeout $MAX_TIMEOUT ./watchsvc-restart.sh "$SRVC" ;
        RETRY_START_OK=$? ;

        if      [ "$RETRY_START_OK" != "$TRUE" ] ;
        then
		if 	[ "$RETRY_START_OK" != "$SVC_RESTART_TIMEOUT" ];
		then	
                	EXIT_MAIN "Restart trials failed. Service still down" ;
		else
			EXIT_MAIN "Timeout starting service. Service may be still down. Please re-run $0" ;
		fi
        else
                display_message "Restart Succeeded! Service $SRVC is up!" ;
        fi;
;;


\?)
        EXIT_MAIN "Service $SRVC is not managed by service command"
;;

\*)     EXIT_MAIN "Can't figure out the state of Service $SRVC, please consult the Administrator"
;;

esac

exit $TRUE

