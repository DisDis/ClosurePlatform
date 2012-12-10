goog.require('goog.debug.Logger');
goog.require('example.page.debug');
goog.require('example.global.stateManager');
goog.require('example.states.Lobby');
goog.require('example.states.Room');

goog.provide('example.page.other');

window["init"] = function() {
    example.log.info('Run web');
    example.global.stateManager.init({
        $buffer1 : $('#'+goog.getCssName('l-fxd-screen1')),
        $buffer2 : $('#'+goog.getCssName('l-fxd-screen2'))
    }).addState('lobby',
            new example.states.Lobby().init({})).addState('room',
                    new example.states.Room().init({}));
    example.log.info("Start synchronize");
    function syncFase() {
        example.global.stateManager.setState('lobby');
    }

    setTimeout(syncFase,1000);
};
