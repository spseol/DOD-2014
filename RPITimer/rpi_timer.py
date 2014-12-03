from Crypto.Random.random import randint
from requests.api import post
from time import sleep
import sys

from datetime import datetime


CONTROL_PORT = 6
ENABLE_PORT = 5
GPIO_DELAY = 0.5  # #delay for GPIO
start_time = None


def is_port_active(port):
    # some magic about GPIO
    r = randint(0, 100000)
    return r > 99999
    # some magic about GPIO


def set_port_active(port):
    # some magic
    pass


def print_elapsed(td):
    sys.stdout.write('\r{:.4}s.'.format(td.seconds + td.microseconds / 10.0 ** 6))


url = raw_input('IP:port to control server (empty for localhost:8888) >>> ') or 'localhost:8888'
url = ''.join(('http://', url, '/control/timer'))

while 1:
    i = raw_input('\nDo you want repeat? (y/n) >>> ').lower()
    if not i in ('y', 'n') or i == 'n':
        continue

    set_port_active(ENABLE_PORT)
    while 1:
        lap_time = datetime.now() - (start_time if not start_time is None else datetime.now())
        print_elapsed(lap_time)
        if is_port_active(ENABLE_PORT):
            if start_time is None:
                sys.stdout.write('\nSTART!')
                start_time = datetime.now()
                sleep(GPIO_DELAY)
                continue
            else:
                lap_time = datetime.now() - start_time
                start_time = None
                r = post(url, data={'time': lap_time.seconds * 1000 + lap_time.microseconds / 1000.0})
                break

