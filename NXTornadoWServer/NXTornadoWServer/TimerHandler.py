import logging

from tornado.web import RequestHandler


class TimerHandler(RequestHandler):
    def post(self):
        msg = {k: ''.join(v) for k, v in self.request.arguments.iteritems()}
        logging.info('Received time {:.4}s from timer.'.format(float(msg['time']) / 1000.0))