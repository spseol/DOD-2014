import logging
from tornado.gen import coroutine
from tornado.web import asynchronous

from tornado.websocket import WebSocketHandler

from BrickController import BrickController


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