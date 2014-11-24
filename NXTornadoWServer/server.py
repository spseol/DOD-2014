from tornado import websocket, web, ioloop, options
from tornado import autoreload

from nxt.locator import find_one_brick, BrickNotFoundError
from nxt.motor import Motor, PORT_B


ws_clients = []


class BrickController():
    brick = None
    brick_found = False
    motor = None
    searching = False


    @classmethod
    def init_brick(cls):
        """
        decompose this!
        """
        if cls.searching:
            print(' *** ABORTING REQUEST FOR BRICK *** ')
            return
        try:
            print(' *** BRICK FINDING *** ')
            cls.searching = True
            cls.brick = find_one_brick()
        except BrickNotFoundError:
            return
        cls.searching = False
        print(' *** BRICK FOUND *** ')
        cls.motor = Motor(cls.brick, PORT_B)
        assert isinstance(cls.motor, Motor)
        cls.brick_found = True


class IndexHandler(web.RequestHandler):
    def get(self):
        self.render("index.html", brick_found=BrickController.brick_found, ws_clients=len(ws_clients))


class SocketHandler(websocket.WebSocketHandler):
    def open(self):
        if not BrickController.brick_found:
            BrickController.init_brick()
            if BrickController.brick_found:
                self.write_message('brick-ok')
        if self not in ws_clients:
            ws_clients.append(self)

    def on_close(self):
        if self in ws_clients:
            ws_clients.remove(self)

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
    options.parse_command_line()
    app.listen(8888)
    ioloop = ioloop.IOLoop().instance()
    autoreload.start(ioloop)
    ioloop.start()
