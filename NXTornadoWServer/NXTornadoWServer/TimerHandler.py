from pprint import pprint
from tornado.web import RequestHandler


class TimerHandler(RequestHandler):
    def post(self, *args, **kwargs):
        pprint({k:''.join(v) for k,v in self.request.arguments.iteritems()})