import logging
import os
import sys
from collections import defaultdict
from tabulate import tabulate

import requests

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)


class PipelineTimes:

    def __init__(self, wait_time=0, build_time=0):
        self.wait_time = wait_time
        self.build_time = build_time

        super().__init__()

    def add_times(self, wait_time, build_time):
        self.wait_time += wait_time
        self.build_time += build_time


def get_assigned_state_transition_time(job_state_transitions):
    return job_state_transitions[1]["state_change_time"]


def get_preparing_state_transition_time(job_state_transitions):
    return job_state_transitions[2]["state_change_time"]


def get_building_state_transition_time(job_state_transitions):
    return job_state_transitions[3]["state_change_time"]


def get_completing_state_transition_time(job_state_transitions):
    return job_state_transitions[4]["state_change_time"]


def get_completed_state_transition_time(job_state_transitions):
    return job_state_transitions[5]["state_change_time"]


def get_gocd_pipeline_history(pipeline_history_url):
    headers = {"Accept": "application/vnd.go.cd.v1+json"}
    response = requests.get(f"{pipeline_history_url}", headers=headers)
    return response.json()


def construct_stage_url(gocd_server_url, pipeline_name, pipeline_counter, stage_name, stage_counter):
    return f"{gocd_server_url}/go/api/stages/{pipeline_name}/{pipeline_counter}/{stage_name}/{stage_counter}"


def extract_stage_times(detailed_stage_instance):
    passed_result = "Passed"

    wait_time = 0
    build_time = 0

    for job in detailed_stage_instance["jobs"]:
        if job["result"] != passed_result:
            logging.warning(f""
                            f"stage instance "
                            f"{detailed_stage_instance['name']}/{detailed_stage_instance['counter']} "
                            f"of "
                            f"{detailed_stage_instance['pipeline_name']}/{detailed_stage_instance['pipeline_counter']} "
                            f"not in {passed_result} result")
            continue

        job_state_transitions = job["job_state_transitions"]

        preparing_state_transition_time = get_preparing_state_transition_time(job_state_transitions)
        building_state_transition_time = get_building_state_transition_time(job_state_transitions)
        completing_state_transition_time = get_completing_state_transition_time(job_state_transitions)

        job_scheduled_date = job["scheduled_date"]

        wait_time += preparing_state_transition_time - job_scheduled_date
        build_time += completing_state_transition_time - building_state_transition_time

    return wait_time, build_time


def get_gocd_stage_instance(stage_instance_url):
    headers = {"Accept": "application/vnd.go.cd.v3+json"}
    response = requests.get(f"{stage_instance_url}", headers=headers)
    return response.json()


def get_gocd_dashboard(gocd_server_url):
    headers = {"Accept": "application/vnd.go.cd.v3+json"}
    response = requests.get(f"{gocd_server_url}/go/api/dashboard", headers=headers)
    return response.json()


def get_pipelines_instances_scheduled_after_date(gocd_dashboard, scheduled_after_date):
    pipeline_instances_scheduled_after_date = defaultdict(list)

    for pipeline in gocd_dashboard["_embedded"]["pipelines"]:
        pipeline_history_url = pipeline["_links"]["self"]["href"]
        pipeline_history = get_gocd_pipeline_history(pipeline_history_url)

        for pipeline_instance in pipeline_history["pipelines"]:
            if pipeline_instance["scheduled_date"] > scheduled_after_date:
                pipeline_instances_scheduled_after_date[pipeline_instance["name"]].append(pipeline_instance)

    return pipeline_instances_scheduled_after_date


def calculate_times_per_pipeline(gocd_server_url, pipelines_instances):
    passed_status = "Passed"

    pipelines_times = defaultdict(PipelineTimes)

    for pipeline_name, pipeline_instances in pipelines_instances.items():
        for pipeline_instance in pipeline_instances:
            pipeline_instance_wait_time = 0
            pipeline_instance_build_time = 0

            for stage in pipeline_instance["stages"]:
                if stage["status"] != passed_status:
                    logging.warning(f""
                                    f"stage instance "
                                    f"{stage['name']}/{stage['counter']} "
                                    f"of "
                                    f"{pipeline_instance['name']}/{pipeline_instance['counter']} "
                                    f"not in {passed_status} state")
                    continue

                stage_instance_url = construct_stage_url(
                    gocd_server_url,
                    pipeline_name,
                    pipeline_instance["counter"],
                    stage["name"],
                    stage["counter"]
                )

                detailed_stage_instance = get_gocd_stage_instance(stage_instance_url)

                stage_wait_time, stage_build_time = extract_stage_times(detailed_stage_instance)

                pipeline_instance_wait_time += stage_wait_time
                pipeline_instance_build_time += stage_build_time

            pipelines_times[pipeline_name].add_times(pipeline_instance_wait_time, pipeline_instance_build_time)

    return pipelines_times


def convert_ms_to_s(ms):
    ms_part = ms % 1000
    s_part = (ms - ms_part) / 1000

    if ms_part >= 500:
        return s_part + 1
    else:
        return s_part


def print_pipelines_times(pipelines_times):
    total_wait_time = 0
    total_build_time = 0

    headers = ["pipeline_name", "wait_time[s]", "build_time[s]"]
    tabulate_data = []

    for pipeline_name, pipeline_time in pipelines_times.items():
        pipeline_wait_time = convert_ms_to_s(pipeline_time.wait_time)
        pipeline_build_time = convert_ms_to_s(pipeline_time.build_time)

        if pipeline_wait_time or pipeline_build_time:
            tabulate_data.append([pipeline_name, pipeline_wait_time, pipeline_build_time])

            total_wait_time += pipeline_wait_time
            total_build_time += pipeline_build_time

    tabulate_data.append(["total", total_wait_time, total_build_time])

    print(tabulate(tabulate_data, headers=headers))


def main():
    gocd_server_url = sys.argv[1]
    scheduled_after_date = int(sys.argv[2])

    gocd_dashboard = get_gocd_dashboard(gocd_server_url)
    pipelines_instances = get_pipelines_instances_scheduled_after_date(gocd_dashboard, scheduled_after_date)
    times_per_pipeline = calculate_times_per_pipeline(gocd_server_url, pipelines_instances)
    print_pipelines_times(times_per_pipeline)


if __name__ == "__main__":
    main()