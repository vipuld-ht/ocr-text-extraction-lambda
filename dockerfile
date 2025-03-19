FROM amazonlinux:2 as builder
RUN amazon-linux-extras enable epel && \
    yum install -y epel-release && \
    yum install -y tesseract poppler-utils python3-pip && \
    yum clean all

# Stage 2: AWS Lambda Base Image
FROM public.ecr.aws/lambda/python:3.9

COPY --from=builder /usr/bin/tesseract /usr/bin/tesseract
COPY --from=builder /usr/lib64/ /usr/lib64/
COPY --from=builder /usr/share/tesseract/tessdata /usr/share/tesseract/tessdata

ENV TESSDATA_PREFIX=/usr/share/tesseract/tessdata
ENV PATH="/usr/bin:${PATH}"

RUN yum install -y poppler-utils

COPY requirements.txt ./

RUN pip3 install --no-cache-dir -r requirements.txt

COPY pdf_text_extraction_lambda.py ./

CMD ["pdf_text_extraction_lambda.lambda_handler"]
