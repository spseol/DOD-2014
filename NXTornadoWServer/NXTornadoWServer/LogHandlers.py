from logging import Handler, LogRecord
import logging

from tornado.websocket import WebSocketHandler

class LoggerSocketHandler(WebSocketHandler):
    clients = []

    def open(self):
        if self not in self.clients:
            self.clients.append(self)
	msgs = WebSocketsLogHandler.dicts[:]
	if len(msgs) > 150:
	    msgs = msgs[-150:]
        for d in msgs:
            self.write_message(d)

    def on_close(self):
        if self in self.clients:
            self.clients.remove(self)

    def on_message(self, message):
        pass


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
