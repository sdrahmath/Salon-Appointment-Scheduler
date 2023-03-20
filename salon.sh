#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU(){
  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services order by service_id")
  if [[ -z $AVAILABLE_SERVICES ]]
  then 
    echo "Sorry, we dont have services available right now"
  else
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That is not a number"
      else
        SERV_AVAIL=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
        NAME_SERV=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
        if [[ -z $SERV_AVAIL ]]
        then
        MAIN_MENU "I could not find that service. What would you like today?"
            else
            echo -e "\nWhat's your phone number?"
            read CUSTOMER_PHONE
            CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
            if [[ -z $CUSTOMER_NAME ]]
            then
              echo -e "\nWhat's your name?"
            read CUSTOMER_NAME
            INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
            fi
          echo -e "\nWhat time would you like your $NAME_SERV, $CUSTOMER_NAME?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          if [[ $SERVICE_TIME ]]
          then
            INSERT_SERV_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
            if [[ $INSERT_SERV_RESULT ]]
            then
              echo -e "\nI have put you down for a $NAME_SERV at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
            fi
          fi
        fi
    fi
  fi
}
MAIN_MENU
