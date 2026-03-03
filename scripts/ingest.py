import json
import time
import boto3
import requests

bucket_name = 'cms-healthcare-data-bucket-2026'
years_id = {2018 : "09c12f06-e3fe-4cb0-81e9-945f2078c1df",
         2019 : "6f6d93e1-ecf8-4b93-9845-091faf20f274",
         2020 : "ef5bdbe1-27b4-4296-b320-52bd5d2183d7",
         2021 : "117d93f2-ce81-40fe-a4d4-8c03203b95e1",
         2022 : "46bf50f8-0983-4ca2-b8d5-f2afbbf2e589"}
base_url = "https://data.cms.gov/data-api/v1/dataset/{dataset_id}/data"

client = boto3.client('s3') #to initialize s3 client

def get_data(year):
    print(f"Fetching data for the year {year}...")
    datasetid = years_id.get(year)
    url = base_url.format(dataset_id=datasetid)
    size = 5000 #number of records to fetch per request
    offset = 0 #starting point for fetching records
    all_data = [] #to store all fetched data

    print(f"Getting data from {url}...")
    try:
        while True:
            params = {'size': size, 'offset': offset}
            response = requests.get(url, params=params)
            response.raise_for_status() # Check if the request was successful
            data = response.json() # Return the JSON data
            if not data: # If no more data is returned, break the loop
                break
            all_data.extend(data) # Append fetched data to all_data list
            offset += size # Increment offset for next iteration
            print(f"Fetched {len(all_data)} records so far...")
            time.sleep(0.5) # Sleep to avoid hitting API rate limits

        print(f"Finished fetching data for {year}. Total records: {len(all_data)}")
        file_key = f"raw_data/cms_data_{year}.json"
        client.put_object(
            Bucket=bucket_name,
            Key=file_key,
            Body="\n".join(json.dumps(record) for record in all_data)
        )
        print(f"Uploaded full datset for {year} to S3 at key {file_key}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred while fetching data: {e}")
        return None
    
if __name__ == "__main__":
    for year in years_id.keys():
        get_data(year)