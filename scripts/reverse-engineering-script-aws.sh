#!/bin/bash

REGION="us-east-2"
echo "📍 Region: $REGION"
echo "=============================================="

# DynamoDB Tables - schema + sample record
echo -e "\n📦 DynamoDB Tables (with structure and sample item):"
TABLES=$(aws dynamodb list-tables --region $REGION --query "TableNames[]" --output text)
for TABLE in $TABLES; do
  echo -e "\n🔹 Table: $TABLE"
  aws dynamodb describe-table --table-name $TABLE --region $REGION --output json

  echo "🧪 Sample Item (if exists):"
  aws dynamodb scan --table-name $TABLE --region $REGION --limit 1 --output json
done

# Lambda Functions - configuration + code
echo -e "\n🧠 Lambda Functions (config + code location):"
LAMBDA_ARNS=$(aws lambda list-functions --region $REGION --query "Functions[].FunctionArn" --output text)
for ARN in $LAMBDA_ARNS; do
  NAME=$(echo $ARN | awk -F':' '{print $NF}')
  echo -e "\n🔹 Lambda: $NAME"
  aws lambda get-function --function-name $NAME --region $REGION --output json
done

# API Gateway v1 - settings, resources, auth
echo -e "\n🌐 API Gateway v1 (REST):"
APIS=$(aws apigateway get-rest-apis --region $REGION --query "items[].id" --output text)
for API_ID in $APIS; do
  echo -e "\n🔹 REST API ID: $API_ID"
  aws apigateway get-rest-api --rest-api-id $API_ID --region $REGION --output json

  echo "🔀 Resources:"
  aws apigateway get-resources --rest-api-id $API_ID --region $REGION --output json

  echo "🔐 Authorizers:"
  aws apigateway get-authorizers --rest-api-id $API_ID --region $REGION --output json

  echo "⚙️ Stages:"
  STAGES=$(aws apigateway get-stages --rest-api-id $API_ID --region $REGION --query "item[].stageName" --output text)
  for STAGE in $STAGES; do
    echo "🔁 Integrations for stage $STAGE:"
    aws apigateway get-stage --rest-api-id $API_ID --stage-name $STAGE --region $REGION --output json
  done
done

# API Gateway v2 - settings, routes, integrations, auth
echo -e "\n🚀 API Gateway v2 (HTTP + WebSocket):"
APIS_V2=$(aws apigatewayv2 get-apis --region $REGION --query "Items[].ApiId" --output text)
for API_ID in $APIS_V2; do
  echo -e "\n🔹 API ID: $API_ID"
  aws apigatewayv2 get-api --api-id $API_ID --region $REGION --output json

  echo "🔁 Routes:"
  aws apigatewayv2 get-routes --api-id $API_ID --region $REGION --output json

  echo "🔄 Integrations:"
  aws apigatewayv2 get-integrations --api-id $API_ID --region $REGION --output json

  echo "🔐 Authorizers:"
  aws apigatewayv2 get-authorizers --api-id $API_ID --region $REGION --output json
done

# IAM Policies - policy document
echo -e "\n🔐 IAM Policies (Customer Managed - JSON):"
POLICIES=$(aws iam list-policies --scope Local --query "Policies[].Arn" --output text)
for POLICY_ARN in $POLICIES; do
  echo -e "\n🔹 Policy ARN: $POLICY_ARN"
  VERS=$(aws iam get-policy --policy-arn $POLICY_ARN --query "Policy.DefaultVersionId" --output text)
  aws iam get-policy-version --policy-arn $POLICY_ARN --version-id $VERS --output json
done

# Cognito User Pools - config
echo -e "\n👥 Cognito User Pools (full properties):"
POOLS=$(aws cognito-idp list-user-pools --region $REGION --max-results 60 --query "UserPools[].Id" --output text)
IFS=$'\n'
for POOL_ID in $POOLS; do
  POOL_ID=$(echo $POOL_ID | xargs) # trim whitespace
  if [[ -n "$POOL_ID" ]]; then
    echo -e "\n🔹 User Pool ID: $POOL_ID"
    aws cognito-idp describe-user-pool --user-pool-id "$POOL_ID" --region $REGION --output json
  fi
done
unset IFS