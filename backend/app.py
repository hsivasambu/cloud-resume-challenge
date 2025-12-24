import os
import json
import boto3

def get_table():
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ.get("TABLE_NAME", "resume_visits")
    return dynamodb.Table(table_name)

def lambda_handler(event, context, table=None):
    if table is None:
        table = get_table()

    resp = table.update_item(
        Key={"id": "site"},
        UpdateExpression="ADD visits :inc",
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )

    visits = int(resp["Attributes"]["visits"])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            # keep your existing CORS headers here if you already have them
        },
        "body": json.dumps({"visits": visits}),
    }