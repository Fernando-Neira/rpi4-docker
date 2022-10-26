#!/bin/sh

arg="$1"
arg2=$2

CONTENT_TYPE="Content-Type: application/json"
HEADERS="Authorization: Bearer ACCESS-TOKEN"

BASE_URL="https://api.smartthings.com/v1/devices/1f49d595-af37-5cd4-c793-94b1ff7bdad6/"

executeApi() {
  curl -s -k -H "$CONTENT_TYPE" -H "$HEADERS" -X POST -d "$2" "$BASE_URL$1"
}

executeApiWithReturn() {
  curl -s -k -H "$CONTENT_TYPE" -H "$HEADERS" -X GET "$BASE_URL$1" | jq "$2"
}

case "$arg" in
power | Power | POWER)
  executeApi "/commands" "{\"commands\": [{\"capability\": \"switch\", \"command\": \"$2\"}]}"
  ;;
temperature | Temperature | TEMPERATURE)
  executeApi "/commands" "{\"commands\": [{\"capability\": \"thermostatCoolingSetpoint\",\"command\": \"setCoolingSetpoint\",\"arguments\": [$arg2]}]}"
  ;;
mode | Mode | MODE)
  executeApi "/commands" "{\"commands\": [{\"capability\": \"airConditionerMode\",\"command\": \"setAirConditionerMode\", \"arguments\": [\"$arg2\"]}]}"
  ;;
fanmode | Fanmode | FANMODE)
  executeApi "/commands" "{\"commands\": [{\"capability\": \"airConditionerFanMode\",\"command\": \"setFanMode\", \"arguments\": [\"$arg2\"]}]}"
  ;;
fanoscillationmode | Fanoscillationmode | FANOSCILLATIONMODE)
  executeApi "/commands" "{\"commands\": [{\"capability\": \"fanOscillationMode\",\"command\": \"setFanOscillationMode\", \"arguments\": [\"$arg2\"]}]}"
  ;;
esac

sleep 1

power=$(executeApiWithReturn "/components/main/capabilities/switch/status" ".switch.value")
temperature=$(executeApiWithReturn "/components/main/capabilities/temperatureMeasurement/status" ".temperature.value")
mode=$(executeApiWithReturn "/components/main/capabilities/airConditionerMode/status" ".airConditionerMode.value")
desired=$(executeApiWithReturn "/components/main/capabilities/thermostatCoolingSetpoint/status" ".coolingSetpoint.value")
fanMode=$(executeApiWithReturn "/components/main/capabilities/airConditionerFanMode/status" ".fanMode.value")
fanOscillationMode=$(executeApiWithReturn "/components/main/capabilities/fanOscillationMode/status" ".fanOscillationMode.value")

power=$(echo "$power" | sed -e "s/^\"//" -e "s/\"$//")
mode=$(echo "$mode" | sed -e "s/^\"//" -e "s/\"$//")
fanMode=$(echo "$fanMode" | sed -e "s/^\"//" -e "s/\"$//")
fanOscillationMode=$(echo "$fanOscillationMode" | sed -e "s/^\"//" -e "s/\"$//")

echo "Power: $power";
echo "Mode: $mode";
echo "Temperature: \"$temperature C\"";
echo "FanMode: $fanMode";
echo "FanOscillationMode $fanOscillationMode";
echo "Desired: \"$desired C\"";
