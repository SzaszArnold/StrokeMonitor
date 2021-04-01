import * as messaging from "messaging";

messaging.peerSocket.addEventListener("message", (evt) => {
  var hdata=JSON.stringify(evt.data);
  setInterval(console.error(hdata), 5000);
  var data =  hdata;
  var url='https://strokemonitor-34e3c-default-rtdb.firebaseio.com/arnoldszasz06data/arni.json';
  fetch(url, {
  method: 'PUT', // Put= modify only one/ 'POST'=upload all
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






