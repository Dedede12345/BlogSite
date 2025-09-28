import boto3
import os
from urllib.parse import unquote_plus
from PIL import Image

s3_client = boto3.client('s3')
OUTPUT_BUCKET = "blogsite-output-bucket-821hwkjqr"

def resize_image(image_path, resized_path):
    with Image.open(image_path) as image:
        image.thumbnail((image.width // 2, image.height // 2))
        image.save(resized_path)
        return image.get_format_mimetype()

def lambda_handler(event, context):
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        source_key = unquote_plus(record['s3']['object']['key'])

        if source_key.startswith("resized/"):
            print(f"Skipping already resized image: {source_key}")
            continue

        filename = os.path.basename(source_key)
        folder = os.path.dirname(source_key)

        # Local temporary paths in Lambda
        download_path = f"/tmp/{filename}"
        resized_path = f"/tmp/resized-{filename}"

        # Output S3 key
        output_key = f"resized/{folder}/{filename}" if folder else f"resized/{filename}"

        # Download from source bucket
        s3_client.download_file(source_bucket, source_key, download_path)
        print(f"Downloaded {source_key} from bucket {source_bucket}")

        # Resize image
        content_type = resize_image(download_path, resized_path)
        print(f"Resized image saved to {resized_path}")

        # Upload to output bucket
        s3_client.upload_file(
            resized_path,
            OUTPUT_BUCKET,
            output_key,
            ExtraArgs={'ContentType': content_type}
        )

        print(f"Uploaded resized image to {OUTPUT_BUCKET}/{output_key}")

        try:
            os.remove(download_path)
            os.remove(resized_path)
        except Exception as e:
            print(f"Cleanup error: {e}")