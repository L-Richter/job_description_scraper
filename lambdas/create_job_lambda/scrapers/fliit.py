import requests
import json

def get_jobs():
    api_url = 'https://api.recruitee.com/c/6472/careers/offers/'
    response = requests.get(api_url)
    response.raise_for_status()
    all_jobs = json.loads(response.text)
    jobs = [job for job in all_jobs if job['department'] == 'fliit']
    return jobs

