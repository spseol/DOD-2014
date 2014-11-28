import logging
from tornado.escape import json_decode, json_encode
from tornado.gen import coroutine
from tornado.web import asynchronous

from tornado.websocket import WebSocketHandler

from BrickController import BrickController


class ControlSocketHandler(WebSocketHandler):
    clients = []
    def open(self):
        self.messages = []
        if self not in self.clients:
            self.clients.append(self)
        logging.info('New WS from {} opened ({} sockets active).'
            .format(self.request.remote_ip, len(self.clients)))
        if not BrickController.brick_found:
            s = BrickController.init_brick()
            for cl in self.clients:
                cl.write_message(BrickController.get_state())

    def on_close(self):
        if self in self.clients:
            self.clients.remove(self)
        logging.info('WS from {} closed ({} sockets remaining).'
            .format(self.request.remote_ip, len(self.clients)))

    def on_message(self, message):
        self.messages.append(message)
        try:
            msg_dict = json_decode(message)
        except:
            self.write_message('Are you fucking kidding me?')
            return
        logging.info('Received {}. message from {}:\n{}'
            .format(len(self.messages), self.request.remote_ip, msg_dict))
        BrickController.process(**msg_dict)

