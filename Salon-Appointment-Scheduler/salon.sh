#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

DISPLAY_SERVICES () {
  echo -e "\n"
SALON_SERVICE_NAMES="$($PSQL "SELECT name FROM services")"
SERVICE_NUMBER=1
for SERVICE_NAME in $SALON_SERVICE_NAMES
do
  echo $SERVICE_NUMBER\) $SERVICE_NAME
  SERVICE_NUMBER=$(( $SERVICE_NUMBER + 1 ))
done
}

PROGRAM_INTRO () {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo Welcome to My Salon, how can I help you? Please enter your selection: 
  DISPLAY_SERVICES
}

GET_CUSTOMER_SERVICE () {
  read SERVICE_ID_SELECTED
  while ! [[ $SERVICE_ID_SELECTED -ge 1 && $SERVICE_ID_SELECTED -le 5  ]]
  do
    echo -e "\nI could not find that service. What would you like today?"
    DISPLAY_SERVICES
    read SERVICE_ID_SELECTED
  done
  
}

CREATE_APPOINTMENT () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
  if [[ -z $CUSTOMER_ID ]]
  then
    ADD_NEW_CUSTOMER
  fi

  echo -e "\nWhat time would you like to schedule the appointment for?"
  read SERVICE_TIME
  
  SERVICE_TYPE="$($PSQL "SELECT name FROM services WHERE $SERVICE_ID_SELECTED = service_id")"
  NEW_APPOINTMENT="$($PSQL "
    INSERT INTO appointments(customer_id, service_id, time) 
    VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
  ")"

  echo -e "\nI have put you down for a $SERVICE_TYPE at $SERVICE_TIME, $CUSTOMER_NAME."
}

ADD_NEW_CUSTOMER () {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  NEW_CUSTOMER="$($PSQL "
    INSERT INTO customers(name, phone) 
    VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')
  ")"
  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
}

PROGRAM_INTRO
GET_CUSTOMER_SERVICE
CREATE_APPOINTMENT
