var RobotController = {
    ws: {
        send: function () {
        }
    },
    settings: {
        wsPrefix: 'ws://',
        wsPostfix: '/ws/control'
    },
    $OK: $(),
    $KO: $(),
    $throttle: $(),
    log: function () {
    },
    lastControlStatus: {},
    actualSteering: 0.0,
    keys: {
        left: 37,
        up: 38,
        right: 39,
        down: 40,
        stop: 32
    },
    activeKeys: {
        37: false,
        38: false,
        39: false,
        40: false,
        32: false
    },
    reset: 0
};

RobotController.getControlStatus = function () {
    var obj = {
        steering: this.actualSteering / 100.0,
        throttle: 0,
        reverse: 0,
        reset: this.reset
    };
    if (this.activeKeys[this.keys.down]) {
        obj.throttle = parseInt(this.$throttle.val());
        obj.reverse = 1;
    }
    if (this.activeKeys[this.keys.up]) {
        obj.throttle = parseInt(this.$throttle.val());
        obj.reverse = 0;
    }
    return obj
};

RobotController.refreshControlStatus = function () {
    var status = RobotController.getControlStatus();
    var lastStatus = RobotController.lastControlStatus;
    if ((status.steering == lastStatus.steering &&
    status.throttle == lastStatus.throttle &&
        status.reverse == lastStatus.reverse) || !status.reset) {
        return
    }
    RobotController.lastControlStatus = status;
    RobotController.ws.send(JSON.stringify(status));
};

RobotController.refreshSteering = function () {
    var RC = RobotController;
    var step = 20;
    if (RC.activeKeys[RC.keys.left] && !RC.activeKeys[RC.keys.right]) {
        RC.actualSteering -= step;
    } else if (RC.activeKeys[RC.keys.right] && !RC.activeKeys[RC.keys.left]) {
        RC.actualSteering += step
    } else {
        if (RC.actualSteering > 0) {
            RC.actualSteering -= step;
        } else if (RC.actualSteering < 0) {
            RC.actualSteering += step;
        }
    }
    if (RC.actualSteering >= 100) {
        RC.actualSteering = 100;
    } else if (RC.actualSteering <= -100) {
        RC.actualSteering = -100;
    }
};

RobotController.toggleState = function (state) {
    if (!state.error)  {
        this.$KO.find('h3').text("Something's wrong.");
        if (state.brick_found) {
            this.$OK.show(200);
            this.$KO.hide(200);
        } else {
            this.$KO.show(200);
            this.$OK.hide(200);
        }
    } else {
        this.$KO.find('h3').text(state.error);
        this.$KO.show(200);
        this.$OK.hide(200);
    }

};

RobotController.onKeyEvent = function (e) {
    if (!(e.keyCode in RobotController.activeKeys)) {
        return
    }
    e.preventDefault();
    if (e.type == 'keydown' || e.type == 'keypress') {
        RobotController.activeKeys[e.keyCode] = true;
        $('button[data-key=' + e.keyCode + ']').addClass('btn-danger').removeClass('btn-success');
    } else {
        RobotController.activeKeys[e.keyCode] = false;
        $('button[data-key=' + e.keyCode + ']').addClass('btn-success').removeClass('btn-danger');
    }
    RobotController.refreshControlStatus();
};

RobotController.onReset = function (e) {
    RobotController.reset = 1;
    RobotController.refreshControlStatus();
    RobotController.reset = 0;
};

RobotController.connectEvents = function () {
    $('html').on('keydown keyup keypress', this.onKeyEvent);
    $('button.reset').click(this.onReset);
};

RobotController.init = function ($OK, $KO, $throttle, log) {
    this.ws = new WebSocket(this.settings.wsPrefix + window.location.host + this.settings.wsPostfix);
    this.$OK = $OK;
    this.$KO = $KO;
    this.$throttle = $throttle;
    this.connectEvents();
    this.log = log;
    this.ws.onmessage = function (evt) {
        var json_data = $.parseJSON(evt.data);
        RobotController.toggleState(json_data);
        console.log(json_data);
    };
    setInterval(this.refreshControlStatus, 101);
    setInterval(this.refreshSteering, 100);
    this.connectEvents();
};
