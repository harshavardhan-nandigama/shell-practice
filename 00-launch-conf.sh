#!/bin/bash

# ==== CONFIGURATIONS (EDIT THESE) ====
AMI_ID="ami-09c813fb71547fc4f"
INSTANCE_TYPE="t2.micro"
KEY_NAME=""
SECURITY_GROUP_ID="sg-052b2eb75308383d4"
SUBNET_ID="subnet-05112b3c37617e1fb"
DNS_ZONE_ID="Z07069691890X06YTPXD4"
DOMAIN="harshavn24.site"

# ==== INSTANCE NAMES ====
INSTANCE_LIST=("frontend" "mongodb" "catalogue" "nginx" "mysql" "cart" "payment" "rabbitmq" "redis" "shipping" "user")  # <-- Add your instance names here

# ==== CHECK INPUT ====
TARGET_INSTANCE="$1"  # Optional input to launch a specific instance by name

# ==== FUNCTION TO LAUNCH ONE INSTANCE ====
launch_instance() {
  INSTANCE_NAME=$1

  echo "Launching instance: $INSTANCE_NAME"

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query "Instances[0].InstanceId" --output text)

  echo "Instance ID: $INSTANCE_ID for $INSTANCE_NAME"

  echo "Waiting for $INSTANCE_NAME to be in running state..."
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID

  PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

  echo "$INSTANCE_NAME IP: $PUBLIC_IP"

  # Create DNS record
  cat > temp-dns.json <<EOF
{
  "Comment": "Create A record for $INSTANCE_NAME",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$INSTANCE_NAME.$DOMAIN",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [{ "Value": "$PUBLIC_IP" }]
      }
    }
  ]
}
EOF

  aws route53 change-resource-record-sets \
    --hosted-zone-id $DNS_ZONE_ID \
    --change-batch file://temp-dns.json

  echo "✅ DNS created for $INSTANCE_NAME.$DOMAIN -> $PUBLIC_IP"
}

# ==== MAIN EXECUTION ====
if [[ -n "$TARGET_INSTANCE" ]]; then
  if [[ " ${INSTANCE_LIST[@]} " =~ " $TARGET_INSTANCE " ]]; then
    launch_instance "$TARGET_INSTANCE"
  else
    echo "❌ ERROR: Instance '$TARGET_INSTANCE' not found in list: ${INSTANCE_LIST[*]}"
    exit 1
  fi
else
  for NAME in "${INSTANCE_LIST[@]}"; do
    launch_instance "$NAME" &
  done
  wait
fi

rm -f temp-dns.json
echo "🎉 All done."
