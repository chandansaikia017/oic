#!/bin/bash
## Scripts for OIC deployments
## Author Chandan Saikia
## version 0.0.1
##################################################

host=XXXXXXX.integration.ocp.oraclecloud.com



read -p 'Enter OIC Username : ' oicUsername

read -s -p 'Enter OIC Password : ' oicPassword


read -p 'Enter OSVC Username: ' osvcUsername


read  -s -p 'Enter OSVC Password: ' osvcPassword

echo "Deploying integration HELLO_WORLD"

curl  -i -X POST -u $oicUsername:$oicPassword -H "Content-Type:multipart/form-data" -F file=@"./integrations/HELLO_WORLD_01.00.0000.iar;type=application/octet-stream" https://$host/icsapis/v2/integrations/archive  


echo "******Updating Connection OSVC******"

curl -i -X  POST -u $oicUsername:$oicPassword -H "X-HTTP-Method-Override:PATCH" -H "Content-Type:application/json" -d '{
	"connectionProperties": {
		"propertyGroup": "CONNECTION_PROPS",
		"propertyName": "targetWSDLURL",
		"propertyType": "WSDL_URL",
		"propertyValue": "https://hostname:port/services/soap/connect/soap?wsdl"
	},
	"securityProperties": [
		{
			"propertyGroup": "CREDENTIALS",
			"propertyName": "username",
			"propertyValue": "'$osvcUsername'"
		},
		{
			"propertyGroup": "CREDENTIALS",
			"propertyName": "password",
			"propertyValue": "'$osvcPassword'"
		}
	]
}' https://$host/icsapis/v2/connections/OSVC

echo "******Activated OSVC Connection******"

echo "******Activating Integration HELLO_WORLD ******"

curl -i -X POST -u $oicUsername:$osvcPassword -H 'Content-type: application/xml' -H 'Accept: application/xml' https://$host/icsapis/v1/integrations/HELLO_WORLD/01.00.0000/activate?enablePayloadTracing=true
