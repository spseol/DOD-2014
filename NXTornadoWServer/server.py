import logging
from logging import Handler, LogRecord, StreamHandler, Formatter, FileHandler
from tornado import web, ioloop, options, autoreload

from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motor import Motor, PORT_B
from tornado.web import StaticFileHandler
from tornado.websocket import WebSocketHandler


def init_logging():
    f = Formatter(fmt='%(asctime)s - %(levelname)s - %(message)s', datefmt='%d. %m. %Y - %H:%M:%S')
    fh = FileHandler('log.log')
    wsh = WebSocketsLogHandler()
    sh = StreamHandler()
    root_logger = logging.getLogger('')
    for handler in (fh, wsh, sh):
        handler.setFormatter(f)
        root_logger.addHandler(handler)


def on_reload():
    if BrickController.brick_found:
        BrickController.brick_found = BrickController.brick_searching = False
        BrickController.brick.sock.close()
        logging.info('reloading')


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
    def get_state(cls):
        return {
            'brick_found': cls.brick_found,
            'brick_searching': cls.brick_searching
        }


class WebSocketsLogHandler(Handler):
    level = logging.INFO
    dicts = []

    def emit(self, record):
        assert isinstance(record, LogRecord)
        msg_dict = {
            'content': record.msg % record.args,
            'level': record.levelname.lower(),
            'created': record.created

        }
        self.dicts.append(msg_dict)
        for client in LoggerSocketHandler.clients:
            client.write_message(msg_dict)


class IndexHandler(web.RequestHandler):
    def get(self):
        logging.info('Serving index.html.')
        self.render("index.html", brick_found=BrickController.brick_found,
                    ws_clients=len(ControlSocketHandler.clients))


class ControlSocketHandler(WebSocketHandler):
    clients = []

    def open(self):
        if self not in self.clients:
            self.clients.append(self)
        logging.info('New WS opening, {} sockets active.'.format(len(self.clients)))
        if not BrickController.brick_found:
            s = BrickController.init_brick()
            for cl in self.clients:
                cl.write_message(BrickController.get_state())

    def on_close(self):
        if self in self.clients:
            self.clients.remove(self)
        logging.info('WS closed, {} sockets active.'.format(len(self.clients)))

    def on_message(self, message):
        logging.info('Received message:\n"{}"'.format((message)))
        if BrickController.brick_found:
            try:
                deg = int(message)
            except:
                deg = 0
            BrickController.motor.turn(100, deg)


class LoggerSocketHandler(WebSocketHandler):
    clients = []

    def open(self):
        if self not in self.clients:
            self.clients.append(self)
        for d in WebSocketsLogHandler.dicts:
            self.write_message(d)

    def on_close(self):
        if self in self.clients:
            self.clients.remove(self)

    def on_message(self, message):
        pass


app = web.Application([
    (r'/', IndexHandler),
    (r'/ws/control', ControlSocketHandler),
    (r'/ws/logger', LoggerSocketHandler),
    (r'/(.*)', StaticFileHandler, {"path": "../NXTornadoWServer"})
                      ], log_function=lambda x: x)

if __name__ == '__main__':
    init_logging()
    options.parse_command_line()
    app.listen(8888)
    ioloop = ioloop.IOLoop().instance()
    autoreload.add_reload_hook(on_reload)
    autoreload.start(ioloop)
    ioloop.start()
    logging.info('Server starting.')
