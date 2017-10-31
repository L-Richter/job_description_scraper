import requests
import json
import hashlib
from collections import defaultdict

def get_details(job_resource):
    api_url = f'https://api.greenhouse.io/v1/boards/babbel/jobs/{job_resource}'
    response = requests.get(api_url)
    response.raise_for_status()
    job = defaultdict(str, json.loads(response.text))
    job_details = {}
    job_details['company_name'] = 'Babbel'
    job_details['natural_id'] = hash_string(job_resource)
    job_details['job_title'] = job['title']
    job_details['job_description'] = job['content']
    job_details['job_description_id'] = hash_string(job['content'])
    job_details['departments'] = [dep['name'] for dep in job['departments']]
    job_details['location'] = job['location']['name']
    return job_details


def hash_string(s):
    return hashlib.md5(str(s).encode('utf-8')).hexdigest()

