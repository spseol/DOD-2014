import logging
from time import sleep
from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motcont import MotCont
from nxt.motor import Motor, PORT_A, PORT_B, BlockedException


class BrickController():
    motCont = None
    brick = None
    brick_found = False
    brick_searching = False
    steering_motor = None
    actual_steering_degs = 0
    main_motor = None
    last_commands = {
        'steering': 0,
        'trottle': 0,
        'reverse': 0,
    }
    STEERING_KEY = 'steering'
    TROTTLE_KEY = 'trottle'
    REVERSE_KEY = 'reverse'
    FULL_SIDE_STEER = 240

    @classmethod
    def init_brick(cls):
        if cls.brick_found:
            return cls.brick_found
        if cls.brick_searching:
            logging.warning('Aborting request for brick searching.')
            return cls.brick_found
        logging.info('Starting new brick brick searching.')
        cls.brick_searching = True
        try:
            # raise BrickNotFoundError
            cls.brick = find_one_brick()
        except BrickNotFoundError:
            logging.warning('Brick not found.')
            cls.brick_searching, cls.brick_found = False, False
            return cls.brick_found
        cls.brick_searching, cls.brick_found = False, True
        logging.info('Brick successfully found.')
        cls.init_motors()
        cls.motCont = MotCont(cls.brick)
        cls.motCont.start()
        return cls.brick_found

    @classmethod
    def init_motors(cls):
        cls.steering_motor = Motor(cls.brick, PORT_A)
        cls.main_motor = Motor(cls.brick, PORT_B)


    @classmethod
    def process(cls, **commands):
        if not cls.brick_found:
            return
        if commands[cls.STEERING_KEY] != cls.last_commands[cls.STEERING_KEY]:
            abs_degs = int(commands[cls.STEERING_KEY] * cls.FULL_SIDE_STEER)
            cls.set_steering(abs_degs)
            logging.info('New steering!')
        if commands[cls.TROTTLE_KEY] != cls.last_commands[cls.TROTTLE_KEY] or commands[cls.REVERSE_KEY] != cls.last_commands[cls.REVERSE_KEY]:
            cls.set_trottle(commands[cls.TROTTLE_KEY], commands[cls.REVERSE_KEY])
            logging.info('New trottle or reverse!')
        cls.last_commands = commands

    @classmethod    
    def set_steering(cls, abs_degs):
        sleep(0.1)
        cls.motCont.move_to(PORT_A, 100 if abs_degs > 0 else -100, abs(abs_degs), speedreg=10)

    
    @classmethod
    def set_trottle(cls, trottle, reverse):
        if not reverse in (0, 1):
            logging.warn('Unknown reverse command, setting to default!')
            reverse = 0
        if not(trottle <= 100 and trottle >= 0):
            logging.warn('Unknown trottle command, setting to 0!')
            trottle = 0.0

        if trottle <= 0:
            cls.main_motor.brake()
            return
        # <0,100> trans to <(0.7*127),127>
        motor_trottle = int((0.5 + 0.5 * (trottle / 100.0)) * 127)
        if not reverse:
            cls.main_motor.run(motor_trottle)
        else:
            cls.main_motor.run(-motor_trottle)



    @classmethod
    def get_state(cls):
        return {
            'brick_found': cls.brick_found,
            'brick_searching': cls.brick_searching,
            'steering_motor': cls.steering_motor._get_state().to_list() if cls.steering_motor else []
        }
