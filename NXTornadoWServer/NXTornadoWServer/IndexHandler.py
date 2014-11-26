import logging
from tornado import web
from BrickController import BrickController
from ControlSocketHandler import ControlSocketHandler

__author__ = 'thejoeejoee'


class IndexHandler(web.RequestHandler):
    def get(self):
        logging.info('Serving index.html.')
        self.render("../static/index.html", brick_found=BrickController.brick_found,
                    ws_clients=len(ControlSocketHandler.clients))