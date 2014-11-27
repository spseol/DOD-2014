import logging

from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motor import Motor, PORT_A, PORT_B, BlockedException


class BrickController():
    brick = None
    brick_found = False
    motor = None
    brick_searching = False
    steering_motor = None
    steering_degs = 0
    STEERING_KEY = 'steering'
    main_motor = None
    TROTTLE_KEY = 'trottle'
    REVERSE_KEY = 'reverse'

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
        return cls.brick_found

    @classmethod
    def init_motors(cls):
        cls.steering_motor = Motor(cls.brick, PORT_A)
        cls.main_motor = Motor(cls.brick, PORT_B)
        assert isinstance(cls.steering_motor, Motor) and isinstance(cls.main_motor, Motor)

    @classmethod
    def process(cls, **commands):
        for key, value in commands.items():
            if getattr(cls, key, value) != value:
                #proccess new value
                print('{} new = {}'.format(key, value))
                if key == cls.STEERING_KEY:
                    assert isinstance(cls.steering_motor, Motor)
                    want_degs = int(value * 140)
                    if cls.steering_degs == want_degs:
                        continue
                    elif want_degs > cls.steering_degs:
                        tacho = 100
                        degs = want_degs - cls.steering_degs
                    elif want_degs < cls.steering_degs:
                        tacho = -100
                        degs = abs(want_degs - cls.steering_degs)
                    logging.info('{} to {}'.format(degs, ('left', 'right')[tacho > 0]))
                    try:
                        cls.steering_motor.turn(tacho, degs, False)
                        cls.steering_degs = want_degs
                    except BlockedException:
                        logging.warning('Steering motor blocked!')
                    print(cls.steering_motor._get_state().to_list())
                if key in (cls.REVERSE_KEY, cls.TROTTLE_KEY):
                    if commands[cls.REVERSE_KEY] == 0:
                        cls.main_motor.run(int(commands[cls.TROTTLE_KEY]*127/100.0))
                    else:
                        cls.main_motor.run(int(-commands[cls.TROTTLE_KEY]*127/100.0))

            else:
                #same as last
                print('{} same'.format(key, value))
            setattr(cls, key, value)


    @classmethod
    def get_state(cls):
        return {
            'brick_found': cls.brick_found,
            'brick_searching': cls.brick_searching
        }