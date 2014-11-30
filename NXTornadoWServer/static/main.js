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
            toggleState(false, $OK, $KO);
            log(message, msg_class, new Date());
        };
    };
    RobotController.ws.onclose = getErrorFun('Connection has been valid closed.', 'warning');
    RobotController.ws.onerror = getErrorFun('WebSocket error occurred!', 'danger');

});