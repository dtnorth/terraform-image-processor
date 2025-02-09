const { DynamoDBClient, PutItemCommand, GetItemCommand } = require('@aws-sdk/client-dynamodb');
const shortid = require('shortid');

const dynamoDB = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.URL_SHORTENER_TABLE;

async function createShortUrl(originalUrl) {
    const shortId = shortid.generate();
    await dynamoDB.send(new PutItemCommand({
        TableName: TABLE_NAME,
        Item: {
            shortId: { S: shortId },
            originalUrl: { S: originalUrl },
        }
    }));
    return `https://your-api.com/short/${shortId}`;
}

async function getOriginalUrl(shortId) {
    const result = await dynamoDB.send(new GetItemCommand({
        TableName: TABLE_NAME,
        Key: { shortId: { S: shortId } },
    }));

    if (!result.Item) throw new Error("Short URL not found");
    return result.Item.originalUrl.S;
}

module.exports = { createShortUrl, getOriginalUrl };

