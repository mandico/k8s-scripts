
#!/bin/bash
WHITE='\033[0;37m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m' 
RED='\033[0;31m' 
TRIES=3
SLEEP=3
APISERVER=https://xxxxxx:443
TOKEN=*****

function header_print(){
   echo "#####################################################"
   echo "########## CHECK STATUS PODS | $1/$2 | $3 ########"
   echo "#####################################################"
   echo ""
}

function call_api(){
   curl -s $APISERVER/api/v1/namespaces/$1/pods/ --header "Authorization: Bearer $TOKEN" --cacert /tmp/ca.crt -k | jq -r '.items[] | [.metadata.name , .status.phase, .status.containerStatuses[].ready] | @tsv'
   RESULT=$(curl -s $APISERVER/api/v1/namespaces/$1/pods/ --header "Authorization: Bearer $TOKEN" --cacert /tmp/ca.crt -k | jq -r '.items[] | [.metadata.name , .status.phase, .status.containerStatuses[].ready] | @tsv')

   if [[ $RESULT == *"Pending"* || $RESULT == *"False"*  ]]
   then
     echo ""
     echo "${ORANGE}############### ... Waiting pods ... ################${WHITE}"
     echo ""
     if [[ $i == $TRIES ]]
     then
       echo "${RED}########### ... ERROR :: PODS NOT OK ... ############${WHITE}"
       exit 1
     fi
     SLEEP $SLEEP
   else
     echo ""
     echo "${GREEN}############ CHECK STATUS PODS | SUCCESS ############${WHITE}"
     echo ""
     break
   fi
}

for (( i=1; i<=$TRIES; i++ ))
do
   header_print $i $TRIES "cmb-prd"
   call_api "cmb-prd"
done

for (( i=1; i<=$TRIES; i++ ))
do  
   header_print $i $TRIES "rgc-prd"
   call_api "rgc-prd"
done