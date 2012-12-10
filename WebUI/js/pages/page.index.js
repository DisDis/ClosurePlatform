goog.require('goog.debug.Logger');
goog.require('example.page.debug');
goog.require('example.global.stateManager');
goog.require('example.states.Intro');
goog.require('example.states.Test');

goog.provide('example.page.index');

window["init"] = function() {
    example.log.info('Run web');
    example.global.stateManager.init({
        $buffer1 : $('#'+goog.getCssName('l-fxd-screen1')),
        $buffer2 : $('#'+goog.getCssName('l-fxd-screen2'))
    }).addState('intro',
            new example.states.Intro().init({})).addState('test',
                    new example.states.Test().init({}));
    example.log.info("Start synchronize");
    function syncFase() {
        example.global.stateManager.history('intro');
    }

    setTimeout(syncFase,1000);
};
