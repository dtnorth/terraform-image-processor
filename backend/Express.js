const express = require('express');
const multer = require('multer');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { DynamoDBClient, PutItemCommand, GetItemCommand } = require('@aws-sdk/client-dynamodb');
const sharp = require('sharp');
const shortid = require('shortid');
const serverless = require('serverless-http');

const app = express();
const s3 = new S3Client({ region: process.env.AWS_REGION });
const dynamoDB = new DynamoDBClient({ region: process.env.AWS_REGION });

const upload = multer({ storage: multer.memoryStorage() });

app.post('/upload', upload.single('image'), async (req, res) => {
    const file = req.file;
    const fileName = `uploads/${Date.now()}-${file.originalname}`;

    try {
        // Upload to S3
        await s3.send(new PutObjectCommand({
            Bucket: process.env.S3_BUCKET,
            Key: fileName,
            Body: file.buffer,
            ContentType: file.mimetype,
        }));

        // Generate Short URL
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
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports.handler = serverless(app);

