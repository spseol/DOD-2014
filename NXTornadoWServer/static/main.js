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

$(function() {
    var $brickTitleOK = $('#brick-ok');
    var $brickTitleKO = $('#brick-ko');
    var $cover = $('#cover');
    var $form = $('#action-form');
    var log = getLogger();
    var ws = new WebSocket('ws://' + window.location.host + '/ws/control');
    var $number = $('input[type=number]');
    var $button = $('submit#turn');
	var lastMsg = "";
    var keys = {
            left: 37,
            up: 38,
            right: 39,
            down: 40,
            stop: 32
        };
	var keysActive = {
		    "37": false,
            "38": false,
            "39": false,
            "40": false,
            "32": false
	};
	var generateStatusJSON = function() {
		console.log(keysActive);
		var obj = {
			"steering":0,
			"trottle":0,
			"reverse":0
			};
		if (keysActive[keys.right]) {
			obj["steering"] = 0.5;
		} else if (keysActive[keys.left]) {
			obj["steering"] = -0.5;
		} else if (keysActive[keys.left] && (keysActive[keys.right])) {
			obj["steering"] = 0;
		} else if (keysActive[keys.down]) {
			obj["trottle"] = 100;
			obj["reverse"] = 1;
		} else if (keysActive[keys.up]) {
			obj["trottle"] = 100;
			obj["reverse"] = 0;
		} else if (keysActive[keys.stop]) {
			obj = {
				"steering":0,
				"trottle":0,
				"reverse":0
			}
		}
		return obj
	};
    var refreshRobot = function() {
        var obj = generateStatusJSON();
		var msg = JSON.stringify(obj);
		if (msg == lastMsg) {
			return
		} else {
			lastMsg = msg;
			console.log(obj);
			ws.send(msg);
		};
    };
	var keyDown = function(e) {
		keysActive[e.keyCode] = true;
		refreshRobot();
	};
	var keyUp = function(e) {
		keysActive[e.keyCode] = false;
		refreshRobot();
	};
    $(window).keydown(keyDown).keyup(keyUp);

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
