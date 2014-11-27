function getLogger() {
    var ws = new WebSocket('ws://' + window.location.host + '/ws/logger');
    var $logger = $('#logger');
    var log = function(content, level, created, type) {
        if (!(created instanceof Date)) {
            var created = new Date(created*1000);
        }
        var $time = $('<span></span>').text(created.toLocaleString()).addClass('pull-right').attr('title', type);
        $('<div></div>').prependTo($logger).hide().addClass('text-' + level).html(content).append($time).slideDown(200).data('type', type);
    };

    ws.onmessage = function (evt) {
        var msg = $.parseJSON(evt.data);
        log(msg.content.replace('\n', '<br>'), msg.level, msg.created, 'control-msg');
    };
    return log;
};

function toggleState(enable, $brickTitleOK, $brickTitleKO, $cover) {
    if (enable) {
        $brickTitleKO.fadeOut(500);
        $brickTitleOK.fadeIn(500);
        $cover.fadeOut(200);
    } else {
        $brickTitleKO.show();
        $brickTitleOK.hide();
        $cover.fadeIn(200);
    }
};

function createControlMessage(trottle, steering, reverse) {
    return {
        "trottle": trottle,
        "steering": steering,
        "reverse": reverse
    }
};

$(function() {
    var $brickTitleOK = $('#brick-ok');
    var $brickTitleKO = $('#brick-ko');
    var $cover = $('#cover');
    var $form = $('#action-form');
    var log = getLogger();
    var ws = new WebSocket('ws://' + window.location.host + '/ws/control');
    var $number = $('input[type=number]');
    var $button = $('submit#turn');
    
    var lastMsg = {};
    var arrowKeyDown = function(e) {
        keys = {
            left: 37,
            up: 38,
            right: 39,
            down: 40,
            stop: 32
        }
        var e = e || window.event;
        var key = e.keyCode;
        var msg = createControlMessage(0, 0, 0);
        switch (key) {
            case keys.left:
                msg = createControlMessage(100, -0.5, 0);
                break
            case keys.up:
                msg = createControlMessage(100, 0, 0);
                break
            case keys.right:
                msg = createControlMessage(100, 0.5, 0);
                break
            case keys.down:
                msg = createControlMessage(100, 0, 1);
                break
            case keys.stop:
                msg = createControlMessage(0, 0, 0);
                break
            default:
                return e
                break
        }
        if (e.type == "keyup") {
            msg = createControlMessage(0, 0, 0);
        }
        if (JSON.stringify(msg) == JSON.stringify(lastMsg)) {
            return e
        }
        console.log(msg);
        lastMsg = msg;
        ws.send(JSON.stringify(msg));
    };
    $(window).keydown(arrowKeyDown).keyup(arrowKeyDown);

    $form.find('button').click(function(event) {
        arrowKeyDown({keyCode: $(this).data('key')*1});
    });

    toggleState(brickOK, $brickTitleOK, $brickTitleKO, $cover);
    ws.onmessage = function (evt) {
        var state = $.parseJSON(evt.data);
        console.log(state);
        toggleState(state.brick_found, $brickTitleOK, $brickTitleKO, $cover);
    };

    getErrorFun = function (message, msg_class) {
        return function(evt) {  
            toggleState(false, $brickTitleOK, $brickTitleKO, $cover);
            log(message, msg_class, new Date());
        };
    };
    ws.onclose = getErrorFun('Connection has been valid closed.', 'warning');
    ws.onerror = getErrorFun('WebSocket error occurred!', 'danger');

});