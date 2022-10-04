#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo -e "\nUSAGE: \n$0 <AWS_PROFILE> <USERNAME> <MFA_TOKEN>\n" >&2
  echo -e "PROFILES: \n$(aws configure list-profiles | grep -v '\-mfa')\n" >&2
  exit 3
else
  set -e
  AWS_PROFILE=$1
  USERNAME=$2
  MFA_TOKEN=$3
  MFA_SN=$(aws --profile $AWS_PROFILE iam list-mfa-devices \
        --user-name $USERNAME \
        --output text \
        --query 'MFADevices[].SerialNumber')
  sts=$(aws --profile $AWS_PROFILE sts get-session-token \
      --serial-number $MFA_SN \
      --token-code $MFA_TOKEN \
      --duration-seconds ${4:-36000} \
      --output text \
      --query \
      'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]')
  sts=($sts)
  export AWS_REGION=sa-east-1
  export AWS_ACCESS_KEY_ID=${sts[0]}
  export AWS_SECRET_ACCESS_KEY=${sts[1]}
  export AWS_SESSION_TOKEN=${sts[2]}
  aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $AWS_PROFILE-mfa
  aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $AWS_PROFILE-mfa
  aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $AWS_PROFILE-mfa
  aws configure set region $AWS_REGION --profile $AWS_PROFILE-mfa
  EXPIRATION=$(date --iso-8601=seconds --date="${sts[3]}")
  echo -e "\nAWS Account ID: $(aws sts get-caller-identity --query Account --output text --profile $AWS_PROFILE-mfa)"
  echo -e "AWS Profile Name: $AWS_PROFILE-mfa"
  echo -e "Token Expiration: $EXPIRATION\n"
fi
