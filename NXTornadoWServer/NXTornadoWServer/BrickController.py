import logging
from time import sleep

from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motcont import MotCont
from nxt.motor import Motor, PORT_A, PORT_B, BlockedException, PORT_C


class BrickController(object):
    motCont = None
    brick = None
    brick_found = False
    brick_searching = False
    steering_motor = None
    actual_abs_degs = 0
    main_motors = None
    last_commands = {
        'steering': 0,
        'throttle': 0,
        'reverse': 0,
    }
    STEERING_KEY = 'steering'
    throttle_KEY = 'throttle'
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
            cls.brick = find_one_brick(debug=True)
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
        cls.main_motors = (Motor(cls.brick, PORT_B), Motor(cls.brick, PORT_C))
        cls.motCont = MotCont(cls.brick)
        cls.motCont.start()


    @classmethod
    def process(cls, **commands):
        if not cls.brick_found:
            return
        print(commands[cls.STEERING_KEY], cls.last_commands[cls.STEERING_KEY])
        if commands[cls.STEERING_KEY] != cls.last_commands[cls.STEERING_KEY]:
            abs_degs = int(commands[cls.STEERING_KEY] * cls.FULL_SIDE_STEER)
            cls.set_steering(abs_degs)
            logging.info('New steering!')
        if commands[cls.throttle_KEY] != cls.last_commands[cls.throttle_KEY] or commands[cls.REVERSE_KEY] != \
                cls.last_commands[cls.REVERSE_KEY]:
            cls.set_throttle(commands[cls.throttle_KEY], commands[cls.REVERSE_KEY])
            logging.info('New throttle or reverse!')
        cls.last_commands = commands

    @classmethod    
    def set_steering(cls, abs_degs):
        if False:
            sleep(0.1)
            cls.motCont.move_to(PORT_A, 100 if abs_degs > 0 else -100, abs(abs_degs), speedreg=10)
        else:
            if cls.actual_abs_degs == abs_degs:
                logging.warn('OK')
                return
            elif abs_degs > cls.actual_abs_degs:
                tacho = 100
                degs = abs_degs - cls.actual_abs_degs
            elif abs_degs < cls.actual_abs_degs:
                tacho = -100
                degs = abs(abs_degs - cls.actual_abs_degs)
            logging.info('Steer {} degs to {}.'.format(degs, ('left', 'right')[tacho > 0]))
            try:
                cls.steering_motor.turn(tacho, degs, brake=True)
                # cls.steering_motor.weak_turn(tacho, degs)
                # cls.steering_motor.run(tacho)
                # sleep(degs/850.0)
                # cls.steering_motor.brake()
            except BlockedException:
                logging.warning('Steering motor blocked!')
            cls.actual_abs_degs = cls.steering_motor.get_tacho().block_tacho_count


    @classmethod
    def set_throttle(cls, throttle, reverse):
        if not reverse in (0, 1):
            logging.warn('Unknown reverse command, setting to default!')
            reverse = 0
        if throttle > 100 or throttle < 0:
            logging.warn('Unknown throttle command, setting to 0!')
            throttle = 0.0

        if throttle <= 0:
            cls.main_motors[1].brake()
            cls.main_motors[0].brake()
            return
        # <0,100> trans to <(0.7*127),127>
        motor_throttle = int((0.5 + 0.5 * (throttle / 100.0)) * 127)
        if reverse:
            cls.main_motors[0].run(-motor_throttle)
            cls.main_motors[1].run(motor_throttle)
        else:
            cls.main_motors[0].run(motor_throttle)
            cls.main_motors[1].run(-motor_throttle)


    @classmethod
    def get_state(cls):
        return {
            'brick_found': cls.brick_found,
            'brick_searching': cls.brick_searching,
            'steering_motor': cls.steering_motor._get_state().to_list() if cls.steering_motor else []
        }

    def __del__(self):
        print('Brick deleted')
        try:
            BrickController.motCont.stop()
            BrickController.brick.sock.close()
        except:
            pass