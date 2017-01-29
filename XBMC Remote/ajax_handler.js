if(!window.didloadajaxhandler) {

var s_ajaxListener = new Object();
s_ajaxListener.tempOpen = XMLHttpRequest.prototype.open;
s_ajaxListener.tempSend = XMLHttpRequest.prototype.send;
s_ajaxListener.callback = function () {
    window.location='mpAjaxHandler://' + this.url;
};

XMLHttpRequest.prototype.open = function(a,b) {
    if (!a) var a='';
    if (!b) var b='';
    s_ajaxListener.tempOpen.apply(this, arguments);
    s_ajaxListener.method = a;
    s_ajaxListener.url = b;
    if (a.toLowerCase() == 'get') {
        s_ajaxListener.data = b.split('?');
        s_ajaxListener.data = s_ajaxListener.data[1];
    }
}

XMLHttpRequest.prototype.send = function(a,b) {
    if (!a) var a='';
    if (!b) var b='';
    s_ajaxListener.tempSend.apply(this, arguments);
    if(s_ajaxListener.method.toLowerCase() == 'post')s_ajaxListener.data = a;
    s_ajaxListener.callback();
}

    window.onload = function() {
        console.log("loaded");
        var buttons=document.getElementsByClassName('ytp-play-button');
        if(buttons.length>0) {
            buttons[0].click();
            console.log("clicked");
        }
    }
    window.didloadajaxhandler = true;
}
