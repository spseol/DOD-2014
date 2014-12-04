import logging

from tornado.escape import json_decode

from tornado.websocket import WebSocketHandler

from BrickController import BrickController


class ControlSocketHandler(WebSocketHandler):
    clients = []
    client_controller = None

    def __init__(self, application, request, **kwargs):
        super(ControlSocketHandler, self).__init__(application, request, **kwargs)
        self.messages = []

    def open(self):
        self.clients.append(self)
        if self.client_controller is None and len(self.clients) == 1:
            self.client_controller = self
        logging.info('New WS from {} opened ({} sockets active).'
                     .format(self.request.remote_ip, len(self.clients)))

        if not BrickController.brick_found:
            BrickController.init_brick()
        if not self.is_client_controller():
            return
        ret_msg = BrickController.get_state()
        if not BrickController.brick_found:
            ret_msg.update({'error': 'Brick not found.'})
        self.refresh_clients()
        self.write_message(ret_msg)

    def on_close(self):
        if self not in self.clients:
            logging.warning('Removing not existing WS.')
        else:
            self.clients.remove(self)
        if len(self.clients) > 1:
            self.client_controller = self.clients[0]
        self.refresh_clients()
        logging.info('WS from {} closed ({} sockets remaining).'
                     .format(self.request.remote_ip, len(self.clients)))

    def on_message(self, message):
        if not BrickController.brick_found:
            ret_msg = BrickController.get_state()
            ret_msg.update({'error': "Brick not found."})
            self.write_message(ret_msg)
            return
        if not self.is_client_controller():
            self.refresh_clients()
            return

        self.messages.append(message)
        try:
            msg_dict = json_decode(message)
        except ValueError:
            self.write_message({'error': "Invalid JSON msg."})
            return
        logging.info('Received {}. message from {}:\n{}'
                     .format(len(self.messages), self.request.remote_ip, msg_dict))
        try:
            BrickController.process(**msg_dict)
        except:
            BrickController.brick_found = False
            for cl in self.clients:
                cl.write_message(BrickController.get_state())

    def is_client_controller(self):
        return self.client_controller == self

    @classmethod
    def refresh_clients(cls):
        clients = cls.clients[:]
        try:
            clients.remove(cls.client_controller)
        except ValueError:
            pass
        ret = BrickController.get_state()
        ret.update({'error': "Sorry, you're actually not the main client."})
        for cl in clients:
            cl.write_message(ret)



