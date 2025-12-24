import json
from unittest.mock import MagicMock

from backend.app import lambda_handler

def test_lambda_handler_increments_and_returns_visits():
    # Arrange: create a fake DynamoDB table
    table = MagicMock()
    table.update_item.return_value = {"Attributes": {"visits": 42}}

    # Act
    resp = lambda_handler(event={}, context=None, table=table)

    # Assert: response shape
    assert resp["statusCode"] == 200
    assert resp["headers"]["Content-Type"] == "application/json"

    body = json.loads(resp["body"])
    assert body["visits"] == 42

    # Assert: DynamoDB call arguments (CRC reviewers like seeing this)
    table.update_item.assert_called_once_with(
        Key={"id": "site"},
        UpdateExpression="ADD visits :inc",
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )
