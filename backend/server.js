const express = require('express');
const multer = require('multer');
const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { DynamoDBClient, PutItemCommand, GetItemCommand } = require('@aws-sdk/client-dynamodb');
const sharp = require('sharp');
const shortid = require('shortid');
const serverless = require('serverless-http');
const { generateResizedImages } = require('./imageProcessor');
const { createShortUrl, getOriginalUrl } = require('./urlShortener');

const app = express();
const s3 = new S3Client({ region: process.env.AWS_REGION });
const upload = multer({ storage: multer.memoryStorage() });

const BUCKET_NAME = process.env.S3_BUCKET;

// 📌 Image Upload API
app.post('/upload', upload.single('image'), async (req, res) => {
    const file = req.file;
    const fileName = `uploads/${Date.now()}-${file.originalname}`;

    const params = {
        Bucket: BUCKET_NAME,
        Key: fileName,
        Body: file.buffer,
        ContentType: file.mimetype,
    };

    try {
        await s3.send(new PutObjectCommand(params));
        const resizedUrls = await generateResizedImages(s3, BUCKET_NAME, file.buffer, fileName);
        const shortUrl = await createShortUrl(fileName);
        
        res.json({
            message: 'Upload successful',
            originalUrl: `https://${BUCKET_NAME}.s3.amazonaws.com/${fileName}`,
            resizedUrls,
            shortUrl
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 URL Shortener API
app.get('/short/:id', async (req, res) => {
    try {
        const originalUrl = await getOriginalUrl(req.params.id);
        res.redirect(originalUrl);
    } catch (error) {
        res.status(404).json({ error: 'Short URL not found' });
    }
});

module.exports.handler = serverless(app);

