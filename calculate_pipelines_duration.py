import json
import logging
import math
import os
import sys
import time
from collections import defaultdict

import requests
from tabulate import tabulate

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)


class PipelineTimes:

    def __init__(self, wait_time=0, build_time=0, count=0, passing_wait_time=0, passing_build_time=0, passing_count=0):
        self.wait_time = wait_time
        self.build_time = build_time
        self.count = count

        self.passing_wait_time = passing_wait_time
        self.passing_build_time = passing_build_time
        self.passing_count = passing_count

        self.main = True

        super().__init__()

    def add_times(self, wait_time, build_time, passing):
        self.wait_time += wait_time
        self.build_time += build_time
        self.count += 1

        if passing:
            self.passing_wait_time += wait_time
            self.passing_build_time += build_time
            self.passing_count += 1


class PipelineStageTimes(PipelineTimes):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.main = False


def get_job_state_transition_time(job_state_transitions, n):
    return job_state_transitions[n]["state_change_time"]


def get_scheduled_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 0)


def get_assigned_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 1)


def get_preparing_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 2)


def get_building_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 3)


def get_completing_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 4)


def get_completed_state_transition_time(job_state_transitions):
    return get_job_state_transition_time(job_state_transitions, 5)


def get_gocd_pipeline_history(pipeline_history_url):
    headers = {"Accept": "application/vnd.go.cd.v1+json"}
    response = requests.get(f"{pipeline_history_url}", headers=headers)
    return response.json()


def construct_stage_url(gocd_server_url, pipeline_name, pipeline_counter, stage_name, stage_counter):
    return f"{gocd_server_url}/go/api/stages/{pipeline_name}/{pipeline_counter}/{stage_name}/{stage_counter}"


def extract_stage_times(detailed_stage_instance):
    passed_result = "Passed"

    wait_time_sum = 0
    build_time_sum = 0

    min_scheduled_time = math.inf
    max_completed_time = 0

    for job in detailed_stage_instance["jobs"]:
        if job["result"] != passed_result:
            logging.warning(f""
                            f"job instance "
                            f"{job['name']} "
                            f"of "
                            f"{detailed_stage_instance['pipeline_name']}/{detailed_stage_instance['pipeline_counter']}/"
                            f"{detailed_stage_instance['name']}/{detailed_stage_instance['counter']} "
                            f"not in {passed_result} result ({job['result']})")

        scheduled_time, completed_time, wait_time, build_time = extract_job_times(job)

        min_scheduled_time = min(min_scheduled_time, scheduled_time)
        max_completed_time = max(max_completed_time, completed_time)

        wait_time_sum += wait_time
        build_time_sum += build_time

    return wait_time_sum, build_time_sum, min_scheduled_time, max_completed_time


def extract_job_times(job):
    passed_pipeline_state_transitions_number = 6

    job_state_transitions = job["job_state_transitions"]

    if len(job_state_transitions) < passed_pipeline_state_transitions_number:
        job_states = ",".join([transition['state'] for transition in job_state_transitions])
        logging.warning(f"found less than {passed_pipeline_state_transitions_number} states: {job_states}")
        return math.inf, 0, 0, 0

    scheduled_state_transition_time = get_scheduled_state_transition_time(job_state_transitions)
    preparing_state_transition_time = get_preparing_state_transition_time(job_state_transitions)
    building_state_transition_time = get_building_state_transition_time(job_state_transitions)
    completing_state_transition_time = get_completing_state_transition_time(job_state_transitions)
    completed_state_transition_time = get_completed_state_transition_time(job_state_transitions)

    wait_time = preparing_state_transition_time - scheduled_state_transition_time
    build_time = completing_state_transition_time - building_state_transition_time

    return scheduled_state_transition_time, completed_state_transition_time, wait_time, build_time


def get_gocd_stage_instance(stage_instance_url):
    headers = {"Accept": "application/vnd.go.cd.v3+json"}
    response = requests.get(f"{stage_instance_url}", headers=headers)
    return response.json()


def get_gocd_dashboard(gocd_server_url):
    headers = {"Accept": "application/vnd.go.cd.v3+json"}
    response = requests.get(f"{gocd_server_url}/go/api/dashboard", headers=headers)
    return response.json()


def get_pipelines_instances_scheduled_between_dates(gocd_dashboard, scheduled_after_date, scheduled_before_date):
    pipeline_instances_scheduled_after_date = defaultdict(list)

    for pipeline in gocd_dashboard["_embedded"]["pipelines"]:
        pipeline_history_url = pipeline["_links"]["self"]["href"]
        pipeline_history = get_gocd_pipeline_history(pipeline_history_url)

        while True:
            for pipeline_instance in pipeline_history["pipelines"]:
                if scheduled_after_date < pipeline_instance["scheduled_date"] < scheduled_before_date:
                    pipeline_instances_scheduled_after_date[pipeline_instance["name"]].append(pipeline_instance)

            if "_links" not in pipeline_history or "next" not in pipeline_history["_links"]:
                break

            pipeline_history_next_url = pipeline_history["_links"]["next"]["href"]
            pipeline_history = get_gocd_pipeline_history(pipeline_history_next_url)

    return pipeline_instances_scheduled_after_date


def calculate_times_per_pipeline(gocd_server_url, pipelines_instances):
    passed_status = "Passed"

    pipelines_times = {}

    run_start_time = math.inf
    run_end_time = 0

    for pipeline_name, pipeline_instances in pipelines_instances.items():
        for pipeline_instance in pipeline_instances:
            pipeline_instance_wait_time = 0
            pipeline_instance_build_time = 0
            passing = True

            for stage in pipeline_instance["stages"]:
                if stage["status"] != passed_status:
                    passing = False
                    logging.warning(f""
                                    f"stage instance "
                                    f"{stage['name']}/{stage['counter']} "
                                    f"of "
                                    f"{pipeline_instance['name']}/{pipeline_instance['counter']} "
                                    f"not in {passed_status} state ({stage['status']})")

                stage_instance_url = construct_stage_url(
                    gocd_server_url,
                    pipeline_name,
                    pipeline_instance["counter"],
                    stage["name"],
                    stage["counter"]
                )

                try:
                    detailed_stage_instance = get_gocd_stage_instance(stage_instance_url)
                except json.decoder.JSONDecodeError:
                    logging.warning(f"corrupted json at {stage_instance_url}, skipping")
                    continue

                stage_wait_time, stage_build_time, start_time, end_time = extract_stage_times(detailed_stage_instance)

                stage_name = stage["name"]
                pipeline_stage_name = f"{pipeline_name}/{stage_name}"

                if pipeline_stage_name not in pipelines_times:
                    pipelines_times[pipeline_stage_name] = PipelineStageTimes()

                pipelines_times[pipeline_stage_name].add_times(stage_wait_time, stage_build_time, passing)

                run_start_time = min(run_start_time, start_time)
                run_end_time = max(run_end_time, end_time)

                pipeline_instance_wait_time += stage_wait_time
                pipeline_instance_build_time += stage_build_time

            if pipeline_name not in pipelines_times:
                pipelines_times[pipeline_name] = PipelineTimes()

            pipelines_times[pipeline_name].add_times(pipeline_instance_wait_time, pipeline_instance_build_time, passing)

    return pipelines_times, run_end_time - run_start_time


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
    total_count = 0
    total_passing_count = 0

    headers = [
        "pipeline_name",
        "wait_time[s]",
        "build_time[s]",
        "count",
        "passing_wait_time[s]",
        "passing_build_time[s]",
        "passing_count",
        "passing_build_time_avg[s]"
    ]

    tabulate_data = []

    for pipeline_name, pipeline_time in pipelines_times.items():
        pipeline_wait_time = convert_ms_to_s(pipeline_time.wait_time)
        pipeline_build_time = convert_ms_to_s(pipeline_time.build_time)
        pipeline_count = pipeline_time.count
        pipeline_passing_wait_time = convert_ms_to_s(pipeline_time.passing_wait_time)
        pipeline_passing_build_time = convert_ms_to_s(pipeline_time.passing_build_time)
        pipeline_passing_count = pipeline_time.passing_count

        if pipeline_count:
            tabulate_data.append(
                [
                    pipeline_name,
                    pipeline_wait_time,
                    pipeline_build_time,
                    pipeline_count,
                    pipeline_passing_wait_time,
                    pipeline_passing_build_time,
                    pipeline_passing_count,
                    pipeline_passing_build_time / pipeline_passing_count
                ]
            )

            if pipeline_time.main:
                total_wait_time += pipeline_wait_time
                total_build_time += pipeline_build_time
                total_count += pipeline_count
                total_passing_count += pipeline_passing_count

    tabulate_data.append(["total", total_wait_time, total_build_time, total_count, "-", "-", total_passing_count, "-"])

    print(tabulate(tabulate_data, headers=headers))


def print_run_time(run_time):
    print(f"time from start to end: {run_time}ms")


def now_ms():
    return round(time.time() * 1000)


def main():
    gocd_server_url = sys.argv[1]
    scheduled_after_date = int(sys.argv[2])

    gocd_dashboard = get_gocd_dashboard(gocd_server_url)
    pipelines_instances = get_pipelines_instances_scheduled_between_dates(
        gocd_dashboard,
        scheduled_after_date,
        now_ms()
    )
    times_per_pipeline, run_time = calculate_times_per_pipeline(gocd_server_url, pipelines_instances)

    print_pipelines_times(times_per_pipeline)
    print_run_time(run_time)


if __name__ == "__main__":
    main()
