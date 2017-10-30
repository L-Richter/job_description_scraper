import requests
import json

def get_jobs():
    api_url = 'https://api.greenhouse.io/v1/boards/babbel/departments'
    response = requests.get(api_url)
    response.raise_for_status()
    departments = json.loads(response.text)
    jobs = [job['id'] for department in departments['departments']
                      for job in department['jobs']]
    return jobs

