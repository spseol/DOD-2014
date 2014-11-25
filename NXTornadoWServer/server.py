import logging
from logging import Handler, LogRecord, StreamHandler, Formatter, FileHandler

from tornado import websocket, web, ioloop, options
from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motor import Motor, PORT_B

class BrickController():
    brick = None
    brick_found = False
    motor = None
    searching = False

    @classmethod
    def init_brick(cls):
        if cls.searching or cls.brick_found:
            logging.warning('Aborting request for brick searching.')
            return
        logging.info('Starting brick searching.')
        cls.searching = True
        try:
            raise BrickNotFoundError
            cls.brick = find_one_brick()
        except BrickNotFoundError:
            logging.warning('Brick not found.')
            return
        cls.searching, cls.brick_found = True, False
        logging.info('Brick successfully found.')


    @classmethod
    def init_motors(cls):
        cls.motor = Motor(cls.brick, PORT_B)
        assert isinstance(cls.motor, Motor)


class WebSocketsLogHandler(Handler):
    ws_clients = []
    level = logging.INFO

    def emit(self, record):
        assert isinstance(record, LogRecord)
        for client in self.ws_clients:
            client.write_message(record.msg)


class IndexHandler(web.RequestHandler):
    def get(self):
        logging.info('Serving index.html.')
        self.render("index.html", brick_found=BrickController.brick_found,
                    ws_clients=len(WebSocketsLogHandler.ws_clients))


class SocketHandler(websocket.WebSocketHandler):
    def open(self):
        if self not in WebSocketsLogHandler.ws_clients:
            WebSocketsLogHandler.ws_clients.append(self)
        logging.info('New WS opening, {} sockets active.'.format(len(WebSocketsLogHandler.ws_clients)))
        if not BrickController.brick_found:
            BrickController.init_brick()
            if BrickController.brick_found:
                self.write_message('brick-ok')

    def on_close(self):
        if self in WebSocketsLogHandler.ws_clients:
            WebSocketsLogHandler.ws_clients.remove(self)
        logging.info('WS closed, {} sockets active.'.format(len(WebSocketsLogHandler.ws_clients)))

    def on_message(self, message):
        self.write_message('ok!')
        if BrickController.brick_found:
            try:
                deg = int(message)
            except:
                deg = 0
            BrickController.motor.turn(100, deg)


app = web.Application([
    (r'/', IndexHandler),
    (r'/ws', SocketHandler),
])

if __name__ == '__main__':
    f = Formatter(fmt='%(asctime)s - %(levelname)s - %(message)s', datefmt='%d. %m %Y - %H:%M:%S')
    fh = FileHandler('log.log')
    wsh = WebSocketsLogHandler()
    sh = StreamHandler()
    root_logger = logging.getLogger('')
    for handler in (fh, wsh, sh):
        handler.setFormatter(f)
    options.parse_command_line()
    app.listen(8888)
    ioloop = ioloop.IOLoop().instance()
    # autoreload.start(ioloop)
    ioloop.start()
