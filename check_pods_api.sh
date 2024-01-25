
#!/bin/bash
WHITE='\033[0;37m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m' 
RED='\033[0;31m' 
TRIES=3
SLEEP=3
APISERVER=https://40.88.199.241:443
TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6InljekFxUjdqUHpCT1ZYX3NqamZxYklfYk14M19qeHNnTTNTVUJzaktKMkEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tc2EiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtbyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImZhYTE0YmI0LTdiYWMtNGM3MS1iMTk5LTA0ZjhmMDMwOGE3MiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlbW8ifQ.MMlRoiIwSGJkyNubttkiGiuGvyqFPssQSK7pnyRTzYnsmD0Tcd_WHVJdDxDxMm-K_u8KO3PQmFW7mtLmEXsHwiiLQovglx5I1uR2Y1l-I_nZJ5IlBM235a-UjeVSdTzjgkNtHybn3St6yu39voLYVW9HFdRj4QF4M1nMuiHvzbNqVH_tAos6kZwLKXd1w8me4zpSeskrDaaLFbryYEA6WojHJM38Z33ZpDkMTdLV7cY5nEwanxFsMMxFHV2YZXrbhIfTEX7FT4H9gFwPHLEDtbJA2LcBzT9pdQg9PoNkKezjOJ5AXPIJ_-qCOczujOXFufKpI78ceHt16UuPIlLhFlXH4KeZZ_Y7wVwR5saXSa8qDdssPLgqsL0PGILpIPpqV1qwLU1cbxhrzz1gsJXoUdLitnJDs1SaVo7cFYY_JB2oH5m4VWSJfjhQkZTAn3W5IrN8RnKbB1k_-B--OCDjXjREiOuVEbM1bsogevNbjDwyWOL1zkYZzrrlKzhs7f1PNWUEl6jpqGGhc3tIjcx7h3uLgOq-p7V1eKSlo1h_UvV4lGNOmSvsrjsp86dYTP7L_3i5rXDccq8aOfM0sdlhPly1684zG5LddZcdgKSOU8OZ9LY2K5Jz1bwGRhRCX1v7JcndbLHSKkxv9w8SApHU3cWyKxf_KokeEQYo-fkYSs0

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