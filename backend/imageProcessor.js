
const sharp = require('sharp');
const { PutObjectCommand } = require('@aws-sdk/client-s3');

async function generateResizedImages(s3, bucket, fileBuffer, fileName, contentType) {
    let resizedUrls = {};
    const resolutions = [100, 300, 600];

    for (const width of resolutions) {
        const resizedImage = await sharp(fileBuffer)
            .resize({ width })
            .toFormat(contentType.includes("image/webp") ? "webp" : "jpeg")
            .toBuffer();

        const newFileName = fileName.replace('.', `-${width}px.`);

        await s3.send(new PutObjectCommand({
            Bucket: bucket,
            Key: newFileName,
            Body: resizedImage,
            ContentType: contentType.includes("image/webp") ? "image/webp" : "image/jpeg",
        }));

        resizedUrls[`${width}px`] = `https://${bucket}.s3.amazonaws.com/${newFileName}`;
    }

    return resizedUrls;
}

module.exports = { generateResizedImages };
