var ServerLogger = {
    ws: {
        send: function () {
        }
    },
    settings: {
        wsPrefix: 'ws://',
        wsPostfix: '/ws/logger'
    }
};

ServerLogger.log = function (content, level, created, type) {
    if (!(created instanceof Date)) {
        var created = new Date(created * 1000);
    }
    var $time = $('<span></span>').text(created.toLocaleString()).addClass('pull-right').attr('title', type);
    $('<div></div>').prependTo(this.$logger).hide().addClass('text-' + level).html(content).append($time).slideDown(200).data('type', type);
};

ServerLogger.init = function ($logger) {
    this.ws = new WebSocket(this.settings.wsPrefix + window.location.host + this.settings.wsPostfix);
    this.$logger = $logger;
    var logger = this;
    this.ws.onmessage = function (evt) {
        var msg = $.parseJSON(evt.data);
        logger.log(msg.content.replace('\n', '<br>'), msg.level, msg.created, 'logger-msg');
    };
};