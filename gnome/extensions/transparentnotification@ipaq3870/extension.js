const Lang = imports.lang;
const Main = imports.ui.main;
const MessageTray = imports.ui.messageTray;

let orig;
let banner;

function style() {
  banner = this.source.createBanner(this);
  banner.actor.add_style_class_name('notification-transparency');
  return banner;
}

function init() {
}

function enable() {
  orig = MessageTray.Notification.prototype.createBanner;
  MessageTray.Notification.prototype.createBanner = style;
}

function disable() {
  MessageTray.Notification.prototype.createBanner = orig;
}
