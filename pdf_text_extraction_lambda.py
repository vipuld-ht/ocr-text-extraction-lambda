import os
import io
import boto3
import pytesseract
from pdf2image import convert_from_bytes
from PIL import Image

# AWS Configuration
BUCKET_NAME = "insightrag-job-config"
S3_PDF_FOLDER = "input/"
S3_OUTPUT_FOLDER = "output-glue/"

# Initialize S3 client
s3 = boto3.client("s3")

def extract_text_from_pdf(pdf_bytes):
    """Extracts text from a PDF file stored in memory."""
    images = convert_from_bytes(pdf_bytes)  # Convert PDF to images
    text = ""
    for image in images:
        text += pytesseract.image_to_string(image) + "\n"
    return text

def process_pdfs():
    """Processes PDFs from S3 and extracts text."""
    pdf_files = s3.list_objects_v2(Bucket=BUCKET_NAME, Prefix=S3_PDF_FOLDER)
    
    if "Contents" not in pdf_files:
        print("No PDFs found in the specified S3 folder.")
        return
    
    for obj in pdf_files["Contents"]:
        file_key = obj["Key"]
        if file_key.lower().endswith(".pdf"):
            response = s3.get_object(Bucket=BUCKET_NAME, Key=file_key)
            pdf_bytes = response["Body"].read()
            extracted_text = extract_text_from_pdf(pdf_bytes)
            save_extracted_text_to_s3(file_key, extracted_text)

def save_extracted_text_to_s3(pdf_key, extracted_text):
    """Saves extracted text to an S3 bucket."""
    txt_filename = os.path.splitext(os.path.basename(pdf_key))[0] + ".txt"
    s3_key = os.path.join(S3_OUTPUT_FOLDER, txt_filename)
    s3.put_object(Bucket=BUCKET_NAME, Key=s3_key, Body=extracted_text, ContentType="text/plain")
    print(f"Uploaded extracted text to: s3://{BUCKET_NAME}/{s3_key}")

def lambda_handler(event, context):
    """AWS Lambda Handler"""
    process_pdfs()
    return {"status": "completed", "message": "PDF processing done"}
