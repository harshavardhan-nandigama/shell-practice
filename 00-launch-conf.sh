#!/bin/bash

# === CONFIGURATION: CHANGE THESE VALUES AS PER YOUR ENVIRONMENT ===
AMI_ID="ami-09c813fb71547fc4f"                      # 👉 Replace with your AMI ID
SG_ID="sg-052b2eb75308383d4"                        # 👉 Replace with your Security Group ID
KEY_NAME="your-key-name"                            # 👉 Replace with your Key Pair Name (or leave empty if not using)
ZONE_ID="Z07069691890X06YTPXD4"                     # 👉 Replace with your Hosted Zone ID
DOMAIN_NAME="harshavn24.site"                       # 👉 Replace with your domain name

# === KEY NAME HANDLING (OPTIONAL) ===
if [ -n "$KEY_NAME" ]; then
  KEY_PARAM="--key-name $KEY_NAME"
else
  KEY_PARAM=""
fi

# === LOOP OVER PASSED INSTANCE NAMES ===
for instance in "$@"; do
    echo "🚀 Launching instance: $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t2.micro \
        --security-group-ids $SG_ID \
        $KEY_PARAM \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "📦 $instance launched with instance ID: $INSTANCE_ID"
    echo "⏳ Waiting for $instance to enter running state..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    # Get IP Address
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi

    echo "🌐 $instance IP address: $IP"

    # Create DNS Record in Route53
    echo "📡 Creating/updating DNS record: $RECORD_NAME -> $IP"
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Create A record for $instance\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 300,
                    \"ResourceRecords\": [{ \"Value\": \"$IP\" }]
                }
            }]
        }"

    echo "✅ DNS created: $RECORD_NAME -> $IP"
    echo "🎉 $instance setup completed."
    echo "---------------------------------------------"
done
