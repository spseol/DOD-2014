function getLogger() {
    var ws = new WebSocket('ws://' + window.location.host + '/ws/logger');
    var $logger = $('#logger');
    var log = function(content, level, d) {
        var d = new Date(d*1000);
        var $time = $('<span></span>').text(d.toLocaleString()).addClass('pull-right');
        $('<div></div>').prependTo($logger).hide().addClass('text-' + level).text(content).append($time).slideDown(1000);
    };
    ws.onmessage = function (evt) {
        var msg = $.parseJSON(evt.data);
        console.log(msg);
        log(msg.content, msg.level, msg.created)
    };
    return log;
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
    
    var setBrick = function(enable) {
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
    setBrick(brickOK);
    ws.onmessage = function (evt) {
        var state = $.parseJSON(evt.data);
        console.log(state);
        setBrick(state.brick_found);
    };

    $form.submit(function(event) {
        event.preventDefault();
        ws.send($number.val());
    });
    exit = function (evt) {
        setBrick(false);
        log('Communication error occured!', 'danger', new Date());
    };
    ws.onclose = exit;
    ws.onerror = exit;

});