import * as messaging from "messaging";
import { settingsStorage } from "settings";
var id = 'invalid';
settingsStorage.onchange = evt => {
    if (evt.key === "oauth") {
        let data = JSON.parse(evt.newValue);
        fetch('https://api.fitbit.com/1/user/-/profile.json', {
            method: 'GET',
            headers: {
                "Authorization": `Bearer ${data.access_token}`
            }
        })
            .then(response => response.json())
            .then(data => {
                console.log('Success:', data['user']['encodedId']);
                id = data['user']['encodedId'];
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
};
function restoreSettings() {
    for (let index = 0; index < settingsStorage.length; index++) {
        let key = settingsStorage.key(index);
        if (key && key === "oauth") {
            let data = JSON.parse(settingsStorage.getItem(key))
        }
    }
}
messaging.peerSocket.onopen = () => {
    restoreSettings();
};
messaging.peerSocket.addEventListener("message", (evt) => {
    var hdata = JSON.stringify(evt.data);
    setInterval(console.error(hdata), 5000);
    var data = hdata;
    var url = `https://strokemonitor-34e3c-default-rtdb.firebaseio.com/${id}/data.json`;
    fetch(url, {
        method: 'PUT',
        body: JSON.stringify(hdata),
    })
        .then(response => response.json())
        .then(data => {
            console.log('Success:', data);
        })
        .catch((error) => {
            console.error('Error:', error);
        });
});
