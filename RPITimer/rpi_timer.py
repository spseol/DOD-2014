from RPi.GPIO as GPIO
from Crypto.Random.random import randint
from requests.api import post
from time import sleep
import sys

from datetime import datetime

GPIO.setmode(GPIO.BOARD)
CONTROL_PORT = 6
ENABLE_PORT = 5
GPIO_DELAY = 0.5  # #delay for GPIO
start_time = None
GPIO.setup(ENABLE_PORT, GPIO.OUT)
GPIO.setup(CONTROL_PORT, GPIO.IN)

def is_port_active(port):
    return GPIO.input(port)


def set_port(port, enable):
    GPIO.output(port, enable)

def print_elapsed(td):
    sys.stdout.write('\r{:.4}s.'.format(td.seconds + td.microseconds / 10.0 ** 6))


url = raw_input('IP:port to control server (empty for localhost:8888) >>> ') or 'localhost:8888'
url = ''.join(('http://', url, '/control/timer'))

while 1:
    i = raw_input('\nDo you want repeat? (y/n) >>> ').lower()
    if not i in ('y', 'n') or i == 'n':
        continue

    set_port(ENABLE_PORT, True)
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
                set_port(ENEBLE_PORT, False)
		r = post(url, data={'time': lap_time.seconds * 1000 + lap_time.microseconds / 1000.0})
                break

