"""Process user data file."""

# Standard Python Libraries
import os
import sys

# Third-Party Libraries
import boto3
from jinja2 import Template

TARGET_FILE = "GITHUB_OUTPUT"

ssm = boto3.client("ssm")

# Retrieve Windows Administrator password from AWS SSM
password = ssm.get_parameter(
    Name="/windows/commando/administrator/password", WithDecryption=True
)["Parameter"]["Value"]

user_data_file_location = "./src/winrm_bootstrap.txt"
with open(user_data_file_location) as user_data_file:
    # Process the user data file with the Windows Administrator password
    Template(user_data_file.read()).stream(password=password).dump(
        user_data_file_location
    )

file_path = os.getenv(TARGET_FILE)
if not file_path:
    print(f"{TARGET_FILE} file was not found!", file=sys.stderr)
    sys.exit(1)

with open(file_path, "a") as output_file:
    print(f"pass={password}", file=output_file)
