from tornado import websocket, web, ioloop, options
import json
from tornado import autoreload

from nxt.locator import find_one_brick
from nxt.motor import Motor, PORT_B


ws_clients = []
robot = {}


def init_brick():
    robot['brick'] = find_one_brick()
    print(' *** BRICK FOUND *** ')
    robot['motor'] = Motor(robot['brick'], PORT_B)


init_brick()


class IndexHandler(web.RequestHandler):
    def get(self):
        self.render("index.html", name='NXTornadoWServer', ws_clients=len(ws_clients))


class SocketHandler(websocket.WebSocketHandler):
    def open(self):
        if self not in ws_clients:
            ws_clients.append(self)

    def on_close(self):
        if self in ws_clients:
            ws_clients.remove(self)

    def on_message(self, message):
        try:
            deg = int(message)
        except:
            pass
        robot['motor'].turn(100, deg)


class ApiHandler(web.RequestHandler):
    @web.asynchronous
    def get(self, *args):
        self.finish()
        id = self.get_argument("id")
        value = self.get_argument("value")
        data = {"id": id, "value": value}
        data = json.dumps(data)
        for c in ws_clients:
            c.write_message(data)

    @web.asynchronous
    def post(self):
        pass


app = web.Application([
    (r'/', IndexHandler),
    (r'/ws', SocketHandler),
    (r'/api', ApiHandler),
    (r'/(favicon.ico)', web.StaticFileHandler, {'path': '../'}),
    (r'/(rest_api_example.png)', web.StaticFileHandler, {'path': './'}),
])

if __name__ == '__main__':
    options.parse_command_line()
    app.listen(8888)
    ioloop = ioloop.IOLoop().instance()
    autoreload.start(ioloop)
    ioloop.start()
