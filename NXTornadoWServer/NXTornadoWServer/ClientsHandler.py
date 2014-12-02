import logging
from tornado.web import RequestHandler
from NXTornadoWServer.ControlSocketHandler import ControlSocketHandler


class ClientsHandler(RequestHandler):

    def get(self):
        try:
            controller_i = ControlSocketHandler.clients.index(ControlSocketHandler.client_controller)
        except ValueError:
            controller_i = 0
        return self.render('../static/clients.html', clients=ControlSocketHandler.clients, controller_i=controller_i)

    def post(self):
        args = {k: ''.join(v) for k, v in self.request.arguments.iteritems()}
        try:
            ControlSocketHandler.client_controller = ControlSocketHandler.clients[int(args['i'])]
        except IndexError:
            pass
        ControlSocketHandler.refresh_clients()
