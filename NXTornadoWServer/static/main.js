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
    ServerLogger.init($('#logger'));
    var log = ServerLogger.log;
    var $brickTitleOK = $('#brick-ok');
    var $brickTitleKO = $('#brick-ko');
    var $cover = $('#cover');
    var $form = $('#action-form');
    var ws = new WebSocket('ws://' + window.location.host + '/ws/control');
    var $number = $('input[type=number]');
    var $button = $('submit#turn');
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
		var obj = {
			"steering": steering/100.0,
			"trottle": 0,
			"reverse": 0
			};
        if (keysActive[keys.down] == true) {
			obj["trottle"] = 100;
			obj["reverse"] = 1;
		};
        if (keysActive[keys.up] == true) {
			obj["trottle"] = 100;
			obj["reverse"] = 0;
		};
		return obj
	};
    var lastObj = generateStatusJSON();
    var refreshRobot = function() {
        var obj = generateStatusJSON();
		var msg = JSON.stringify(obj);
        if (Math.abs(obj["steering"]-lastObj["steering"]) <= 0.05) {
            return
        }
		lastObj = obj;
		ws.send(msg);
    };
    $('html').on('keydown keyup keypress', function(e) {
        if (e.type == 'keydown' || e.type == 'keypress') {
            keysActive[e.keyCode] = true;
        } else {
            keysActive[e.keyCode] = false;
        }
        e.preventDefault();
        refreshRobot();
    });
    var steering = 0; // <-100;+100>
    setInterval(function() {
        if (keysActive[keys.left] && !keysActive[keys.right]) {
            steering += (steering > -100) ? -10 : 0;
        } else if (keysActive[keys.right] && !keysActive[keys.left]) {
            steering += (steering < 100) ? 10 : 0;
        } else {
            if (Math.abs(steering) <= 110) {
                steering += (steering > 0) ? -10 : ((steering == 0) ? 0 : 10);
            }
        }
        $('#steering').text(steering);
        refreshRobot();
    }, 150);

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
