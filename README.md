# Webcam Catpure

Example configuration file

```
aws:
  region: "us-east-1"
  key: "XXX"
  secret: "XXX"
  bucket: "mybucket"

cameras:
  format: "%Y/%m/%d/%H%M.jpg"
  schedule: "* * * * *"
  nest:
    client_id: "XXX"
    client_secret: "XXX"
    to_capture:
      - "Front Yard"
```
