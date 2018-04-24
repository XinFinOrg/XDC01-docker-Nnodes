#!/bin/bash

function checkport {
        if nc -zv -w30 $1 $2 <<< '' &> /dev/null
        then
                return 0
        else
                return 1
        fi
}

# Example checks
if $(checkport 'localhost' 9001); then
	echo "In Use"
else
	echo "Free"
fi

