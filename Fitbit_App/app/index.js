import clock from "clock";
import document from "document";
import { preferences } from "user-settings";
import * as util from "../common/utils";
import { HeartRateSensor } from "heart-rate";
import { me as appbit } from "appbit";
import * as messaging from "messaging";
import { user } from "user-profile";
import { battery } from "power";
import { today } from 'user-activity';
import { me as device } from "device";
import { vibration } from "haptics";
import exercise from "exercise";
/*Based on the documentation at the link: https://dev.fitbit.com/build/reference/device-api/heart-rate/
                                          https://dev.fitbit.com/build/reference/device-api/clock/
                                          https://dev.fitbit.com/build/reference/device-api/exercise/
                                          https://dev.fitbit.com/build/reference/device-api/messaging/
                                          https://dev.fitbit.com/build/reference/device-api/power/
*/
const modelID = device.modelId;
const SETTINGS_TYPE = "cbor";
const SETTINGS_FILE = "settings.cbor";
let settings = loadSettings();
const timeLabel = document.getElementById("timeLabel");
const dateLabel = document.getElementById("dateLabel");
const heartRateLabel = document.getElementById("heartRateLabel");
const accuLevel = document.getElementById("accuLabel");
const stepsCounter = document.getElementById("stepsLabel");
stepsCounter.text = "Steps: " + today.adjusted.steps;
accuLevel.text = "\u26A1 " + Math.floor(battery.chargeLevel) + "%";
console.log((user.maxHeartRate || "Unknown") + " BPM");
clock.granularity = "minutes";
clock.ontick = (evt) => {
    let today = evt.date;
    let hours = today.getHours();

    if (preferences.clockDisplay === "12h") {
        // 12h format
        hours = hours % 12 || 12;
    } else {
        // 24h format
        hours = util.zeroPad(hours);
    }

    let minutes = util.zeroPad(today.getMinutes());
    let seconds = util.zeroPad(today.getSeconds());

    let day = util.zeroPad(today.getDate());
    let month = util.zeroPad(today.getMonth() + 1);
    let year = today.getFullYear();

    timeLabel.text = `${hours}:${minutes}`;
    setDateDisplay(dateLabel, day, month, year, settings.USDateFormat);
}

if (HeartRateSensor && appbit.permissions.granted("access_heart_rate")) {
    const hrm = new HeartRateSensor();
    hrm.addEventListener("reading", () => {
        heartRateLabel.text = "\u2665 " + `${hrm.heartRate}`;
        if (hrm.heartRate != null && exercise.state == "stopped") {
            sendMessage(hrm.heartRate);
            if (hrm.heartRate >= 160) { vibration.start("alert"); }
            else { vibration.stop(); }
        }
    });
    hrm.start();
}
function setDateDisplay(obj, d, m, y, format) {

    let date;
    if (format) {
        date = `${m}/${d}/${y}`;
    }
    else {
        date = `${d}/${m}/${y}`;
    }

    obj.text = date;
    settings.USDateFormat = format;
}

messaging.peerSocket.onmessage = evt => {
    const dateLabel = document.getElementById("dateLabel");
    let t = new Date();
    let d = util.zeroPad(t.getDate());
    let m = util.zeroPad(t.getMonth() + 1);
    let y = t.getFullYear();
    setDateDisplay(dateLabel, d, m, y, evt.data);
}

appbit.onunload = saveSettings;

function loadSettings() {
    try {
        return fs.readFileSync(SETTINGS_FILE, SETTINGS_TYPE);
    } catch (ex) {
        // Defaults
        return {
            USDateFormat: false
        }
    }
}

function saveSettings() {
    fs.writeFileSync(SETTINGS_FILE, settings, SETTINGS_TYPE);
}

messaging.peerSocket.addEventListener("open", (evt) => {
    sendMessage();
});

messaging.peerSocket.addEventListener("error", (err) => {
    console.error(`Connection error: ${err.code} - ${err.message}`);
});


function sendMessage(data) {
    if (messaging.peerSocket.readyState === messaging.peerSocket.OPEN) {
        // Send the data to peer as a message
        messaging.peerSocket.send(data);
    }
}

const backgroundAnimation = document.getElementById("backgroundAnimation");

backgroundAnimation.animate("enable");