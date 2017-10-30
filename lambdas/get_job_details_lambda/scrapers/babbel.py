import requests
import json

def get_jobs(job_resource):
    api_url = f'https://api.greenhouse.io/v1/boards/babbel/jobs/{job_resource}'
    response = requests.get(api_url)
    response.raise_for_status()
    job = json.loads(response.text)
    job_details = {}
    job_details['company_name'] = 'Babbel'
    job_details['natural_id'] = job_resource
    job_details['job_title'] = job['title']
    job_details['job_description'] = job['content']
    job_details['departments'] = [dep['name'] for dep in job['departments']]
    job_details['location'] = job['location']['name']
    return job_details

