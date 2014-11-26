from Crypto.Random.random import randint
from requests.api import post
from time import sleep

from datetime import datetime


CONTROL_PORT = 6
GPIO_DELAY = 0.5  # #delay for GPIO
start_time = None

def is_port_active(port):
    # some magic about GPIO
    r = randint(0, 10000)
    return r > 9999
    # some magic about GPIO


def print_elapsed(td):
    print('Elapsed {:.3}s.'.format(td.seconds + td.microseconds / 10.0 ** 6))


url = raw_input('IP:port to control server (empty for localhost:8888) >>> ') or 'localhost:8888'
url = ''.join(('http://', url, '/control/timer'))

while 1:
    # sleep(0.005)
    if is_port_active(CONTROL_PORT):
        if start_time is None:
            start_time = datetime.now()
            sleep(GPIO_DELAY)
            continue
        else:
            lap_time = datetime.now() - start_time
            start_time = None
            miliseconds = lap_time.seconds * 1000 + lap_time.microseconds / 1000.0
            r = post(url, data={'time': miliseconds})
            raw_input('end! enter to continue..')

        # TODO: add printing

