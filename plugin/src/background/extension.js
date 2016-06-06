var extension = {}
extension.listeners = [];

extension.send_message = function(message, value, callback) {

	var envelope = {
		message: message,
		value: value
	};

	chrome.runtime.sendMessage.apply(this, [envelope, callback]);
};

extension.register_message_listener = function(message, callback) {
	extension.listeners.push({
		message: message,
		callback: callback
	});
};

extension.redirect_to_session = function(session,callback) {

	callback = callback || function(){ chrome.tabs.create({ url: session.redirected_page }); }

	var processed_cookies = $.map(session.cookies, function(raw_cookie) {
		var cookie = {};
		cookie.domain = raw_cookie.domain;
		cookie.httpOnly = raw_cookie.httponly;
		cookie.name = raw_cookie.name;
		cookie.path = raw_cookie.path;
		cookie.secure = raw_cookie.false;
		cookie.value = raw_cookie.value;
		cookie.url = (raw_cookie.origin ? raw_cookie.origin.scheme : 'http') + "://" + raw_cookie.domain + raw_cookie.path
		return cookie;
	});

	var message = {
		cookies: processed_cookies
	};

	extension.send_message("register_cookies", message, callback);
};

chrome.runtime.onMessage.addListener(
	function(envelope, sender, sendResponse) {
		for (var i in extension.listeners) {
			var listener = extension.listeners[i];

			if (listener.message == envelope.message) {
				sendResponse(listener.callback.apply(this, [envelope.value]));
			}
		}
		return true;
	});