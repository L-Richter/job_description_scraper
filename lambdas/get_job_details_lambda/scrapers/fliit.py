import json
import hashlib
from collections import defaultdict

def get_details(job_resource):
    job = defaultdict(str, job_resource)
    job_details = {}
    job_details['company_name'] = 'Fliit'
    job_details['natural_id'] = hash_string(job['id'])
    job_details['job_title'] = job['title']
    job_details['job_description'] = job['description'] + job['requirements']
    job_details['job_description_id'] = hash_string(
                                            job_details['job_description']
                                        )
    job_details['location'] = job['location']
    return job_details


def hash_string(s):
    return hashlib.md5(str(s).encode('utf-8')).hexdigest()

