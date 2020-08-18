### vars ###

pass="SAuer1357N@1357N"
nsx=192.168.1.70

### get ID file ###

### colllect all the segments ID and create output file (id_results)

curl --silent -k -u admin:$pass -X GET https://$nsx/policy/api/v1/infra/segments | grep -A 2 seg | grep  ' "path" : ' | awk '{print $3}' | sed 's/"//g' | sed 's/,//g' > seg_id

get="curl --silent -k -u admin:$pass -X GET https://$nsx/policy/api/v1"

sed  -i -e "s|^|$get|" seg_id

sed  -i s/$/"| grep -B 1 display_name | head -n 1 |   cut -d ":" -f2 | cut -c3- | rev | cut -c 3- | rev"/ seg_id

 chmod 777 seg_id
 ./seg_id > id_results


declare -a array=()
i=0
while IFS= read -r line; do   array[i]=$line; let "i++"; done < id_results




### get display name file ###

### colllect all the segments display name and create output file (display_resultsv)


curl --silent -k -u admin:$pass -X GET https://$nsx/policy/api/v1/infra/segments | grep -A 2 seg | grep  ' "path" : ' | awk '{print $3}' | sed 's/"//g' | sed 's/,//g' > seg_display

get="curl --silent -k -u admin:$pass -X GET https://$nsx/policy/api/v1"

sed  -i -e "s|^|$get|" seg_display

sed  -i s/$/"| grep display_name | cut -d ":" -f2 | cut -c3- | rev | cut -c 3- | rev"/ seg_display

 chmod 777 seg_display
 ./seg_display > display_results


declare -a array1=()
a=0
while IFS= read -r line; do   array1[a]=$line; let "a++"; done < display_results
echo "${array1[0]}"





##### create json template ##### 

##### create PATCH request json template to delete the segment and childsegment objjects using marked_for_delete":true


u=0
for d in "${array[@]}"
do
	echo $d
cat > infra-$d.delete << EOF
curl --user admin:$pass -H 'Content-Type: application/json' --request PATCH  'https://$nsx/policy/api/v1/infra' -k -d '{
   "resource_type":"Infra",
   "children":[
      {
         "resource_type":"ChildSegment",
         "marked_for_delete":true,
         "Segment":{
            "resource_type":"Segment",
            "id":"input_id",
            "display_name":"input_display"
         }
      }
   ]
}'
EOF
sed -i "s/input_display/${array1[u]}/g" infra-$d.delete
sed -i "s/input_id/${array[u]}/g" infra-$d.delete 
let "u++"
done

##### the while will create script for each segment , copy past the output and execute the DELETION scripts..

chmod 777 *.delete
ls -ltrh infra-* |  awk '{print $9}' | sed   s/^/.'\/'/

