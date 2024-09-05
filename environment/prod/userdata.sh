#!/bin/bash
# userdata.sh

# Update the package list and install Apache web server
yum update -y
yum install -y httpd

# Start the HTTP service and enable it to start on boot
systemctl start httpd
systemctl enable httpd

# Get the instance's metadata for IP, Availability Zone, and Hostname
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)

# Create a styled HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instance Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background-color: #fff;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        h1 {
            color: #007bff;
        }
        p {
            font-size: 18px;
            margin: 5px 0;
        }
        .footer {
            margin-top: 20px;
            font-size: 14px;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Instance Information</h1>
        <p><strong>Private IP Address:</strong> $INSTANCE_IP</p>
        <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
        <p><strong>Hostname:</strong> $HOSTNAME</p>
        <div class="footer">Powered by Terraform & AWS</div>
    </div>
</body>
</html>
EOF

# Restart HTTP service to ensure the new content is served
systemctl restart httpd