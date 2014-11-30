$(function() {
    ServerLogger.init($('#logger'));
    var log = ServerLogger.log;
    var $OK = $('#brick-ok');
    var $KO = $('#brick-ko, #cover');
    var $trottle = $('input[name=trottle]');

    RobotController.init($OK, $KO, $trottle, log);
    RobotController.toggleState(brickOK);

    getErrorFun = function (message, msg_class) {
        return function(evt) {  
            RobotController.toggleState(false, $OK, $KO);
            ServerLogger.log(message, msg_class, new Date());
        };
    };
    RobotController.ws.onclose = getErrorFun('Connection has been closed.', 'danger');
    RobotController.ws.onerror = getErrorFun('WebSocket error occurred!', 'danger');
});