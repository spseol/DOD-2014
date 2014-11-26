from Crypto.Random.random import randint
from requests.api import post
from time import sleep

from datetime import datetime, timedelta


CONTROL_PORT = 6
GPIO_DELAY = 0.5  # #delay for GPIO
url = raw_input('IP:port to control server >>> ')
url = ''.join(('http://', url, '/control/timer'))

def is_port_active(port):
    # some magic about GPIO
    r = randint(0, 1000)
    return r > 999


start_time = None
while 1:

    if is_port_active(CONTROL_PORT) and start_time is None:
        start_time = datetime.now()
        sleep(GPIO_DELAY)
        continue

    if is_port_active(CONTROL_PORT) and start_time is not None:
        lap_time = datetime.now() - start_time
        start_time = None
        milisecs = lap_time.seconds*1000 + lap_time.microseconds/1000.0
        r = post(url, data={'time': milisecs})


