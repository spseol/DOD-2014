import logging

from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motor import Motor, PORT_B


class BrickController():
    brick = None
    brick_found = False
    motor = None
    brick_searching = False

    @classmethod
    def init_brick(cls):
        if cls.brick_found:
            return cls.brick_found
        if cls.brick_searching:
            logging.warning('Aborting request for brick searching.')
            return cls.brick_found
        logging.info('Starting new brick brick_searching.')
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
        cls.motor = Motor(cls.brick, PORT_B)
        assert isinstance(cls.motor, Motor)

    @classmethod
    def process(cls, **commands):
        for key, value in commands.items():
            if getattr(cls, key, value) != value:
                #proccess new value
                print('{} new = {}'.format(key, value))
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