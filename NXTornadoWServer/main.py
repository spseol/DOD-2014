import logging
from logging import StreamHandler, Formatter, FileHandler
from tornado import web, ioloop, options, autoreload

from tornado.web import StaticFileHandler

from NXTornadoWServer.BrickController import BrickController
from NXTornadoWServer.IndexHandler import IndexHandler
from NXTornadoWServer.LogHandlers import LoggerSocketHandler
from NXTornadoWServer.ControlSocketHandler import ControlSocketHandler
from NXTornadoWServer.LogHandlers import WebSocketsLogHandler
from NXTornadoWServer.TimerHandler import TimerHandler


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
        BrickController.motCont.stop()


app = web.Application([
                          (r'/', IndexHandler),
                          (r'/ws/control', ControlSocketHandler),
                          (r'/ws/logger', LoggerSocketHandler),
                          (r'/control/timer', TimerHandler),
                          (r'/static/(.*)', StaticFileHandler, {"path": "static"})
                      ], log_function=lambda x: x)

if __name__ == '__main__':
    init_logging()
    on_reload()
    options.parse_command_line()
    app.listen(8888)
    ioloop = ioloop.IOLoop().instance()
    autoreload.add_reload_hook(on_reload)
    autoreload.start(ioloop)
    ioloop.start()
    logging.info('Server starting.')
