var RobotController = {
	ws: {send: function() {},},
	settings: {
		wsPrefix: 'ws://',
		wsPostfix: '/ws/control',
	},
	$OK: $(),
	$KO: $(),
	$trottle: $(),
	log: function() {},
	lastControlStatus: {},
	actualSteering: 0.0,
	keys: {
		left: 37,
        up: 38,
        right: 39,
        down: 40,
        stop: 32,
    },
	activeKeys: {
		37: false,
        38: false,
        39: false,
        40: false,
        32: false,
	},
};

RobotController.getControlStatus = function() {
	var obj = {
		steering: this.actualSteering/100.0,
		trottle: 0,
		reverse: 0,
		};
    if (this.activeKeys[this.keys.down]) {
		obj.trottle = parseInt(this.$trottle.val());
		obj.reverse = 1;
	};
    if (this.activeKeys[this.keys.up]) {
		obj.trottle = parseInt(this.$trottle.val());
		obj.reverse = 0;
	};
	return obj
};

RobotController.refreshControlStatus = function() {
	var status = RobotController.getControlStatus();
	var lastStatus = RobotController.lastControlStatus;
	if (status.steering == lastStatus.steering &&
		status.trottle == lastStatus.trottle &&
		status.reverse == lastStatus.reverse) {
		return
	}
	RobotController.lastControlStatus = status;
	RobotController.ws.send(JSON.stringify(status));
};

RobotController.refreshSteering = function() {
	var RC = RobotController;
	var step = 25;
	var steering = RC.actualSteering;
    if (RC.activeKeys[RC.keys.left] && !RC.activeKeys[RC.keys.right]) {
        RC.actualSteering += (RC.actualSteering > -100) ? -step : 0;
    } else if (RC.activeKeys[RC.keys.right] && !RC.activeKeys[RC.keys.left]) {
        RC.actualSteering += (RC.actualSteering < 100) ? step : 0;
    } else {
        if (Math.abs(RC.actualSteering) <= 110) {
            RC.actualSteering += (RC.actualSteering > 0) ? -step : ((RC.actualSteering == 0) ? 0 : step);
        }
    }
    if (RC.actualSteering != steering) {
    	//RC.refreshControlStatus();
    }
};

RobotController.toggleState = function(enable) {
	if (enable) {
		this.$OK.show(200);
		this.$KO.hide(200);
	} else {
		this.$KO.show(200);
		this.$OK.hide(200);
	}
};

RobotController.onKeyEvent = function(e) {
	if (e.type == 'keydown' || e.type == 'keypress') {
            RobotController.activeKeys[e.keyCode] = true;
            $('button[data-key=' + e.keyCode + ']').addClass('btn-danger').removeClass('btn-success');
        } else {
            RobotController.activeKeys[e.keyCode] = false;
            $('button[data-key=' + e.keyCode + ']').addClass('btn-success').removeClass('btn-danger');
        }
        RC.refreshControlStatus();
        e.preventDefault();
};

RobotController.connectEvents = function() {
	$('html').on('keydown keyup keypress', this.onKeyEvent);
};

RobotController.init = function($OK, $KO, $trottle, log) {
	this.ws = new WebSocket(this.settings.wsPrefix + window.location.host + this.settings.wsPostfix);
	this.$OK = $OK;
	this.$KO = $KO;
	this.$trottle = $trottle;
	this.connectEvents();
	this.log = log;
	this.ws.onmessage = function (evt) {
        RobotController.toggleState($.parseJSON(evt.data).brick_found, $OK, $KO);
    };
    setInterval(this.refreshControlStatus, 200);
    setInterval(this.refreshSteering, 20);
    this.connectEvents();
};