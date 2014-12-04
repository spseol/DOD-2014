from logging import Handler, LogRecord
import logging

from tornado.websocket import WebSocketHandler


class LoggerSocketHandler(WebSocketHandler):
    clients = []

    def open(self):
        if self not in self.clients:
            self.clients.append(self)
        msgs = WebSocketsLogHandler.messages
        if len(msgs) > 50:
            msgs = msgs[-50:]
        for d in msgs:
            self.write_message(d)

    def on_close(self):
        if self in self.clients:
            self.clients.remove(self)

    def on_message(self, message):
        pass


class WebSocketsLogHandler(Handler):
    level = logging.INFO
    messages = []

    def emit(self, record):
        assert isinstance(record, LogRecord)
        msg_dict = {
            'content': record.msg % record.args,
            'level': record.levelname.lower(),
            'created': record.created

        }
        self.messages.append(msg_dict)
        for client in LoggerSocketHandler.clients:
            client.write_message(msg_dict)
