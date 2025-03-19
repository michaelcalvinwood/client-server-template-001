#!/bin/bash

vlanIP=$(ip -4 addr show | grep -oP '(?<=inet\s)(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)(\d+\.){2}\d+' | head -1)

echo "Vlan IP = $vlanIP"
