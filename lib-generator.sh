# Enable required repositories and install dependencies
sudo amazon-linux-extras enable epel
sudo yum install -y tesseract poppler-utils python3-pip

# Create the layer directory
mkdir -p ~/tesseract-poppler-layer/bin

# Copy the required binaries
cp /usr/bin/tesseract ~/tesseract-poppler-layer/bin/
cp /usr/bin/pdftotext ~/tesseract-poppler-layer/bin/

# Copy required shared libraries
mkdir -p ~/tesseract-poppler-layer/lib
ldd /usr/bin/tesseract | awk '{print $3}' | grep -v '^(' | xargs -I '{}' cp -v '{}' ~/tesseract-poppler-layer/lib/
ldd /usr/bin/pdftotext | awk '{print $3}' | grep -v '^(' | xargs -I '{}' cp -v '{}' ~/tesseract-poppler-layer/lib/

# Navigate to the layer directory
cd ~/tesseract-poppler-layer

# Zip the layer (ensure correct structure)
zip -r tesseract-poppler-layer.zip bin lib

# Upload to S3
aws s3 cp tesseract-poppler-layer.zip s3://insightrag-job-config/glue_libraries_zip/
