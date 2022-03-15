import random
import requests
import time

while True:
    n = random.choice([0, 5, 10, 15, 20, 25, 91])
    try:
        print(requests.get(f"http://fibonacci:5000/fibonacci?n={n}"))
    except requests.exceptions.ConnectionError as ce:
        print(ce)

    sleep_seconds = random.randint(1, 5)
    time.sleep(sleep_seconds)