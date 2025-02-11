
const express = require('express');
const multer = require('multer');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');
const sharp = require('sharp');
const shortid = require('shortid');
const serverless = require('serverless-http');

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

const s3 = new S3Client({ region: process.env.AWS_REGION });
const dynamoDB = new DynamoDBClient({ region: process.env.AWS_REGION });

app.post('/upload', upload.single('image'), async (req, res) => {
    const file = req.file;
    const fileName = `uploads/${Date.now()}-${file.originalname}`;
    await s3.send(new PutObjectCommand({
        Bucket: process.env.S3_BUCKET,
        Key: fileName,
        Body: file.buffer,
        ContentType: file.mimetype,
    }));

    const shortId = shortid.generate();
    await dynamoDB.send(new PutItemCommand({
        TableName: process.env.TABLE_NAME,
        Item: {
            shortId: { S: shortId },
            originalUrl: { S: fileName },
        }
    }));

    res.json({
        message: 'Upload successful',
        fileUrl: `https://${process.env.S3_BUCKET}.s3.amazonaws.com/${fileName}`,
        shortUrl: `https://your-api.com/short/${shortId}`
    });
});

module.exports.handler = serverless(app);
